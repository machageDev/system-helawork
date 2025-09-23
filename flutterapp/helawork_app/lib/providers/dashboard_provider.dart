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

      //  Profile should be a Map
      final profile = await apiService.getUserProfile();

      // Tasks should be a List
      final tasksRaw = await ApiService.fetchTask();
      final tasks = List<Map<String, dynamic>>.from(tasksRaw as List);

      //  Payments should be a Map
      final paymentsRaw = await ApiService.getPaymentSummary();
      final payments = Map<String, dynamic>.from(paymentsRaw as Map);

      // Fill dashboard state
      userName = profile["name"] ?? "User";
      inProgress = tasks.where((t) => t["status"] == "In Progress").length;
      completed = tasks.where((t) => t["status"] == "Completed").length;
      totalPayments = (payments["total_earnings"] ?? 0).toDouble();

      activeTasks = tasks.take(3).toList();
      recentPayments =
          List<Map<String, dynamic>>.from(payments["recent"] ?? []);

      error = null;
    } catch (e) {
      error = "Failed to load dashboard: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
