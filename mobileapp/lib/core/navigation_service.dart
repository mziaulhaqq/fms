import 'package:flutter/material.dart';

/// Global navigation key to handle navigation from anywhere in the app
/// Particularly useful for handling authentication errors and redirects
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NavigationService {
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  /// Navigate to login screen and clear navigation stack
  static void navigateToLogin() {
    navigator?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
  
  /// Navigate to dashboard and clear navigation stack
  static void navigateToDashboard() {
    navigator?.pushNamedAndRemoveUntil('/dashboard', (route) => false);
  }
  
  /// Show error dialog
  static void showErrorDialog(String message) {
    final context = navigator?.context;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  /// Show snackbar message
  static void showSnackBar(String message, {bool isError = false}) {
    final context = navigator?.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
        ),
      );
    }
  }
}
