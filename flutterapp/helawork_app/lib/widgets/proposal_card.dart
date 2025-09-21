import 'package:flutter/material.dart';

class ProposalCard extends StatelessWidget {
  final Map<String, dynamic> proposal;

  const ProposalCard({super.key, required this.proposal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(proposal['title'] ?? "No title"),
        subtitle: Text(proposal['description'] ?? "No description"),
        trailing: Text("Status: ${proposal['status'] ?? 'Pending'}"),
      ),
    );
  }
}
