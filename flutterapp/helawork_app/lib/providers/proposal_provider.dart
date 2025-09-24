import 'package:flutter/material.dart';
import '../models/proposal.dart';

class ProposalProvider with ChangeNotifier {
  List<Proposal> _proposals = [];
  bool _isLoading = false;

  var error;

  List<Proposal> get proposals => _proposals;
  bool get isLoading => _isLoading;

  Future<void> addProposal(Proposal proposal) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // simulate API

    _proposals.insert(0, proposal);
    _isLoading = false;
    notifyListeners();
  }
}
