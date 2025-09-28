import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contract_provider.dart';

class ContractScreen extends StatelessWidget {
  const ContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Contracts"),
        backgroundColor: const Color(0xFF007bff), // HelaWork blue
      ),
      body: Consumer<ContractProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF007bff)),
            );
          }

          if (provider.contracts.isEmpty) {
            return const Center(child: Text("No contracts available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.contracts.length,
            itemBuilder: (context, index) {
              final contract = provider.contracts[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    contract.taskTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0056b3), // Darker HelaWork blue
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Employer: ${contract.employerName}"),
                      Text("Start: ${contract.startDate}"),
                      Text("End: ${contract.endDate ?? 'Ongoing'}"),
                    ],
                  ),
                  trailing: Icon(
                    contract.isActive ? Icons.check_circle : Icons.cancel,
                    color: contract.isActive ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<ContractProvider>(context, listen: false).fetchContracts();
        },
        backgroundColor: const Color(0xFF007bff),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
