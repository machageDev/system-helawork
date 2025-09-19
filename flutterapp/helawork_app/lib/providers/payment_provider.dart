
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  Map<String, dynamic>? paymentData;
  bool isLoading = false;
  String? error;

  Future<void> loadPaymentSummary() async {
    isLoading = true;
    notifyListeners();

    try {
      paymentData = await ApiService.getPaymentSummary();
      error = null;
    } catch (e) {
      error = "Failed to load: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> withdraw() async {
    try {
      final result = await ApiService.withdrawMpesa();
      return result['ResponseDescription'];
    } catch (e) {
      return "Withdraw failed: $e";
    }
  }
}
