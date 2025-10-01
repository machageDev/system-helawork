import 'package:flutter/material.dart';
import 'package:helawork_app/home/rating_screen.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'task_page.dart';
import 'payment_summary_page.dart';
import 'proposal_screen.dart';
import 'user_profile_screen.dart';
import 'contract_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // Remove UserProfileScreen from pages since we're removing the Account tab
  final List<Widget> _pages = const [
    SizedBox(), // Home page is built separately
    TaskPage(),
    PaymentSummaryPage(),
    ProposalsScreen(),
    // UserProfileScreen removed from navigation
  ];

  @override
  void initState() {
    super.initState();
    // Load dashboard data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ================= MAIN DASHBOARD BODY (Home Tab) =================
  Widget _buildHomePage(DashboardProvider dashboard) {
    if (dashboard.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    if (dashboard.error != null) {
      return Center(
        child: Text(
          dashboard.error!,
          style: TextStyle(color: Colors.red.shade400),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => dashboard.loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(dashboard),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildActiveTasksSection(dashboard),
            const SizedBox(height: 20),
            _buildRatingsSection(),
            const SizedBox(height: 20),
            _buildContractsSection(),
          ],
        ),
      ),
    );
  }

  // ================= USER HEADER =================
  Widget _buildUserHeader(DashboardProvider dashboard) {
    return Row(
      children: [
        // Clickable Profile Picture
        GestureDetector(
          onTap: () {
            // Navigate to UserProfileScreen when profile icon is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 25,
            backgroundImage: dashboard.profilePictureUrl != null && 
                            dashboard.profilePictureUrl!.isNotEmpty
                ? NetworkImage(dashboard.profilePictureUrl!)
                : null,
            backgroundColor: dashboard.profilePictureUrl != null ? 
                            Colors.transparent : Colors.grey[700],
            child: dashboard.profilePictureUrl == null || 
                   dashboard.profilePictureUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 24)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        // User Name
        Text(
          dashboard.userName ?? "Guest User",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
       
      ],
    );
  }

  // ================= QUICK ACTIONS =================
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _onItemTapped(1), // Navigate to Tasks
            icon: const Icon(Icons.task, color: Colors.white),
            label: const Text(
              "Tasks",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= ACTIVE TASKS SECTION =================
  Widget _buildActiveTasksSection(DashboardProvider dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Active Tasks",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _onItemTapped(1), 
              child: const Text(
                "View All",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (dashboard.activeTasks.isEmpty)
          const Text(
            "No active tasks",
            style: TextStyle(color: Colors.grey),
          )
        else
          ...dashboard.activeTasks.map((task) => _buildTaskCard(
                task["title"] ?? "Untitled Task",
                "Due: ${task["deadline"] ?? 'N/A'}",
                task["status"] ?? "Unknown",
              )),
      ],
    );
  }

  // ================= RATINGS SECTION =================
  Widget _buildRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ratings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RatingsScreen()),
            );
          },
          icon: const Icon(Icons.star, color: Colors.white),
          label: const Text(
            "View Ratings",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  // ================= CONTRACTS SECTION =================
  Widget _buildContractsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contracts",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey.shade700,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContractScreen()),
            );
          },
          icon: const Icon(Icons.article, color: Colors.white),
          label: const Text(
            "View Contracts",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  // ================= TASK CARD =================
  Widget _buildTaskCard(String title, String subtitle, String status) {
    Color statusColor = status == "Completed" ? Colors.green : Colors.orangeAccent;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            title: const Text(
              "Dashboard",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => dashboard.loadData(),
              ),
            ],
          ),
          body: _selectedIndex == 0
              ? _buildHomePage(dashboard)
              : _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.grey[900],
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: "Tasks",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment),
                label: "Payments",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: "Proposals",
              ),
              // Account BottomNavigationBarItem removed
            ],
          ),
        );
      },
    );
  }
}