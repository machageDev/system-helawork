import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contract_provider.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    _hasFetched = false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContractProvider>(context);

    if (!_hasFetched && !provider.isLoading && provider.contracts.isEmpty) {
      _hasFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchContracts();
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "My Contracts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF007b),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF007b),
              ),
            )
          : provider.contracts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No contracts available",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          provider.fetchContracts();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007b),
                        ),
                        child: const Text(
                          "Refresh",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
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
                            fontSize: 18,
                            color: Color(0xFF0056b3),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              "Employer: ${contract.employerName}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Start: ${contract.startDate}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "End: ${contract.endDate ?? 'Ongoing'}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          contract.isActive ? Icons.check_circle : Icons.cancel,
                          color: contract.isActive ? Colors.green : Colors.red,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.fetchContracts();
        },
        backgroundColor: const Color(0xFF007bff),
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}