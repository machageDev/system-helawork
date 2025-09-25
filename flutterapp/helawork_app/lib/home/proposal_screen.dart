import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/proposal.dart';
import '../providers/proposal_provider.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  bool showCreateForm = false; 
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String coverLetter = '';
  String bidAmount = '';

  @override
  void initState() {
    super.initState();
    Provider.of<ProposalProvider>(context, listen: false).fetchProposals();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProposalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposals"),
        actions: [
          IconButton(
            icon: Icon(showCreateForm ? Icons.list : Icons.add),
            onPressed: () {
              setState(() {
                showCreateForm = !showCreateForm;
              });
            },
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : showCreateForm
              ? _buildCreateForm(provider)
              : _buildProposalsList(provider),
    );
  }

  Widget _buildProposalsList(ProposalProvider provider) {
    if (provider.proposals.isEmpty) {
      return const Center(child: Text("No proposals yet"));
    }
    return ListView.builder(
      itemCount: provider.proposals.length,
      itemBuilder: (context, index) {
        final proposal = provider.proposals[index];
        return Card(
          color: const Color(0xFF1E1E2C),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  proposal.coverLetter,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  "Bid: \$${proposal.bidAmount.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 8),
                Text(
                  "Status: ${proposal.status}",
                  style: TextStyle(
                      color: proposal.status == "Accepted"
                          ? Colors.green
                          : proposal.status == "Rejected"
                              ? Colors.red
                              : Colors.yellow),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateForm(ProposalProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Task Title"),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter a title' : null,
              onChanged: (val) => title = val,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(labelText: "Cover Letter"),
              maxLines: 4,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter cover letter' : null,
              onChanged: (val) => coverLetter = val,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(labelText: "Bid Amount"),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter bid amount' : null,
              onChanged: (val) => bidAmount = val,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final proposal = Proposal(
                            title: title,
                            coverLetter: coverLetter,
                            bidAmount: double.parse(bidAmount),
                          );
                          provider.addProposal(proposal);
                          setState(() {
                            showCreateForm = false; // Back to list
                          });
                        }
                      },
                child: provider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Submit Proposal"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
