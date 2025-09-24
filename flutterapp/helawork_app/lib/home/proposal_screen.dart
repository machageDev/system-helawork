import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/proposal_provider.dart';
import '../widgets/proposal_card.dart';

class ProposalsScreen extends StatelessWidget {
  const ProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProposalProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Proposals")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.proposals.isEmpty
              ? const Center(child: Text("No proposals yet"))
              : ListView.builder(
                  itemCount: provider.proposals.length,
                  itemBuilder: (context, index) {
                    return ProposalCard(proposal: provider.proposals[index]);
                  },
                ),
    );
  }
}
