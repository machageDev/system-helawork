import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> get tasks => _tasks;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchTasks(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final tasks = await ApiService.getTasks();
      _tasks = List<Map<String, dynamic>>.from(tasks);
    } catch (e) {
      _errorMessage = "Failed to load tasks";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load tasks")),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
