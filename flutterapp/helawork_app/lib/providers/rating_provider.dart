import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';

class RatingProvider with ChangeNotifier {
  List<dynamic> _ratings = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get ratings => _ratings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRatings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await ApiService.getData('/ratings/');
      _ratings = data;
      print("✅ Loaded ${_ratings.length} ratings");
    } catch (e) {
      _error = "Failed to load ratings: $e";
      print("❌ Error fetching ratings: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }
}