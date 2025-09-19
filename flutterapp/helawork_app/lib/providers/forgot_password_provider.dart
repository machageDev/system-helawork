import 'package:flutter/material.dart';

class ForgotPasswordProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> resetPassword(String email, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // TODO: Replace with API call
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password reset link sent to your email")),
    );
  }
}
