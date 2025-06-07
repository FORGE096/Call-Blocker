import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SnackbarService {
  static void showSuccess(BuildContext context, String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 4,
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showBlockerEnabled(BuildContext context) {
    showSuccess(context, 'Call blocker has been enabled');
  }

  static void showBlockerDisabled(BuildContext context) {
    showInfo(context, 'Call blocker has been disabled');
  }

  static void showNumberBlocked(BuildContext context, String number) {
    showSuccess(context, 'Number $number has been blocked');
  }

  static void showNumberUnblocked(BuildContext context, String number) {
    showInfo(context, 'Number $number has been unblocked');
  }

  static void showPrefixBlocked(BuildContext context, String prefix) {
    showSuccess(context, 'Prefix $prefix has been blocked');
  }

  static void showPrefixUnblocked(BuildContext context, String prefix) {
    showInfo(context, 'Prefix $prefix has been unblocked');
  }

  static void showSettingsSaved(BuildContext context) {
    showSuccess(context, 'Settings have been saved');
  }

  static void showPermissionRequired(BuildContext context) {
    showWarning(
        context, 'Please grant required permissions to use call blocking');
  }

  static void showErrorOccurred(BuildContext context) {
    showError(context, 'An error occurred. Please try again');
  }
}
