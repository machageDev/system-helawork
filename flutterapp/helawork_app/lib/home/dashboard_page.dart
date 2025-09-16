import 'package:flutter/material.dart';
import 'package:helawork_app/Api/api_service.dart';
import 'package:helawork_app/home/payment_summary_page.dart';
import 'package:helawork_app/home/user_profile_screen.dart';
import 'package:helawork_app/home/task_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = "";
  int inProgress = 0;
  int completed = 0;
  double totalPayments = 0.0;
  List<Map<String, dynamic>> activeTasks = [];
  List<Map<String, dynamic>> recentPayments = [];

  int _selectedIndex = 0;

  final Color bgColor = Colors.black87;
  final Color cardColor = Colors.grey.shade900;
  final Color subTextColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = ApiService();

      final profile = await apiService.getUserProfile();
      final tasksRaw = await ApiService.getTasks();
      final paymentsRaw = await ApiService.getPaymentSummary();

      final tasks = List<Map<String, dynamic>>.from(tasksRaw);
      final payments = Map<String, dynamic>.from(paymentsRaw);

      setState(() {
        userName = profile["name"] ?? "User";

        inProgress = tasks.where((t) => t["status"] == "In Progress").length;
        completed = tasks.where((t) => t["status"] == "Completed").length;
        totalPayments = payments["total_earnings"]?.toDouble() ?? 0.0;

        activeTasks = tasks.take(3).toList();
        recentPayments = List<Map<String, dynamic>>.from(payments["recent"] ?? []);
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentSummaryPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Hi, $userName 👋",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard("In Progress", "$inProgress", Icons.work, Colors.orange),
                  _buildStatCard("Completed", "$completed", Icons.check_circle, Colors.green),
                  _buildStatCard("Payments", "Ksh $totalPayments", Icons.payment, Colors.blue),
                ],
              ),
              const SizedBox(height: 20),

              // Active Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Active Tasks",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TaskPage()),
                      );
                    },
                    child: const Text("View All", style: TextStyle(color: Colors.green)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              if (activeTasks.isEmpty)
                const Text("No active tasks", style: TextStyle(color: Colors.grey))
              else
                ...activeTasks.map((task) => _buildTaskCard(
                      task["title"] ?? "Untitled Task",
                      "Due: ${task["deadline"] ?? 'N/A'}",
                      task["status"] ?? "Unknown",
                    )),
              const SizedBox(height: 20),

              // Recent Payments Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Payments",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentSummaryPage()),
                      );
                    },
                    child: const Text("View All", style: TextStyle(color: Colors.green)),
                  )
                ],
              ),
              const SizedBox(height: 10),
              if (recentPayments.isEmpty)
                const Text("No recent payments", style: TextStyle(color: Colors.grey))
              else
                ...recentPayments.map((p) => _buildPaymentRow(
                      p["task"] ?? "Unknown Task",
                      "Ksh ${p["amount"] ?? 0}",
                      p["date"] ?? "N/A",
                      p["status"] ?? "Pending",
                    )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: bgColor,
        selectedItemColor: Colors.green,
        unselectedItemColor: subTextColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "Payments"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String deadline, String status) {
    Color statusColor;
    switch (status) {
      case "In Progress":
        statusColor = Colors.orange;
        break;
      case "Completed":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(deadline, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String task, String amount, String date, String status) {
    Color statusColor = status == "Paid" ? Colors.green : Colors.orange;
    return ListTile(
      tileColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(task, style: const TextStyle(color: Colors.white)),
      subtitle: Text(date, style: const TextStyle(color: Colors.grey)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
