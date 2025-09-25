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
  String coverLetter = '';
  String bidAmount = '';
  int? selectedTaskId;

  // TODO: Replace with dynamic task fetch from API
  final List<Map<String, dynamic>> tasks = [
    {"id": 1, "title": "Website Development"},
    {"id": 2, "title": "Mobile App UI"},
    {"id": 3, "title": "Logo Design"},
    {"id": 4, "title": "Backend API Integration"},
  ];

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
                if (proposal.title != null)
                  Text(
                    proposal.title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                            : Colors.yellow,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateForm(ProposalProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Task Dropdown
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Select Task"),
              value: selectedTaskId,
              items: tasks
                  .map((task) => DropdownMenuItem<int>(
                        value: task['id'],
                        child: Text(task['title']),
                      ))
                  .toList(),
              validator: (val) => val == null ? 'Select a task' : null,
              onChanged: (val) => setState(() {
                selectedTaskId = val;
              }),
            ),
            const SizedBox(height: 10),

            // Cover Letter
            TextFormField(
              decoration: const InputDecoration(labelText: "Proposal / Cover Letter"),
              maxLines: 4,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter cover letter' : null,
              onChanged: (val) => coverLetter = val,
            ),
            const SizedBox(height: 10),

            // Bid Amount
            TextFormField(
              decoration: const InputDecoration(labelText: "Bid Amount"),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter bid amount' : null,
              onChanged: (val) => bidAmount = val,
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() &&
                            selectedTaskId != null) {
                          try {
                            final proposal = Proposal(
                              taskId: selectedTaskId!,
                              freelancerId: 1, // replace with current user ID
                              coverLetter: coverLetter,
                              bidAmount: double.parse(bidAmount),
                            );

                            await provider.addProposal(proposal);

                            setState(() {
                              showCreateForm = false;
                              selectedTaskId = null;
                              coverLetter = '';
                              bidAmount = '';
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        }
                      },
                child: provider.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Submit Proposal"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
