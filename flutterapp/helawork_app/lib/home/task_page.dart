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
        title: const Text('My Tasks'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskProvider.tasks.isEmpty
              ? Center(
                  child: Text(
                    taskProvider.errorMessage.isNotEmpty
                        ? taskProvider.errorMessage
                        : 'No tasks assigned',
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(task['title'] ?? 'Untitled Task'),
                        subtitle: Text(task['description'] ?? ''),
                        trailing: task['completed'] == true
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.pending, color: Colors.orange),
                        onTap: () {
                          // TODO: Show task details
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
