import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardProvider with ChangeNotifier {
  String? userName;
  String? profilePictureUrl; 
  int inProgress = 0;
  int completed = 0;
  List<Map<String, dynamic>> activeTasks = [];
  bool isLoading = false;
  String? error;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Load user data first from SharedPreferences
      await _loadUserData();
      
      // Fetch tasks
      final tasksRaw = await ApiService.fetchTasks();

      // If no user data in SharedPreferences, get from API
      if (userName == null || userName!.isEmpty) {
        userName = await ApiService.getLoggedInUserName();
        // Save to SharedPreferences for future use
        await _saveUserData();
      }

      // TODO: Add this method to your ApiService to fetch profile picture
      // if (profilePictureUrl == null || profilePictureUrl!.isEmpty) {
      //   profilePictureUrl = await ApiService.getUserProfilePicture();
      //   await _saveUserData();
      // }

      // Convert tasks to a list of maps
      final tasks = List<Map<String, dynamic>>.from(tasksRaw);

      // Tasks - FIXED THE SYNTAX ERROR HERE
      inProgress = tasks.where((t) => t["status"] == "In Progress").length;
      completed = tasks.where((t) => t["status"] == "Completed").length; // Fixed this line
      activeTasks = tasks.take(5).toList();

      error = null;
    } catch (e) {
      error = "Failed to load dashboard: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    profilePictureUrl = prefs.getString('profilePictureUrl');
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != null) {
      await prefs.setString('userName', userName!);
    }
    if (profilePictureUrl != null) {
      await prefs.setString('profilePictureUrl', profilePictureUrl!);
    }
  }

  // Update user profile data
  Future<void> updateUserProfile(String name, String profileUrl) async {
    userName = name;
    profilePictureUrl = profileUrl;
    await _saveUserData();
    notifyListeners();
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('profilePictureUrl');
    userName = null;
    profilePictureUrl = null;
    notifyListeners();
  }
}