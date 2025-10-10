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

  final List<Widget> _pages = const [
    SizedBox(), 
    TaskPage(),
    PaymentSummaryPage(),
    ProposalsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
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
            _buildNotificationsSection(dashboard),
            const SizedBox(height: 20),
            _buildStatsCards(dashboard),
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
    final notificationCount = _getNotificationCount(dashboard);
    
    return Row(
      children: [
        GestureDetector(
          onTap: () {
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
        Text(
          dashboard.userName ?? "Guest User",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Notification badge with count
        Stack(
          children: [
            IconButton(
              icon: Icon(
                notificationCount > 0 ? Icons.notifications : Icons.notifications_none,
                color: Colors.white,
              ),
              onPressed: () => _showNotifications(dashboard),
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ================= NOTIFICATIONS SECTION =================
  Widget _buildNotificationsSection(DashboardProvider dashboard) {
    final notifications = _generateNotifications(dashboard);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Notifications",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (notifications.isNotEmpty)
              TextButton(
                onPressed: () => _showNotifications(dashboard),
                child: const Text(
                  "View All",
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        
        if (notifications.isEmpty)
          _buildEmptyNotificationCard()
        else
          Column(
            children: notifications.take(3).map((notification) => 
              _buildNotificationCard(notification, dashboard)
            ).toList(),
          ),
      ],
    );
  }

  // ================= STATS CARDS =================
  Widget _buildStatsCards(DashboardProvider dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Overview",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              "Active Tasks",
              dashboard.activeTasks.length.toString(),
              Icons.task,
              Colors.green,
            ),
            _buildStatCard(
              "Total Tasks",
              dashboard.totalTasks.toString(),
              Icons.assignment,
              Colors.blue,
            ),
            _buildStatCard(
              "In Progress",
              dashboard.ongoingTasks.toString(),
              Icons.timelapse,
              Colors.orange,
            ),
            _buildStatCard(
              "Completed",
              dashboard.completedTasks.toString(),
              Icons.check_circle,
              Colors.purple,
            ),
          ],
        ),
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
            onPressed: () => _onItemTapped(1),
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
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _onItemTapped(3),
            icon: const Icon(Icons.article, color: Colors.white),
            label: const Text(
              "Proposals",
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

  // ================= RATINGS SECTION =================
  Widget _buildRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ratings & Reviews",
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

  // ================= NOTIFICATION METHODS =================

  // Generate notifications based on dashboard data
  List<Map<String, dynamic>> _generateNotifications(DashboardProvider dashboard) {
    final notifications = <Map<String, dynamic>>[];
    
    // New proposals notification
    if (dashboard.pendingProposals > 0) {
      notifications.add({
        'type': 'proposal',
        'title': 'New Proposals',
        'message': 'You have ${dashboard.pendingProposals} new proposal(s) waiting for review',
        'icon': Icons.person_add,
        'color': Colors.orange,
        'action': () => _onItemTapped(3), // Navigate to proposals
      });
    }

    // Active tasks notification
    if (dashboard.activeTasks.isNotEmpty) {
      notifications.add({
        'type': 'active_tasks',
        'title': 'Active Tasks',
        'message': 'You have ${dashboard.activeTasks.length} active task(s)',
        'icon': Icons.task,
        'color': Colors.green,
        'action': () => _onItemTapped(1), // Navigate to tasks
      });
    }

    // Tasks in progress notification
    if (dashboard.ongoingTasks > 0) {
      notifications.add({
        'type': 'in_progress',
        'title': 'Tasks in Progress',
        'message': '${dashboard.ongoingTasks} task(s) are currently being worked on',
        'icon': Icons.timelapse,
        'color': Colors.blue,
        'action': () => _onItemTapped(1), // Navigate to tasks
      });
    }

    // Completed tasks notification
    if (dashboard.completedTasks > 0) {
      notifications.add({
        'type': 'completed',
        'title': 'Completed Tasks',
        'message': '${dashboard.completedTasks} task(s) have been completed',
        'icon': Icons.check_circle,
        'color': Colors.purple,
        'action': () => _onItemTapped(1), // Navigate to tasks
      });
    }

    return notifications;
  }

  // Get total notification count
  int _getNotificationCount(DashboardProvider dashboard) {
    return _generateNotifications(dashboard).length;
  }

  // Build notification card
  Widget _buildNotificationCard(Map<String, dynamic> notification, DashboardProvider dashboard) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification['color'] as Color,
          child: Icon(
            notification['icon'] as IconData,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'] as String,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          notification['message'] as String,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {
          final action = notification['action'] as Function?;
          if (action != null) {
            action();
          }
        },
      ),
    );
  }

  // Build empty notification card
  Widget _buildEmptyNotificationCard() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.notifications_off, color: Colors.grey, size: 40),
            SizedBox(height: 10),
            Text(
              "No New Notifications",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              "You're all caught up!",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Show notifications dialog
  void _showNotifications(DashboardProvider dashboard) {
    final notifications = _generateNotifications(dashboard);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "All Notifications",
          style: TextStyle(color: Colors.white),
        ),
        content: notifications.isEmpty
            ? const Text(
                "No new notifications",
                style: TextStyle(color: Colors.grey),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification, dashboard);
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // Build stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
            ],
          ),
        );
      },
    );
  }
}