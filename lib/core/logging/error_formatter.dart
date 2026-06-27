import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum ErrorSource {
  firebase,
  auth,
  api,
  google,
  local,
  unknown,
}

class FormattedError {
  const FormattedError({
    required this.source,
    required this.code,
    required this.message,
    this.details,
  });

  final ErrorSource source;
  final String code;
  final String message;
  final String? details;

  String get sourceLabel => switch (source) {
        ErrorSource.firebase => 'FIREBASE',
        ErrorSource.auth => 'AUTH',
        ErrorSource.api => 'API',
        ErrorSource.google => 'GOOGLE',
        ErrorSource.local => 'LOCAL',
        ErrorSource.unknown => 'APP',
      };
}

class ErrorFormatter {
  ErrorFormatter._();

  static FormattedError parse(
    Object error, {
    String? fallbackMessage,
    String fallbackCode = '500',
  }) {
    if (error is FirebaseAuthException) {
      return FormattedError(
        source: ErrorSource.auth,
        code: error.code,
        message: error.message ?? fallbackMessage ?? error.code,
        details: error.plugin,
      );
    }

    if (error is FirebaseException) {
      return FormattedError(
        source: ErrorSource.firebase,
        code: error.code,
        message: error.message ?? fallbackMessage ?? error.code,
        details: error.plugin,
      );
    }

    if (error is GoogleSignInException) {
      return FormattedError(
        source: ErrorSource.google,
        code: error.code.name,
        message: error.description ?? fallbackMessage ?? error.toString(),
      );
    }

    if (error is DioException) {
      final response = error.response;
      final statusCode = response?.statusCode?.toString() ?? fallbackCode;

      return FormattedError(
        source: ErrorSource.api,
        code: statusCode,
        message: fallbackMessage ??
            response?.statusMessage ??
            error.message ??
            'Network request failed',
        details: _dioDetails(error),
      );
    }

    if (error is AppErrorPayload) {
      return FormattedError(
        source: error.source,
        code: error.code,
        message: error.message,
        details: error.details,
      );
    }

    if (error is String) {
      return FormattedError(
        source: ErrorSource.local,
        code: fallbackCode,
        message: fallbackMessage ?? error,
      );
    }

    return FormattedError(
      source: ErrorSource.unknown,
      code: fallbackCode,
      message: fallbackMessage ?? error.toString(),
    );
  }

  static String _dioDetails(DioException error) {
    final buffer = StringBuffer()
      ..writeln('${error.requestOptions.method} ${error.requestOptions.uri}');

    final responseData = error.response?.data;
    if (responseData != null) {
      buffer.writeln('Response: $responseData');
    }

    return buffer.toString().trim();
  }
}

class AppErrorPayload {
  const AppErrorPayload({
    required this.source,
    required this.code,
    required this.message,
    this.details,
  });

  final ErrorSource source;
  final String code;
  final String message;
  final String? details;
}
