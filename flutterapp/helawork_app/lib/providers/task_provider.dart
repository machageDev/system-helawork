import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> get tasks => _tasks;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ✅ KEEP the existing method that works with authentication
  Future<void> fetchTasks(BuildContext context) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final data = await ApiService.fetchTasks(); 
      _tasks = List<Map<String, dynamic>>.from(data);
      
      print('✅ Successfully loaded ${_tasks.length} tasks');
      
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
      print('❌ Error loading tasks: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage))
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // ✅ ADD this new method for proposals (without context for flexibility)
  Future<void> fetchTasksForProposals() async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final data = await ApiService.fetchTasks(); 
      _tasks = List<Map<String, dynamic>>.from(data);
      
      print('✅ Successfully loaded ${_tasks.length} tasks for proposals');
      
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
      print('❌ Error loading tasks for proposals: $e');
      rethrow; // Important for error handling in forms
    } finally {
      _setLoading(false);
    }
  }

  // ✅ OPTION 1: Show ALL tasks (remove filtering)
  List<Map<String, dynamic>> get availableTasks {
    print('🔄 Available tasks called - total tasks: ${_tasks.length}');
    
    // Debug: Print all tasks to see what we have
    for (var task in _tasks) {
      print('📋 Task: ${task['title']} - assigned: ${task['assigned_user'] != null}, completed: ${task['completed'] ?? false}, approved: ${task['is_approved'] ?? false}');
    }
    
    return _tasks.map((task) {
      return {
        'id': task['task_id'] ?? task['id'],
        'title': task['title'] ?? 'Untitled Task',
        'description': task['description'] ?? '',
        'employer': task['employer'] ?? {},
      };
    }).toList();
  }

  // ✅ Get task title by ID (for proposal display)
  String getTaskTitleById(int taskId) {
    try {
      final task = _tasks.firstWhere(
        (task) => (task['task_id'] ?? task['id']) == taskId,
        orElse: () => {'title': 'Selected Task'}
      );
      return task['title'] ?? 'Selected Task';
    } catch (e) {
      print('❌ Error finding task title for ID $taskId: $e');
      return 'Selected Task';
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}