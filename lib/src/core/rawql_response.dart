abstract class RawQlResponseData<T> {
  const RawQlResponseData();

  factory RawQlResponseData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    switch (json['type']) {
      case 'single':
        return RawQlSingleResponse<T>(fromJson!(json['item']));
      case 'multiple':
        return RawQlMultipleResponse<T>(
          (json['items'] as List?)?.map<T>((e) => fromJson!(e)).toList() ??
              const [],
        );
      case 'paginated':
        return RawQlPaginatedResponse<T>(
          items:
              (json['items'] as List<dynamic>? ?? [])
                  .map<T>((e) => fromJson!(e))
                  .toList(),
          currentPage: json['currentPage'] ?? 1,
          nextPage: json['nextPage'],
          prevPage: json['prevPage'],
          hasMore: json['hasMore'] ?? false,
          totalItems: json['totalItems'],
          totalPages: json['totalPages'],
          limit: json['limit'] ?? 10,
        );
      default:
        throw Exception('Unknown response type: ${json['type']}');
    }
  }
}

class RawQlSingleResponse<T> extends RawQlResponseData<T> {
  final T item;
  const RawQlSingleResponse(this.item);
}

class RawQlMultipleResponse<T> extends RawQlResponseData<T> {
  final List<T> items;
  const RawQlMultipleResponse(this.items);
}

class RawQlPaginatedResponse<T> extends RawQlResponseData<T> {
  final List<T> items;
  final int currentPage;
  final int? nextPage;
  final int? prevPage;
  final bool hasMore;
  final int? totalItems;
  final int? totalPages;
  final int limit;

  const RawQlPaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    required this.limit,
    this.nextPage,
    this.prevPage,
    this.totalItems,
    this.totalPages,
  });
}

class RawQlResponse<T> {
  final bool status;
  final String message;
  final RawQlResponseData<T>? data;

  const RawQlResponse({required this.status, required this.message, this.data});

  factory RawQlResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    return RawQlResponse<T>(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      data:
          json['data'] == null
              ? null
              : RawQlResponseData<T>.fromJson(json['data'], fromJson),
    );
  }
}
