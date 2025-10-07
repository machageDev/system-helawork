import 'package:flutter/material.dart';
import 'package:helawork_app/services/api_service.dart';

class RatingProvider with ChangeNotifier {
  List<dynamic> _ratings = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get ratings => _ratings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyRatings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final data = await ApiService.getData('/my_employer_ratings/');
      _ratings = data;
      print("✅ Loaded ${_ratings.length} ratings");
    } catch (e) {
      _error = "Failed to load ratings: $e";
      print("❌ Error fetching ratings: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitRating({
    required int taskId,
    required int freelancerId,
    required int employerId,
    required int score,
    required String review,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await ApiService.submitRating(
        taskId: taskId,
        freelancerId: freelancerId,
        employerId: employerId,
        score: score,
        review: review,
      );
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