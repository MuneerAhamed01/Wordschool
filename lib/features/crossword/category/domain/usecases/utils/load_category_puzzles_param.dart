class LoadCategoryPuzzlesParam {
  const LoadCategoryPuzzlesParam({required this.categoryId, this.afterNumber});

  final String categoryId;

  /// The last puzzle number already shown (null = first page).
  final int? afterNumber;
}
