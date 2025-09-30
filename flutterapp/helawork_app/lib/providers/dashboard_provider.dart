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
      
      await _loadUserData();
      
      
      final tasksRaw = await ApiService.fetchTasks();

     
      if (userName == null || userName!.isEmpty) {
        userName = await ApiService.getLoggedInUserName();
       
        await _saveUserData();
      }

      
      if (profilePictureUrl == null || profilePictureUrl!.isEmpty) {
        await _loadProfilePictureFromAPI();
      }

      
      final tasks = List<Map<String, dynamic>>.from(tasksRaw);

     
      inProgress = tasks.where((t) => t["status"] == "In Progress").length;
      completed = tasks.where((t) => t["status"] == "Completed").length;
      activeTasks = tasks.take(5).toList();

      error = null;
    } catch (e) {
      error = "Failed to load dashboard: $e";
      print(' Dashboard load error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> _loadProfilePictureFromAPI() async {
    try {
      print(' Loading profile picture from API...');
      
      // Method 1: If you have a direct API endpoint for user profile
      // profilePictureUrl = await ApiService.getUserProfilePicture();
      
      // Method 2: Fetch user profile data that includes picture
      final userProfile = await ApiService.getUserProfile();
      if (userProfile != null && userProfile['profile_picture'] != null) {
        profilePictureUrl = userProfile['profile_picture'];
        print(' Profile picture loaded: $profilePictureUrl');
        await _saveUserData(); // Save to cache
      } else {
        print('ℹ No profile picture found in user profile');
      }
    } catch (e) {
      print(' Error loading profile picture: $e');
      // Don't throw error - just continue without profile picture
    }
  }

  
  Future<void> refreshProfilePicture() async {
    print(' Manually refreshing profile picture...');
    await _loadProfilePictureFromAPI();
    notifyListeners();
  }

  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    profilePictureUrl = prefs.getString('profilePictureUrl');
    print(' Loaded from cache - Name: $userName, Photo: $profilePictureUrl');
  }

 
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != null) {
      await prefs.setString('userName', userName!);
    }
    if (profilePictureUrl != null) {
      await prefs.setString('profilePictureUrl', profilePictureUrl!);
    }
    print(' Saved to cache - Name: $userName, Photo: $profilePictureUrl');
  }


  Future<void> updateUserProfile(String name, String profileUrl) async {
    userName = name;
    profilePictureUrl = profileUrl;
    await _saveUserData();
    notifyListeners();
    print(' User profile updated in dashboard');
  }

  
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('profilePictureUrl');
    userName = null;
    profilePictureUrl = null;
    notifyListeners();
    print(' User data cleared from dashboard');
  }
}