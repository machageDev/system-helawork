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

  // ADD THIS METHOD TO SUBMIT NEW RATINGS
  Future<void> submitRating({
    required String taskId,
    required String clientId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Prepare rating data
      final ratingData = {
        'taskId': taskId,
        'clientId': clientId, 
        'rating': rating,
        'comment': comment,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Submit to backend - you might need a different endpoint
      await ApiService.postData('/ratings/submit', ratingData);
      print("✅ Rating submitted successfully");
      
    } catch (e) {
      _error = "Failed to submit rating: $e";
      print("❌ Error submitting rating: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}