import 'dart:developer';

import 'package:wordshool/core/constants/consts.dart';

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
    log('$data');
  }
}

class DataError<T> extends DataState<T> {
  DataError({required super.error});

  @override
  void print() {
    final printData = '''
Error: ${error?.error},
Code: ${error?.code},
Message: ${error?.message}
      ''';
    log(printData);
  }
}

class AppError {
  final dynamic error;
  final String message;
  final String code;

  AppError({
    required this.error,
    this.message = SOMETHING_WENT_WRONG,
    required this.code,
  });
}
