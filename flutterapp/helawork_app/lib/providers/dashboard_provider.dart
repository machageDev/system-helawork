import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  String userName = "";
  int inProgress = 0;
  int completed = 0;
  double totalPayments = 0.0;
  List<Map<String, dynamic>> activeTasks = [];
  List<Map<String, dynamic>> recentPayments = [];
  bool isLoading = false;
  String? error;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final apiService = ApiService();

      // Fetch user profile, tasks, and payments
      final profile = await apiService.getUserProfile();
      final tasksRaw = await ApiService.fetchTask();
      final paymentsRaw = await ApiService.getPaymentSummary();

      // Convert tasks to a list of maps
      final tasks = List<Map<String, dynamic>>.from(tasksRaw as Iterable);

      // ✅ FIX: Handle payments as a list instead of a map
      final payments = List<Map<String, dynamic>>.from(paymentsRaw as Iterable);

      // Profile
      userName = profile["name"] ?? "User";

      // Tasks
      inProgress = tasks.where((t) => t["status"] == "In Progress").length;
      completed = tasks.where((t) => t["status"] == "Completed").length;
      activeTasks = tasks.take(3).toList();

      // Payments
      totalPayments = payments.fold(
        0.0,
        (sum, p) => sum + (p["amount"]?.toDouble() ?? 0.0),
      );
      recentPayments = payments.take(3).toList();

      error = null;
    } catch (e) {
      error = "Failed to load dashboard: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
