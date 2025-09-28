import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      if (response["success"] == true) {
        _isLoggedIn = true;
        _userData = response["data"]; // Save user data
      } else {
        _isLoggedIn = false;
        _userData = null;
      }

      return response;
    } catch (e) {
      _isLoggedIn = false;
      _userData = null;
      return {"success": false, "message": "Something went wrong"};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
    String confirmPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name,
        email,
        phone,
        password,
        confirmPassword,
      );
      return response;
    } catch (e) {
      return {"success": false, "message": "Something went wrong"};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _userData = null;
    notifyListeners();
  }
}
