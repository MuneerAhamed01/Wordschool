import 'package:wordshool/core/constants/consts.dart';
import 'package:wordshool/core/logging/error_formatter.dart';
import 'package:wordshool/core/logging/app_logger.dart';

abstract class DataState<T> {
  final T? data;
  final AppError? error;

  DataState({this.data, this.error});

  void print();
}

class DataSuccess<T> extends DataState<T> {
  DataSuccess({required super.data});

  @override
  void print() {
    AppLogger.instance.debug('$data', tag: 'DATA');
  }
}

class DataError<T> extends DataState<T> {
  DataError({
    required super.error,
    StackTrace? stackTrace,
    String? context,
  }) {
    _logError(stackTrace: stackTrace, context: context);
  }

  void _logError({StackTrace? stackTrace, String? context}) {
    final appError = error;
    if (appError == null || appError.silent) return;

    AppLogger.instance.logDataError(
      error: appError.error,
      code: appError.code,
      message: appError.message,
      context: context ?? 'DataError<$T>',
      stackTrace: stackTrace,
    );
  }

  @override
  void print() {
    _logError(context: 'DataError<$T>');
  }
}

class AppError {
  final dynamic error;
  final String message;
  final String code;
  final bool silent;

  AppError({
    required this.error,
    this.message = SOMETHING_WENT_WRONG,
    required this.code,
    this.silent = false,
  });

  factory AppError.fromException(
    Object exception, {
    String? message,
    String? code,
    bool silent = false,
  }) {
    final formatted = ErrorFormatter.parse(
      exception,
      fallbackMessage: message,
      fallbackCode: code ?? '500',
    );

    return AppError(
      error: exception,
      message: message ?? formatted.message,
      code: code ?? formatted.code,
      silent: silent,
    );
  }

  factory AppError.notFound({
    required String message,
    Object? error,
  }) {
    return AppError(
      error: error ?? message,
      message: message,
      code: '404',
      silent: true,
    );
  }

  factory AppError.cancelled({
    required String message,
    Object? error,
  }) {
    return AppError(
      error: error ?? message,
      message: message,
      code: '499',
      silent: true,
    );
  }

  factory AppError.validation({
    required String message,
    Object? error,
  }) {
    return AppError(
      error: error ?? message,
      message: message,
      code: '400',
      silent: true,
    );
  }
}
