import 'package:flutter/foundation.dart';

/// Simple logger that prints colored output to the console using ANSI codes.
/// Works in terminals that support ANSI colors (most modern terminals).
class Logger {
  Logger._();

  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _cyan = '\x1B[36m';
  static const _gray = '\x1B[90m';
  static bool enableInRelease = false;

  static void _print(String msg) {
    if (!kDebugMode && !enableInRelease) return;
    debugPrint(msg);
  }

  static void info(String message, {String tag = 'INFO'}) {
    final msg = '$_cyan[$tag] $_reset$message';
    _print(msg);
  }

  static void success(String message, {String tag = 'SUCCESS'}) {
    final msg = '$_green[$tag] $_reset$message';
    _print(msg);
  }

  static void warn(String message, {String tag = 'WARN'}) {
    final msg = '$_yellow[$tag] $_reset$message';
    _print(msg);
  }

  static void error(String message, {String tag = 'ERROR'}) {
    final msg = '$_red[$tag] $_reset$message';
    _print(msg);
  }

  static void debug(String message, {String tag = 'DEBUG'}) {
    final msg = '$_gray[$tag] $_reset$message';
    _print(msg);
  }
}
