import 'package:flutter/foundation.dart';
import '../core/rawql_response.dart';
import 'pagination_state.dart';

typedef FetchPage<T> = Future<RawQlPaginatedResponse<T>> Function(int page);

class PaginationController<T> extends ChangeNotifier {
  PaginationState<T> _state = PaginationState<T>.initial();
  PaginationState<T> get state => _state;

  late FetchPage<T> _fetch;

  void init(FetchPage<T> fetch) {
    _fetch = fetch;
  }

  Future<void> loadFirst({bool refresh = false}) async {
    if (refresh) {
      _state = PaginationState<T>.initial();
      notifyListeners();
    }

    final isInitial = _state.items.isEmpty;
    _state = _state.copyWith(
      isLoading: isInitial,
      isLoadingMore: !isInitial,
      error: null,
    );
    notifyListeners();

    try {
      final page = _state.currentPage;
      final resp = await _fetch(page);

      final newItems =
          (refresh || page == 1) ? <T>[] : List<T>.from(_state.items);
      newItems.addAll(resp.items.cast<T>());

      _state = _state.copyWith(
        items: newItems,
        hasMore: resp.hasMore,
        currentPage: resp.hasMore ? page + 1 : page,
        isLoading: false,
        isLoadingMore: false,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e,
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() => loadFirst(refresh: true);

  Future<void> loadMore() async {
    if (_state.isLoadingMore || !_state.hasMore) return;
    await loadFirst();
  }
}
