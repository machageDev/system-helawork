import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_completion_provider.dart';

class TaskCompletionPage extends StatefulWidget {
  final int taskId;
  
  const TaskCompletionPage({super.key, required this.taskId});

  @override
  State<TaskCompletionPage> createState() => _TaskCompletionPageState();
}

class _TaskCompletionPageState extends State<TaskCompletionPage> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskCompletionProvider>(context, listen: false)
          .loadTaskCompletion(widget.taskId);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ================= MAIN PAGE BODY =================
  Widget _buildPageBody(TaskCompletionProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 50),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: TextStyle(color: Colors.red.shade400, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => provider.loadTaskCompletion(widget.taskId),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadTaskCompletion(widget.taskId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(provider),
            const SizedBox(height: 20),
            _buildCompletionStatus(provider),
            const SizedBox(height: 20),
            _buildSubmissionForm(provider),
            if (provider.completionData != null) ...[
              const SizedBox(height: 20),
              _buildEmployerFeedback(provider),
            ],
          ],
        ),
      ),
    );
  }

  // ================= TASK HEADER =================
  Widget _buildTaskHeader(TaskCompletionProvider provider) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.taskData?['title'] ?? 'Task Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTaskDetailItem('Budget', 
                'Ksh ${provider.taskData?['budget']?.toStringAsFixed(2) ?? '0.00'}'),
            _buildTaskDetailItem('Deadline', 
                provider.taskData?['deadline'] ?? 'Not set'),
            _buildTaskDetailItem('Category', 
                provider.taskData?['category_display'] ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ================= COMPLETION STATUS =================
  Widget _buildCompletionStatus(TaskCompletionProvider provider) {
    final status = provider.completionData?['status'];
    final statusDisplay = provider.completionData?['status_display'] ?? 'Not Submitted';
    
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;
    
    switch (status) {
      case 'submitted':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        break;
      case 'under_review':
        statusColor = Colors.blue;
        statusIcon = Icons.visibility;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'revisions_requested':
        statusColor = Colors.orange;
        statusIcon = Icons.build;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Completion Status',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    statusDisplay,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUBMISSION FORM =================
  Widget _buildSubmissionForm(TaskCompletionProvider provider) {
    final canSubmit = provider.completionData == null;
    final canUpdate = provider.completionData?['can_update'] == true;

    if (!canSubmit && !canUpdate) {
      return const SizedBox(); // Hide form if cannot submit or update
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              canSubmit ? 'Submit Task Completion' : 'Update Submission',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Submission Notes (Optional)',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe your work, include any important notes or links...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: provider.isSubmitting ? null : () {
                  _handleSubmission(provider, canSubmit);
                },
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        canSubmit ? 'Submit Completion' : 'Update Submission',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPLOYER FEEDBACK =================
  Widget _buildEmployerFeedback(TaskCompletionProvider provider) {
    final employerNotes = provider.completionData?['employer_review_notes'];
    final reviewedAt = provider.completionData?['reviewed_at'];
    
    if (employerNotes == null || employerNotes.isEmpty) {
      return const SizedBox();
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.feedback, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Employer Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                employerNotes,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            if (reviewedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reviewed on: $reviewedAt',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= HANDLE SUBMISSION =================
  void _handleSubmission(TaskCompletionProvider provider, bool isNewSubmission) {
    final notes = _notesController.text.trim();
    
    if (isNewSubmission) {
      provider.submitCompletion(widget.taskId, notes).then((success) {
        if (success) {
          _showSuccessDialog('Completion submitted successfully!');
          _notesController.clear();
        } else {
          _showErrorDialog('Failed to submit completion');
        }
      });
    } else {
      provider.updateCompletion(widget.taskId, notes).then((success) {
        if (success) {
          _showSuccessDialog('Submission updated successfully!');
        } else {
          _showErrorDialog('Failed to update submission');
        }
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Success', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<TaskCompletionProvider>(context, listen: false)
                  .loadTaskCompletion(widget.taskId);
            },
            child: const Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskCompletionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.grey[900],
            elevation: 0,
            title: const Text(
              "Task Completion",
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => provider.loadTaskCompletion(widget.taskId),
              ),
            ],
          ),
          body: _buildPageBody(provider),
        );
      },
    );
  }
}