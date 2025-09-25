import 'package:flutter/material.dart';
import '../models/proposal.dart';

class ProposalProvider with ChangeNotifier {
  List<Proposal> _proposals = [];
  bool _isLoading = false;
  String? error;

  List<Proposal> get proposals => _proposals;
  bool get isLoading => _isLoading;

  /// Fetch proposals dynamically (e.g., from API)
  Future<void> fetchProposals() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Replace this with your API call or database fetch
      // Example: _proposals = await ApiService.getProposals();

      _proposals = []; // placeholder
      error = null;
    } catch (e) {
      error = "Failed to load proposals: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new proposal
  Future<void> addProposal(Proposal proposal) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Example API call: await ApiService.submitProposal(proposal);

      // Ensure proposal has a status
      if (proposal.status.isEmpty) {
        proposal.status = "Pending";
      }

      _proposals.insert(0, proposal);
      error = null;
    } catch (e) {
      error = "Failed to add proposal: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
