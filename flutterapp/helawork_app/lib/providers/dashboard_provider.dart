import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  String userName = "";
  int inProgress = 0;
  int completed = 0;
  List<Map<String, dynamic>> activeTasks = [];
  bool isLoading = false;
  String? error;

 Future<void> loadData() async {
  isLoading = true;
  notifyListeners();

  try {

    // Fetch user profile and tasks
    final profileResponse = await ApiService.getUserProfile();
    final tasksRaw = await ApiService.fetchTasks(); 

    // Profile (check if success)
    if (profileResponse["success"] == true) {
      final profile = Map<String, dynamic>.from(profileResponse["data"]);
      userName = profile["name"] ?? "User";
    } else {
      userName = "User";
    }

    // Convert tasks to a list of maps
    final tasks = List<Map<String, dynamic>>.from(tasksRaw);

    // Tasks
    inProgress = tasks.where((t) => t["status"] == "In Progress").length;
    completed = tasks.where((t) => t["status"] == "Completed").length;
    activeTasks = tasks.take(5).toList();

    error = null;
  } catch (e) {
    error = "Failed to load dashboard: $e";
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
}