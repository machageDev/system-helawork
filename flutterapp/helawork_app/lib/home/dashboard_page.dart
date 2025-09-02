import 'package:flutter/material.dart';
import 'package:helawork_app/Api/api_service.dart' as ApiService;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String activeSession = "00:00:00";
  double totalEarnings = 0.0;
  List tasks = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    var session = await ApiService.getActiveSession();
    var earnings = await ApiService.getEarnings();
    var fetchedTasks = await ApiService.getTasks();

    setState(() {
      activeSession = session["time"];
      totalEarnings = earnings["amount"];
      tasks = fetchedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Session
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Active Session", style: TextStyle(color: Colors.white70)),
                      Text(activeSession, style: TextStyle(color: Colors.white, fontSize: 28)),
                      Text("Time worked today", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Recent Tasks
              Text("Recent Tasks", style: TextStyle(color: Colors.white, fontSize: 18)),
              Column(
                children: tasks.map((task) {
                  return Card(
                    color: Colors.grey[850],
                    child: ListTile(
                      title: Text(task["title"], style: TextStyle(color: Colors.white)),
                      subtitle: Text("${task["hours"]} hours", style: TextStyle(color: Colors.grey)),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: task["status"] == "Approved"
                              ? Colors.green
                              : task["status"] == "In Progress"
                                  ? Colors.orange
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(task["status"], style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              // Total Earnings
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Total Earnings", style: TextStyle(color: Colors.orange, fontSize: 18)),
                      Text("\$$totalEarnings", style: TextStyle(color: Colors.orange, fontSize: 28)),
                      Text("This month", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
