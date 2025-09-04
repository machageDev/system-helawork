import 'package:flutter/material.dart';
import 'package:helawork_app/Api/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = "User";
  double totalEarnings = 0.0;
  List<dynamic> recentTasks = [];
  bool isDarkTheme = true; // theme state

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = ApiService();

      final profile = await apiService.getUserProfile();
      final payments = await ApiService.getPaymentSummary();
      final tasks = await ApiService.getTasks();
      setState(() {
        userName = profile["name"] ?? "User";
        totalEarnings = payments["total_earnings"]?.toDouble() ?? 0.0;
        recentTasks = tasks;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkTheme ? Colors.black : Colors.white;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final subTextColor = isDarkTheme ? Colors.white70 : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(
              icon: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                setState(() {
                  isDarkTheme = !isDarkTheme;
                });
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text("${_getGreeting()},",
                  style: TextStyle(color: subTextColor, fontSize: 16)),
              Text(userName,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text("View My Balances"),
              ),
              const SizedBox(height: 20),

              // Recent Tasks
              Text("Recent Tasks",
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Column(
                children: recentTasks.map((task) {
                  return _buildTaskCard(
                    task["title"],
                    "${task["hours"]} hours",
                    task["status"],
                    textColor,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Feature Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildFeature(Icons.timer, "Log Hours", textColor),
                  _buildFeature(Icons.assignment, "My Tasks", textColor),
                  _buildFeature(Icons.payment, "Payments", textColor),
                  _buildFeature(Icons.bar_chart, "Reports", textColor),
                  _buildFeature(Icons.card_giftcard, "Rewards", textColor),
                  _buildFeature(Icons.person, "Profile", textColor),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bgColor,
        selectedItemColor: Colors.green,
        unselectedItemColor: subTextColor,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Image.asset("assets/helawork_logo.png", height: 32),
            label: "Helawork",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
      String title, String hours, String status, Color textColor) {
    Color statusColor;
    switch (status) {
      case "Approved":
        statusColor = Colors.green;
        break;
      case "In Progress":
        statusColor = Colors.orange;
        break;
      case "Rejected":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(hours,
                style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: TextStyle(
                    color: statusColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
