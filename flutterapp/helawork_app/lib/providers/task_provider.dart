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
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final data = await ApiService.fetchTasks(); 
      _tasks = List<Map<String, dynamic>>.from(data);
      
      print(' Successfully loaded ${_tasks.length} tasks');
      
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

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}