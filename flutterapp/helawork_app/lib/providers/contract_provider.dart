import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/contract_model.dart';

class ContractProvider with ChangeNotifier {
  List<Contract> _contracts = [];
  bool _isLoading = false;

  List<Contract> get contracts => _contracts;
  bool get isLoading => _isLoading;

  Future<void> fetchContracts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse("http://127.0.0.1:8000/api/contracts/")); // Update API URL

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _contracts = data.map((json) => Contract.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load contracts");
      }
    } catch (e) {
      debugPrint("Error fetching contracts: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
