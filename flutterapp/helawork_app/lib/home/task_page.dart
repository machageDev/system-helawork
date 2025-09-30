import 'package:flutter/material.dart';
import 'package:helawork_app/providers/task_provider.dart';
import 'package:provider/provider.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TaskProvider>(context, listen: false).fetchTasks(context));
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Tasks'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskProvider.tasks.isEmpty
              ? Center(
                  child: Text(
                    taskProvider.errorMessage.isNotEmpty
                        ? taskProvider.errorMessage
                        : 'No tasks available',
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    final employer = task['employer'] ?? {};
                    
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Task Title and Status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task['title'] ?? 'Untitled Task',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                _buildTaskStatus(task),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Task Description
                            Text(
                              task['description'] ?? '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Client Information
                            _buildClientSection(employer),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildClientSection(Map<String, dynamic> employer) {
    final companyName = employer['company_name'];
    final username = employer['username'];
    final profilePic = employer['profile_picture'];
    
    String displayName = companyName ?? username ?? 'Client';
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Client Avatar
          _buildClientAvatar(profilePic, displayName),
          const SizedBox(width: 12),
          
          // Client Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posted by:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (employer['contact_email'] != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.email, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        employer['contact_email'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientAvatar(String? profilePic, String displayName) {
    if (profilePic != null && profilePic.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(profilePic),
        radius: 20,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        radius: 20,
        child: Text(
          displayName[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }
  }

  Widget _buildTaskStatus(Map<String, dynamic> task) {
    final isApproved = task['is_approved'] ?? false;
    final isAssigned = task['assigned_user'] != null;
    
    Color statusColor = Colors.orange;
    String statusText = 'Available';
    IconData statusIcon = Icons.access_time;
    
    if (isAssigned && !isApproved) {
      statusColor = Colors.blue;
      statusText = 'Assigned';
      statusIcon = Icons.person;
    } else if (isApproved) {
      statusColor = Colors.green;
      statusText = 'Approved';
      statusIcon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}