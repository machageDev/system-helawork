import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';

class UserProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  final Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// Set a field locally
  void setProfileField(String key, dynamic value) {
    _userProfile[key] = value;
    notifyListeners();
  }

  /// Create or update profile on server
  Future<void> saveProfile(BuildContext context, String token) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.updateUserProfile(_userProfile, token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? 'Profile saved successfully')),
      );
    } catch (e) {
      _errorMessage = 'Failed to save profile';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save profile')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
