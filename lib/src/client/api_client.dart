import 'dart:io';

import 'package:dio/dio.dart';
import '../core/rawql_request.dart';
import '../core/rawql_response.dart';

typedef TokenProvider = Future<String?> Function();

class RawLibClient {
  final Dio _dio;
  final String rawqlPath;
  final TokenProvider? tokenProvider;

  RawLibClient({
    required String baseUrl,
    this.rawqlPath = '/rawql',
    this.tokenProvider,
    Dio? dio,
    InterceptorsWrapper? extraInterceptor,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               headers: {'Content-Type': 'application/json'},
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (tokenProvider != null) {
            final token = await tokenProvider!.call();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
      ),
    );
    if (extraInterceptor != null) _dio.interceptors.add(extraInterceptor);
  }

  Future<RawQlResponse<T>> execute<T>({
    RawQlRequest? request,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    File? file,
    List<File>? files,
    String? fieldName,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
    Options? options,
  }) async {
    Object bodyData;

    if (file != null || (files != null && files.isNotEmpty)) {
      final formData = FormData.fromMap({
        ...?request?.toJson(),
        ...?body,
        if (file != null && fieldName != null)
          fieldName: await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          ),
        if (files != null && files.isNotEmpty && fieldName != null)
          fieldName: [
            for (var f in files)
              await MultipartFile.fromFile(
                f.path,
                filename: f.path.split(Platform.pathSeparator).last,
              ),
          ],
      });
      bodyData = formData;
    } else {
      bodyData = {...?request?.toJson(), ...?body};
    }

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        rawqlPath,
        data: bodyData,
        queryParameters: queryParams,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: options,
      );

      if (res.data == null) {
        throw Exception('No data in response');
      }

      return RawQlResponse<T>.fromJson(res.data!, fromJson);
    } catch (e) {
      return RawQlResponse(status: false, message: e.toString());
    }
  }
}
