import 'package:flutter/material.dart';

enum AppAlertType { success, error, warning, info }

class AppAlert {
  /// Displays a high-contrast modal dialog tailored for clear outdoor visibility.
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    AppAlertType type = AppAlertType.info,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.65), // Strong dimming for outdoor contrast
      builder: (BuildContext dialogContext) {
        return _AppAlertDialog(
          message: message,
          title: title,
          type: type,
          buttonText: buttonText,
        );
      },
    );
  }

  /// Convenience method for Success popups
  static Future<void> showSuccess(
    BuildContext context, {
    required String message,
    String? title = 'SUCCESS',
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      message: message,
      title: title,
      type: AppAlertType.success,
      buttonText: buttonText,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Convenience method for Error popups
  static Future<void> showError(
    BuildContext context, {
    required String message,
    String? title = 'ERROR',
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      message: message,
      title: title,
      type: AppAlertType.error,
      buttonText: buttonText,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Convenience method for Warning popups
  static Future<void> showWarning(
    BuildContext context, {
    required String message,
    String? title = 'WARNING',
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      message: message,
      title: title,
      type: AppAlertType.warning,
      buttonText: buttonText,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Convenience method for Info popups
  static Future<void> showInfo(
    BuildContext context, {
    required String message,
    String? title = 'NOTICE',
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      message: message,
      title: title,
      type: AppAlertType.info,
      buttonText: buttonText,
      barrierDismissible: barrierDismissible,
    );
  }
}

class _AppAlertDialog extends StatelessWidget {
  final String message;
  final String? title;
  final AppAlertType type;
  final String buttonText;

  const _AppAlertDialog({
    required this.message,
    this.title,
    required this.type,
    required this.buttonText,
  });

  Color get _primaryColor {
    switch (type) {
      case AppAlertType.success:
        return const Color(0xFF059669); // High saturation emerald green
      case AppAlertType.error:
        return const Color(0xFFDC2626); // High saturation crimson red
      case AppAlertType.warning:
        return const Color(0xFFD97706); // High saturation amber/orange
      case AppAlertType.info:
        return const Color(0xFF2563EB); // Royal blue
    }
  }

  Color get _badgeBgColor {
    switch (type) {
      case AppAlertType.success:
        return const Color(0xFFD1FAE5);
      case AppAlertType.error:
        return const Color(0xFFFEE2E2);
      case AppAlertType.warning:
        return const Color(0xFFFEF3C7);
      case AppAlertType.info:
        return const Color(0xFFDBEAFE);
    }
  }

  IconData get _icon {
    switch (type) {
      case AppAlertType.success:
        return Icons.check_circle_rounded;
      case AppAlertType.error:
        return Icons.error_rounded;
      case AppAlertType.warning:
        return Icons.warning_rounded;
      case AppAlertType.info:
        return Icons.info_rounded;
    }
  }

  String get _defaultTitle {
    switch (type) {
      case AppAlertType.success:
        return 'SUCCESS';
      case AppAlertType.error:
        return 'ERROR';
      case AppAlertType.warning:
        return 'WARNING';
      case AppAlertType.info:
        return 'NOTICE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = (title != null && title!.isNotEmpty) ? title! : _defaultTitle;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.black.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Icon with Tinted Badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _badgeBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 40,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // High-Contrast Title
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: Color(0xFF111827), // Crisp near-black
              ),
            ),
            const SizedBox(height: 12),

            // Message Body (large & high contrast for outdoor reading)
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 26),

            // Prominent Full-Width Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: _primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonText.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
