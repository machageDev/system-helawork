import 'package:flutter/material.dart';
import '../models/proposal.dart';

class ProposalProvider with ChangeNotifier {
  List<Proposal> _proposals = [];
  bool _isLoading = false;
  String? error;

  List<Proposal> get proposals => _proposals;
  bool get isLoading => _isLoading;

  /// ✅ Load proposals (simulate API call)
  Future<void> fetchProposals() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // simulate API call

      // Example mock data (replace with API response later)
      _proposals = [
        Proposal(
          title: "Website Development",
          coverLetter: "I can build your website in Flutter + Django.",
          bidAmount: 15000,
          status: "Pending",
        ),
        Proposal(
          title: "Mobile App UI",
          coverLetter: "I will design a sleek UI for your mobile app.",
          bidAmount: 8000,
          status: "Accepted",
        ),
      ];

      error = null;
    } catch (e) {
      error = "Failed to load proposals: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Add a new proposal (e.g., from form submission)
  Future<void> addProposal(Proposal proposal) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // simulate API call

      _proposals.insert(0, proposal); // add at top of list
      error = null;
    } catch (e) {
      error = "Failed to add proposal: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
