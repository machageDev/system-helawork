import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'task_page.dart';
import 'payment_summary_page.dart';
import 'proposal_screen.dart';
import 'user_profile_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SizedBox(), // Home will be built dynamically
    const TaskPage(),
    const PaymentSummaryPage(),
    const ProposalsScreen(),
    const UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<DashboardProvider>(context, listen: false).loadData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ================= MAIN DASHBOARD BODY (Home Tab) =================
  Widget _buildHomePage() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        if (dashboard.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }

        if (dashboard.error != null) {
          return Center(
              child: Text(dashboard.error!,
                  style: TextStyle(color: Colors.red.shade400)));
        }

        return RefreshIndicator(
          onRefresh: dashboard.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= ACTIVE TASKS ONLY =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Active Tasks",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => _onItemTapped(1), // Jump to Tasks tab
                      child: const Text("View All",
                          style: TextStyle(color: Colors.green)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                if (dashboard.activeTasks.isEmpty)
                  const Text("No active tasks",
                      style: TextStyle(color: Colors.grey))
                else
                  ...dashboard.activeTasks.map((task) => _buildTaskCard(
                        task["title"] ?? "Untitled Task",
                        "Due: ${task["deadline"] ?? 'N/A'}",
                        task["status"] ?? "Unknown",
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= CARD WIDGETS =================
  Widget _buildTaskCard(String title, String subtitle, String status) {
    Color statusColor =
        status == "Completed" ? Colors.green : Colors.orangeAccent;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        trailing: Text(status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.grey[900],
            elevation: 0,
            title: Text("Welcome, ${dashboard.userName}",
                style: const TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: dashboard.loadData,
              ),
            ],
          ),
          body: _selectedIndex == 0 ? _buildHomePage() : _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.grey[900],
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.payment), label: "Payments"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.article), label: "Proposals"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Account"),
            ],
          ),
        );
      },
    );
  }
}