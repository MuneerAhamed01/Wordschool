import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/data/data_source/callable.dart';

/// Asks the server whether this account is an admin.
class AdminAccessService {
  AdminAccessService(this._callable);

  final AdminCallable _callable;

  /// Confirms the server accepts this account as an admin.
  Future<DataState<void>> checkAccess() async {
    final result = await _callable.call('adminListCategories');
    return AdminCallable.convert(result, (_) {});
  }
}
