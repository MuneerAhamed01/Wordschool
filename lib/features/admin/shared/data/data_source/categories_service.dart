import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/shared/domain/models/results.dart';
import 'package:wordshool/core/utils/json_read.dart';

/// Categories callables (used by most admin sections).
class AdminCategoriesService {
  AdminCategoriesService(this._callable);

  final AdminCallable _callable;

  Future<DataState<List<AdminCategory>>> listCategories() async {
    final result = await _callable.call('adminListCategories');
    return AdminCallable.convert(
      result,
      (json) =>
          asMapList(json['categories']).map(AdminCategory.fromJson).toList(),
    );
  }

  Future<DataState<SaveResult>> saveCategory(AdminCategory category) async {
    final result = await _callable.call('adminSaveCategory', category.toJson());
    return AdminCallable.convert(result, SaveResult.fromJson);
  }
}
