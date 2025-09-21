import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> get tasks => _tasks;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // --- Fetch all tasks ---
  Future<void> fetchTasks(BuildContext context) async {
    _setLoading(true);
    _errorMessage = '';
    try {
      final data = await ApiService.getData('tasks/');
      _tasks = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      _showError(context, 'Failed to load tasks');
    } finally {
      _setLoading(false);
    }
  }

  // --- Fetch single task by id ---
  Future<Map<String, dynamic>?> fetchTaskById(
      BuildContext context, int id) async {
    _setLoading(true);
    try {
      final data = await ApiService.getData('tasks/');
      final task = Map<String, dynamic>.from(data as Map);

      final index = _tasks.indexWhere((t) => t['task_id'] == id);
      if (index != -1) {
        _tasks[index] = task;
      }
      return task;
    } catch (e) {
      _showError(context, 'Failed to load task details');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // --- Helpers ---
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    _errorMessage = message;
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
    notifyListeners();
  }
}
