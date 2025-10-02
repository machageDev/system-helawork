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
  final _coverLetterController = TextEditingController();
  final _bidAmountController = TextEditingController();
  int? selectedTaskId;
  
  
  PlatformFile? _selectedPdfFile;
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
    if (!mounted) {
      print(' Not mounted, returning early');
      return;
    }
    
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

  // PDF file picker method
  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPdfFile = result.files.single;
          _isPdfPicked = true;
        });
        print('PDF file selected: ${_selectedPdfFile!.name}');
        print('File size: ${_selectedPdfFile!.size} bytes');
        print('File path: ${_selectedPdfFile!.path}');
      } else {
        print('No PDF file selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No PDF file selected"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error picking PDF file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting PDF file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Clear selected PDF
  void _clearPdfFile() {
    setState(() {
      _selectedPdfFile = null;
      _isPdfPicked = false;
    });
    print('PDF file cleared');
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _bidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(' ProposalsScreen build called - showCreateForm: $showCreateForm');
    final proposalProvider = Provider.of<ProposalProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    print(' Provider states - proposalLoading: ${proposalProvider.isLoading}, taskLoading: ${taskProvider.isLoading}');
    print(' Available tasks count: ${taskProvider.availableTasks.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Proposals"),
        actions: [
          IconButton(
            icon: Icon(showCreateForm ? Icons.list : Icons.add),
            onPressed: () {
              print(' Toggle button pressed - current state: $showCreateForm');
              setState(() {
                showCreateForm = !showCreateForm;
                // Reset form when switching back to list
                if (!showCreateForm) {
                  _resetForm();
                }
              });
              print(' Toggle button - new state: $showCreateForm');
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
    print(' _buildCreateForm called');
    print(' Available tasks in form: ${taskProvider.availableTasks.length}');

    if (taskProvider.availableTasks.isEmpty) {
      print(' No available tasks to show');
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
                    .map((task) {
                      print('📝 Dropdown item - id: ${task['id']}, title: ${task['title']}');
                      return DropdownMenuItem<int>(
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
                      );
                    })
                    .toList(),
                validator: (val) => val == null ? 'Please select a task' : null,
                onChanged: (val) {
                  print(' Dropdown changed - selected: $val');
                  setState(() {
                    selectedTaskId = val;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Cover Letter
              TextFormField(
                controller: _coverLetterController,
                decoration: const InputDecoration(
                  labelText: "Proposal / Cover Letter",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (val) {
                  final isValid = val == null || val.isEmpty ? 'Please enter a cover letter' : null;
                  print(' Cover letter validation: ${isValid == null ? 'valid' : 'invalid'}');
                  return isValid;
                },
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
                    print(' Bid amount validation: empty');
                    return 'Please enter a bid amount';
                  }
                  if (double.tryParse(val) == null) {
                    print(' Bid amount validation: not a number');
                    return 'Please enter a valid number';
                  }
                  print(' Bid amount validation: valid');
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // PDF Upload Section
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
                      "Proposal File (PDF)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    const SizedBox(height: 8),
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
                                        _selectedPdfFile!.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${(_selectedPdfFile!.size / 1024).toStringAsFixed(2)} KB',
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
                                  onPressed: _clearPdfFile,
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _pickPdfFile,
                            icon: const Icon(Icons.attach_file),
                            label: const Text("Select PDF File"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                    if (!_isPdfPicked)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Attach your proposal document (PDF only)",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (proposalProvider.isLoading || _isPdfUploading) 
                      ? null 
                      : () {
                          print(' SUBMIT BUTTON PRESSED!');
                          print(' Current state:');
                          print('   - selectedTaskId: $selectedTaskId');
                          print('   - coverLetter length: ${_coverLetterController.text.length}');
                          print('   - bidAmount: ${_bidAmountController.text}');
                          print('   - pdfSelected: $_isPdfPicked');
                          print('   - pdfFileName: ${_selectedPdfFile?.name}');
                          print('   - proposalProvider.isLoading: ${proposalProvider.isLoading}');
                          print('   - _isPdfUploading: $_isPdfUploading');
                          
                          _submitProposal(proposalProvider, taskProvider);
                        },
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

  // Updated submit proposal method
  Future<void> _submitProposal(ProposalProvider proposalProvider, TaskProvider taskProvider) async {
    print(' _submitProposal method started');
    
    print(' Validating form...');
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
    print(' Form validation PASSED');

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
    print(' Task selected: $selectedTaskId');

    if (!_isPdfPicked) {
      print(' No PDF file selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please attach a PDF proposal file"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    print(' PDF file selected: ${_selectedPdfFile!.name}');

    try {
      setState(() {
        _isPdfUploading = true;
      });

      print(' Getting task title...');
      // Get task title safely
      final task = taskProvider.availableTasks.firstWhere(
        (task) => task['id'] == selectedTaskId,
        orElse: () => {'title': 'Selected Task'}
      );
      final taskTitle = task['title'] ?? 'Selected Task';
      print(' Task title: $taskTitle');

      // Create proposal with PDF file information
      print(' Creating proposal object...');
      final proposal = Proposal(
        taskId: selectedTaskId!,
        freelancerId: 1, // TODO: Get from authentication
        coverLetter: _coverLetterController.text,
        bidAmount: double.parse(_bidAmountController.text),
        status: "Pending",
        title: taskTitle,
        pdfFileName: _selectedPdfFile!.name,
        pdfFilePath: _selectedPdfFile!.path,
      );
      print(' Proposal object created: ${proposal.toJson()}');

      // Submit proposal with PDF file
      print(' Calling proposalProvider.addProposal with PDF...');
      await proposalProvider.addProposal(proposal, pdfFile: _selectedPdfFile);
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
      print(' Form reset and navigation complete');

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
    print(' Resetting form...');
    _formKey.currentState?.reset();
    _coverLetterController.clear();
    _bidAmountController.clear();
    setState(() {
      selectedTaskId = null;
      _selectedPdfFile = null;
      _isPdfPicked = false;
      _isPdfUploading = false;
    });
    print(' Form reset complete');
  }

  Widget _buildProposalsList(ProposalProvider provider) {
    print(' _buildProposalsList called - proposal count: ${provider.proposals.length}');
    
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
                  Text(proposal.coverLetter),
                  const SizedBox(height: 8),
                  Text(
                    "Bid: \$${proposal.bidAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Show PDF file name if available
                  if (proposal.pdfFileName != null)
                    Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Attachment: ${proposal.pdfFileName}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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