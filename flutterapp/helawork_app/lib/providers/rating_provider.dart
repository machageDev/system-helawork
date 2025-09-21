import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RatingProvider with ChangeNotifier {
  List<dynamic> _ratings = [];
  bool _isLoading = false;

  List<dynamic> get ratings => _ratings;
  bool get isLoading => _isLoading;

  Future<void> fetchRatings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getData('/ratings/');
      _ratings = data;
    } catch (e) {
      print("Error fetching ratings: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}
