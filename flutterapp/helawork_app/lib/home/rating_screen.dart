import 'package:flutter/material.dart';
import 'package:helawork_app/providers/rating_provider.dart';
import 'package:helawork_app/screens/submit_rating_screen.dart';
import 'package:helawork_app/widgets/rating_card.dart';
import 'package:provider/provider.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    _hasFetched = false;
  }

  void _navigateToSubmitRating() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitRatingScreen(
          taskId: 'task-123', // Replace with actual task ID
          employerId: 'employer-456', // Replace with actual employer ID
          clientName: 'Client Name', // Replace with actual client name
          freelancerId: 123, // You need to get this from somewhere
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RatingProvider>(context);

    if (!_hasFetched && !provider.isLoading && provider.ratings.isEmpty) {
      _hasFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchMyRatings();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Ratings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToSubmitRating,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.ratings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("No ratings yet"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _navigateToSubmitRating,
                        child: const Text("Submit Your First Rating"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.ratings.length,
                  itemBuilder: (context, index) {
                    return RatingCard(rating: provider.ratings[index]);
                  },
                ),
    );
  }
}