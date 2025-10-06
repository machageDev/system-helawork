import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/proposal.dart';
import '../providers/proposal_provider.dart';
import '../providers/task_provider.dart';

class ProposalsScreen extends StatefulWidget {
  const ProposalsScreen({super.key});

  @override
  State<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  bool showCreateForm = false;
  final _formKey = GlobalKey<FormState>();
  final _bidAmountController = TextEditingController();
  int? selectedTaskId;
  
  // PDF file for cover letter
  PlatformFile? _selectedCoverLetterPdf;
  bool _isPdfPicked = false;
  bool _isPdfUploading = false;

  @override
  void initState() {
    super.initState();
    print(' ProposalsScreen initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    print(' _loadInitialData started');
    if (!mounted) return;
    
    final proposalProvider = Provider.of<ProposalProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    try {
      print(' Fetching proposals...');
      await proposalProvider.fetchProposals();
      print(' Fetching tasks...');
      await taskProvider.fetchTasksForProposals();
      print(' Initial data loaded successfully');
    } catch (e) {
      print(' Error loading initial data: $e');
    }
  }

  // PDF file picker method for cover letter
  Future<void> _pickCoverLetterPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, 
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedCoverLetterPdf = result.files.single;
          _isPdfPicked = true;
        });
        print(' Cover letter PDF selected: ${_selectedCoverLetterPdf!.name}');
        print(' File size: ${_selectedCoverLetterPdf!.size} bytes');
      } else {
        print(' No PDF file selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No PDF file selected"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print(' Error picking PDF file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting PDF file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Clear selected PDF
  void _clearCoverLetterPdf() {
    setState(() {
      _selectedCoverLetterPdf = null;
      _isPdfPicked = false;
    });
    print(' Cover letter PDF cleared');
  }

  @override
  void dispose() {
    _bidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proposalProvider = Provider.of<ProposalProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposals"),
        actions: [
          IconButton(
            icon: Icon(showCreateForm ? Icons.list : Icons.add),
            onPressed: () {
              setState(() {
                showCreateForm = !showCreateForm;
                if (!showCreateForm) {
                  _resetForm();
                }
              });
            },
          )
        ],
      ),
      body: proposalProvider.isLoading || taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : showCreateForm
              ? _buildCreateForm(proposalProvider, taskProvider)
              : _buildProposalsList(proposalProvider),
    );
  }

  Widget _buildCreateForm(ProposalProvider proposalProvider, TaskProvider taskProvider) {
    if (taskProvider.availableTasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No available tasks",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              "All tasks are currently assigned or approved",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Task Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Select Task",
                  border: OutlineInputBorder(),
                ),
                value: selectedTaskId,
                items: taskProvider.availableTasks
                    .map((task) => DropdownMenuItem<int>(
                          value: task['id'],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task['title'] ?? 'Untitled Task',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (task['employer']?['company_name'] != null)
                                Text(
                                  'Client: ${task['employer']?['company_name']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ))
                    .toList(),
                validator: (val) => val == null ? 'Please select a task' : null,
                onChanged: (val) {
                  setState(() {
                    selectedTaskId = val;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Cover Letter PDF Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cover Letter (PDF)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Upload your cover letter as a PDF document",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _isPdfPicked
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedCoverLetterPdf!.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${(_selectedCoverLetterPdf!.size / 1024).toStringAsFixed(2)} KB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                                  onPressed: _clearCoverLetterPdf,
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _pickCoverLetterPdf,
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Upload Cover Letter PDF"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                    
                    if (!_isPdfPicked)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Required: Upload your cover letter as a PDF file",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bid Amount
              TextFormField(
                controller: _bidAmountController,
                decoration: const InputDecoration(
                  labelText: "Bid Amount",
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a bid amount';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (proposalProvider.isLoading || _isPdfUploading) 
                      ? null 
                      : _submitProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: (proposalProvider.isLoading || _isPdfUploading)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Submit Proposal",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitProposal() async {
    final proposalProvider = Provider.of<ProposalProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    print(' _submitProposal method started');
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      print(' Form validation FAILED');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the form errors"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedTaskId == null) {
      print(' No task selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a task"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isPdfPicked) {
      print(' No cover letter PDF selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your cover letter PDF"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isPdfUploading = true;
      });

      // Get task title
      final task = taskProvider.availableTasks.firstWhere(
        (task) => task['id'] == selectedTaskId,
        orElse: () => {'title': 'Selected Task'}
      );
      final taskTitle = task['title'] ?? 'Selected Task';

      // Create proposal - cover letter is now the PDF file
      final proposal = Proposal(
        taskId: selectedTaskId!,
        freelancerId: 1, // TODO: Get from authentication
        coverLetter: "Cover letter provided as PDF", // Placeholder text
        bidAmount: double.parse(_bidAmountController.text),
        status: "Pending",
        title: taskTitle,
        pdfFileName: _selectedCoverLetterPdf!.name,
        
      );

      print(' Submitting proposal with PDF cover letter...');
      await proposalProvider.addProposal(proposal, pdfFile: _selectedCoverLetterPdf);
      print(' Proposal submitted successfully!');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Proposal submitted successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Reset form and go back to list
      _resetForm();
      setState(() {
        showCreateForm = false;
      });

    } catch (e, stackTrace) {
      print(' ERROR in _submitProposal: $e');
      print(' Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting proposal: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isPdfUploading = false;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _bidAmountController.clear();
    setState(() {
      selectedTaskId = null;
      _selectedCoverLetterPdf = null;
      _isPdfPicked = false;
      _isPdfUploading = false;
    });
  }

  Widget _buildProposalsList(ProposalProvider provider) {
    if (provider.proposals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No proposals yet",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              "Tap the + button to create your first proposal",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => Provider.of<ProposalProvider>(context, listen: false).fetchProposals(),
      child: ListView.builder(
        itemCount: provider.proposals.length,
        itemBuilder: (context, index) {
          final proposal = provider.proposals[index];
          return Card(
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
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Show PDF file name for cover letter
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Cover Letter: ${proposal.pdfFileName ?? 'PDF Document'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bid: \$${proposal.bidAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Status: ${proposal.status}",
                    style: TextStyle(
                      color: proposal.status == "Accepted"
                          ? Colors.green
                          : proposal.status == "Rejected"
                              ? Colors.red
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}