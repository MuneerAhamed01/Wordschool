import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/logging/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.instance.error(
      error,
      message: 'Unhandled bloc error in ${bloc.runtimeType}',
      tag: 'BLOC',
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    final errorMessage = _errorMessageFromState(transition.nextState);
    if (errorMessage != null) {
      AppLogger.instance.warning(
        '${bloc.runtimeType} entered error state',
        tag: 'BLOC',
        error: errorMessage,
      );
    }

    super.onTransition(bloc, transition);
  }

  String? _errorMessageFromState(Object? state) {
    if (state == null) return null;

    final match = RegExp(r'\.error\((.+)\)$').firstMatch(state.toString());
    return match?.group(1);
  }
}
