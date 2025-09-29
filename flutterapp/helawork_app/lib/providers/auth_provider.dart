import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../providers/dashboard_provider.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;

  Future<Map<String, dynamic>> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);

      if (response["success"] == true) {
        _isLoggedIn = true;
        _userData = response["data"];
        _token = response["data"]["token"];

        // ✅ FIX: Save BOTH token AND user_id to secure storage
        await _secureStorage.write(key: "auth_token", value: _token);
        await _secureStorage.write(
          key: "user_id", 
          value: _userData?['id']?.toString() ?? _userData?['user_id']?.toString()
        );

        // Debug print to verify
        debugPrint('Saved token: $_token');
        debugPrint('Saved user ID: ${_userData?['id'] ?? _userData?['user_id']}');

        // ✅ Update dashboard with logged in user info
        if (context.mounted) {
          final dashboardProvider =
              Provider.of<DashboardProvider>(context, listen: false);

          dashboardProvider.updateUserProfile(
            _userData?['name'] ?? "User",
            _userData?['profile_picture'] ?? "",
          );
        }
      } else {
        _isLoggedIn = false;
        _userData = null;
        _token = null;
        await _secureStorage.delete(key: "auth_token");
        await _secureStorage.delete(key: "user_id"); // Also clear user_id
      }

      return response;
    } catch (e) {
      debugPrint("Login error: $e");
      _isLoggedIn = false;
      _userData = null;
      _token = null;
      await _secureStorage.delete(key: "auth_token");
      await _secureStorage.delete(key: "user_id");
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
      debugPrint("Register error: $e");
      return {"success": false, "message": "Something went wrong"};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() async {
    _isLoggedIn = false;
    _userData = null;
    _token = null;
    // ✅ Clear both token and user_id on logout
    await _secureStorage.delete(key: "auth_token");
    await _secureStorage.delete(key: "user_id");
    notifyListeners();
  }

  // ✅ Add method to check if user data exists in secure storage
  Future<void> checkLoginStatus() async {
    final token = await _secureStorage.read(key: "auth_token");
    final userId = await _secureStorage.read(key: "user_id");
    
    if (token != null && userId != null) {
      _isLoggedIn = true;
      _token = token;
      // You might want to fetch user data here if needed
    } else {
      _isLoggedIn = false;
      _token = null;
      _userData = null;
    }
    notifyListeners();
  }
}