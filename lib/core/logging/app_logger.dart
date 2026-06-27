import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:wordshool/core/logging/error_formatter.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  bool _enabled = false;
  late Logger _logger;

  void init({bool? enabled}) {
    _enabled = enabled ?? kDebugMode;
    _logger = Logger(
      filter: _AppLogFilter(_enabled),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 6,
        lineLength: 88,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        noBoxingByDefault: false,
      ),
    );

    if (_enabled) {
      info('App logger initialized', tag: 'APP');
    }
  }

  void debug(String message, {String tag = 'APP', Object? data}) {
    if (!_enabled) return;
    _logger.d(_format(tag, message), error: data);
  }

  void info(String message, {String tag = 'APP', Object? data}) {
    if (!_enabled) return;
    _logger.i(_format(tag, message), error: data);
  }

  void warning(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    _logger.w(
      _format(tag, message),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    Object error, {
    String? message,
    String tag = 'APP',
    StackTrace? stackTrace,
    String? code,
  }) {
    if (!_enabled) return;

    final formatted = ErrorFormatter.parse(
      error,
      fallbackMessage: message,
      fallbackCode: code ?? '500',
    );

    final buffer = StringBuffer()
      ..writeln(_format(formatted.sourceLabel, message ?? formatted.message))
      ..writeln('├─ Code: ${formatted.code}')
      ..writeln('└─ Message: ${formatted.message}');

    if (formatted.details != null && formatted.details!.isNotEmpty) {
      buffer.writeln('   Details: ${formatted.details}');
    }

    _logger.e(
      buffer.toString().trimRight(),
      error: error is String ? null : error,
      stackTrace: stackTrace,
    );
  }

  void logDataError({
    required Object error,
    required String code,
    required String message,
    String? context,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;

    final formatted = ErrorFormatter.parse(
      error,
      fallbackMessage: message,
      fallbackCode: code,
    );

    final buffer = StringBuffer()
      ..writeln(
        _format(
          formatted.sourceLabel,
          context ?? 'Operation failed',
        ),
      )
      ..writeln('├─ Code: $code')
      ..writeln('├─ Message: $message');

    final details = _resolveDetails(error, formatted.details);
    if (details != null) {
      buffer.writeln('└─ Details: $details');
    } else {
      buffer.write('└─');
    }

    _logger.e(
      buffer.toString().trimRight(),
      error: error is String ? null : error,
      stackTrace: stackTrace,
    );
  }

  String? _resolveDetails(Object error, String? formattedDetails) {
    if (formattedDetails != null && formattedDetails.isNotEmpty) {
      return formattedDetails;
    }

    if (error is String) {
      return null;
    }

    final asString = error.toString();
    return asString.isEmpty ? null : asString;
  }

  String _format(String tag, String message) => '[$tag] $message';
}

class _AppLogFilter extends LogFilter {
  _AppLogFilter(this.enabled);

  final bool enabled;

  @override
  bool shouldLog(LogEvent event) => enabled;
}
