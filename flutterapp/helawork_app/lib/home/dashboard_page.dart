import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'payment_summary_page.dart';
import 'task_page.dart';
import 'user_profile_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DashboardProvider>(context, listen: false).loadData());
  }

  void _onItemTapped(BuildContext context, int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TaskPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PaymentSummaryPage()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const UserProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Hi, ${provider.userName} 👋",
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
                      MaterialPageRoute(
                          builder: (_) => const UserProfileScreen()));
                },
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.green))
              : provider.error != null
                  ? Center(
                      child: Text(provider.error!,
                          style: const TextStyle(color: Colors.red)))
                  : RefreshIndicator(
                      onRefresh: provider.loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ================= STATS =================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCard("In Progress",
                                    "${provider.inProgress}", Icons.work, Colors.orange),
                                _buildStatCard("Completed",
                                    "${provider.completed}", Icons.check_circle, Colors.green),
                                _buildStatCard(
                                    "Payments",
                                    "Ksh ${provider.totalPayments}",
                                    Icons.payment,
                                    Colors.blue),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ================= ACTIVE TASKS =================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Active Tasks",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const TaskPage()));
                                  },
                                  child: const Text("View All",
                                      style: TextStyle(color: Colors.green)),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (provider.activeTasks.isEmpty)
                              const Text("No active tasks",
                                  style: TextStyle(color: Colors.grey))
                            else
                              ...provider.activeTasks.map((task) => _buildTaskCard(
                                    task["title"] ?? "Untitled Task",
                                    "Due: ${task["deadline"] ?? 'N/A'}",
                                    task["status"] ?? "Unknown",
                                  )),
                            const SizedBox(height: 20),

                            // ================= RECENT PAYMENTS =================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Recent Payments",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const PaymentSummaryPage()));
                                  },
                                  child: const Text("View All",
                                      style: TextStyle(color: Colors.green)),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (provider.recentPayments.isEmpty)
                              const Text("No recent payments",
                                  style: TextStyle(color: Colors.grey))
                            else
                              ...provider.recentPayments.map((p) => _buildPaymentRow(
                                    p["task"] ?? "Unknown Task",
                                    "Ksh ${p["amount"] ?? 0}",
                                    p["date"] ?? "N/A",
                                    p["status"] ?? "Pending",
                                  )),

                            // ================= PROPOSALS =================
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Proposals",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Navigate to ProposalsPage
                                  },
                                  child: const Text("View All",
                                      style: TextStyle(color: Colors.green)),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (provider.proposals.isEmpty)
                              const Text("No proposals yet",
                                  style: TextStyle(color: Colors.grey))
                            else
                              ...provider.proposals.map((proposal) =>
                                  _buildProposalCard(
                                    proposal["jobTitle"] ?? "Untitled Job",
                                    proposal["status"] ?? "Pending",
                                    proposal["date"] ?? "N/A",
                                  )),

                            // ================= RATINGS =================
                            const SizedBox(height: 20),
                            const Text("Employer Ratings",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            if (provider.ratings.isEmpty)
                              const Text("No ratings yet",
                                  style: TextStyle(color: Colors.grey))
                            else
                              ...provider.ratings.map((r) => _buildRatingCard(
                                    r["employer"] ?? "Unknown Employer",
                                    r["score"] ?? 0,
                                    r["review"] ?? "No review",
                                    r["date"] ?? "N/A",
                                  )),
                          ],
                        ),
                      ),
                    ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => _onItemTapped(context, index),
            backgroundColor: Colors.black87,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
              BottomNavigationBarItem(icon: Icon(Icons.money), label: "Payments"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
            ],
          ),
        );
      },
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
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
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(deadline,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: statusColor, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
      String task, String amount, String date, String status) {
    Color statusColor = status == "Paid" ? Colors.green : Colors.orange;
    return ListTile(
      tileColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(task, style: const TextStyle(color: Colors.white)),
      subtitle: Text(date, style: const TextStyle(color: Colors.grey)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(status,
              style:
                  TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProposalCard(String jobTitle, String status, String date) {
    Color statusColor = status == "Accepted"
        ? Colors.green
        : status == "Rejected"
            ? Colors.red
            : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(jobTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text("Applied on: $date",
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: statusColor, borderRadius: BorderRadius.circular(8)),
            child: Text(status,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildRatingCard(
      String employer, int score, String review, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(employer,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(Icons.star,
                        color: i < score ? Colors.green : Colors.grey,
                        size: 18)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(review,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(date,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
