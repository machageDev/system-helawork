import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TaskCompletionProvider with ChangeNotifier {
  Map<String, dynamic>? taskData;
  Map<String, dynamic>? completionData;
  bool isLoading = false;
  bool isSubmitting = false;
  String? error;

  Future<void> loadTaskCompletion(int taskId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Load task details
      final taskResponse = await ApiService.fetchTaskDetails(taskId);
      taskData = taskResponse;
      
      // Load completion data if exists
      final completionResponse = await ApiService.fetchTaskCompletion(taskId);
      completionData = completionResponse;
      
    } catch (e) {
      error = "Failed to load task completion: $e";
      print('Task completion load error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitCompletion(int taskId, String notes) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await ApiService.submitTaskCompletion(
        taskId: taskId,
        notes: notes,
      );
      
      if (response['success'] == true) {
        // Reload data to get updated completion
        await loadTaskCompletion(taskId);
        return true;
      }
      return false;
    } catch (e) {
      error = "Submission failed: $e";
      print('Submission error: $e');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateCompletion(int taskId, String notes) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await ApiService.updateTaskCompletion(
        taskId: taskId,
        notes: notes,
      );
      
      if (response['success'] == true) {
        await loadTaskCompletion(taskId);
        return true;
      }
      return false;
    } catch (e) {
      error = "Update failed: $e";
      print('Update error: $e');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}