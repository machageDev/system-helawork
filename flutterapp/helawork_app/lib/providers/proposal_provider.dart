import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProposalProvider with ChangeNotifier {
  List<dynamic> _proposals = [];
  bool _isLoading = false;

  List<dynamic> get proposals => _proposals;
  bool get isLoading => _isLoading;

  Future<void> fetchProposals() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getData('proposals');
      _proposals = data;
    } catch (e) {
      print("Error fetching proposals: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}
