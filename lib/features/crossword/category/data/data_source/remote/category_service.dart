import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/category/data/data_source/category_service.dart';
import 'package:wordshool/features/crossword/shared/data/models/category.dart';
import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';

class CategoryDataSourceImpl extends CategoryDataSource {
  CategoryDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _published = 'published';

  @override
  Future<DataState<CrosswordCategoryModel>> getCategory(String categoryId) {
    return guardData('Category.getCategory', () async {
      final snap = await _firestore
          .collection(FirebaseCollections.crosswordCategories)
          .doc(categoryId)
          .get();
      return CrosswordCategoryModel.fromJson(snap.data() ?? const {},
          documentId: snap.id);
    });
  }

  @override
  Future<DataState<List<CrosswordPuzzleModel>>> getPuzzles({
    required String categoryId,
    int? afterNumber,
    required int limit,
  }) {
    return guardData('Category.getPuzzles', () async {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirebaseCollections.crosswordPuzzles)
          .where('categoryId', isEqualTo: categoryId)
          .where('status', isEqualTo: _published)
          .orderBy('number', descending: true)
          .limit(limit);
      if (afterNumber != null) query = query.startAfter([afterNumber]);
      final snap = await query.get();
      return [
        for (final doc in snap.docs)
          CrosswordPuzzleModel.fromJson(doc.data(), documentId: doc.id),
      ];
    });
  }
}
