class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final Object? error;

  const PaginationState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.currentPage,
    this.error,
  });

  factory PaginationState.initial() => const PaginationState(
    items: [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
    currentPage: 1,
  );

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    Object? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}
