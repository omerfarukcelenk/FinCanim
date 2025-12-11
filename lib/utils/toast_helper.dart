import 'package:falcim_benim/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class ToastHelper {
  ToastHelper._();

  // Provide a navigator key to use the overlay without BuildContext.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayState? get _overlay => navigatorKey.currentState?.overlay;

  static void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color textColor = Colors.white,
    double? fontSize,
  }) {
    _showOverlay(
      message,
      duration,
      backgroundColor ?? Colors.black87,
      textColor,
      fontSize ?? ResponsiveSize.fontSize_16,
    );
  }

  static void showSuccess(String message) {
    _showOverlay(
      message,
      const Duration(seconds: 2),
      Colors.green[700] ?? Colors.green,
      Colors.white,
      ResponsiveSize.fontSize_18,
    );
  }

  static void showError(String message) {
    _showOverlay(
      message,
      const Duration(seconds: 3),
      Colors.red[700] ?? Colors.red,
      Colors.white,
      ResponsiveSize.fontSize_18,
    );
  }

  static void showInfo(String message) {
    _showOverlay(
      message,
      const Duration(seconds: 2),
      Colors.blue[700] ?? Colors.blue,
      Colors.white,
      ResponsiveSize.fontSize_18,
    );
  }

  static void _showOverlay(
    String message,
    Duration duration,
    Color bg,
    Color fg,
    double fontSize,
  ) {
    final overlay = _overlay;

    void insert(OverlayState overlayState) {
      final entry = OverlayEntry(
        builder: (context) {
          return Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: _ToastWidget(
              message: message,
              backgroundColor: bg,
              textColor: fg,
              fontSize: fontSize,
            ),
          );
        },
      );

      overlayState.insert(entry);

      Future.delayed(duration, () {
        try {
          entry.remove();
        } catch (_) {}
      });
    }

    if (overlay == null) {
      // If overlay is not yet available (app still building), try to insert after
      // the next frame when overlay should be ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final overlayAfter = _overlay;
        if (overlayAfter != null) insert(overlayAfter);
      });
      return;
    }

    insert(overlay);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Text(
              widget.message,
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
