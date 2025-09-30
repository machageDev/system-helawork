import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  
  void setProfileField(String key, dynamic value) {
    _userProfile[key] = value;
    notifyListeners();
  }

  
  Future<void> saveProfile(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      
      final token = await _secureStorage.read(key: "auth_token");
      final userId = await _secureStorage.read(key: "user_id");

      print('Token: $token'); 
      print('User ID: $userId'); 

      if (token == null || userId == null) {
        _errorMessage = 'You must log in first';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must log in first')),
        );
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.updateUserProfile(_userProfile, token, userId); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? 'Profile saved successfully')),
      );
    } catch (e) {
      print('Error saving profile: $e'); 
      _errorMessage = 'Failed to save profile: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}