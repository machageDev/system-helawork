import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';

class UserProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _apiService.getUserProfile();

    _isLoading = false;
    if (response["success"]) {
      _userProfile = response["data"];
    } else {
      _errorMessage = response["message"];
    }
    notifyListeners();
  }

  Future<void> updateProfile(BuildContext context) async {
    if (_userProfile == null) return;

    _isLoading = true;
    notifyListeners();

    final response = await _apiService.updateUserProfile(_userProfile!);

    _isLoading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["message"])),
    );
  }

  /// Update local profile field before sending update
  void setProfileField(String key, dynamic value) {
    if (_userProfile == null) return;
    _userProfile![key] = value;
    notifyListeners();
  }
}
