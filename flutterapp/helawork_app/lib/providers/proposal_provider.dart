import 'package:flutter/material.dart';
import '../models/proposal.dart';
import '../services/api_service.dart';

class ProposalProvider with ChangeNotifier {
  List<Proposal> _proposals = [];
  bool _isLoading = false;
  String? error;

  List<Proposal> get proposals => _proposals;
  bool get isLoading => _isLoading;

  
  Future<void> fetchProposals() async {
    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      
      _proposals = await ApiService.fetchProposals();
      print(' Loaded ${_proposals.length} proposals');
    } catch (e) {
      error = "Failed to load proposals: $e";
      print(' Error loading proposals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<void> addProposal(Proposal proposal) async {
  _isLoading = true;
  error = null;
  notifyListeners(); 

  try {
    print(' Sending proposal to API...');
    
    
    final submittedProposal = await ApiService.submitProposal(proposal);
    
    print(' API call successful, adding to local list');
    _proposals.insert(0, submittedProposal);
    error = null;
    
  } catch (e) {
    print(' Error in addProposal: $e');
    error = "Failed to add proposal: $e";
    rethrow; // Important for UI error handling
  } finally {
    _isLoading = false;
    notifyListeners(); 
    print(' Loading state set to false');
  }
}

  
  List<Proposal> getProposalsByFreelancer(int freelancerId) {
    return _proposals.where((p) => p.freelancerId == freelancerId).toList();
  }

  
  List<Proposal> getProposalsByTask(int taskId) {
    return _proposals.where((p) => p.taskId == taskId).toList();
  }
}