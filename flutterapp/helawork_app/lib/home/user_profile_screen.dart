import 'package:flutter/material.dart';
import 'package:helawork_app/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<UserProfileProvider>(context, listen: false).loadUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          "User Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : profileProvider.errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    profileProvider.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF1E1E2C),
                        backgroundImage: profileProvider.userProfile?['profilePicture'] != null
                            ? NetworkImage(profileProvider.userProfile!['profilePicture'])
                            : null,
                        child: profileProvider.userProfile?['profilePicture'] == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // User ID
                      _buildProfileItem(
                        "User ID",
                        profileProvider.userProfile?['user_id']?.toString() ?? "N/A",
                      ),
                      const SizedBox(height: 15),

                      // Bio
                      _buildProfileItem(
                        "Bio",
                        profileProvider.userProfile?['bio'] ?? "No bio yet",
                      ),
                      const SizedBox(height: 25),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => profileProvider.updateProfile(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Update Profile",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Refresh Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: profileProvider.loadUserProfile,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Refresh Profile"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
