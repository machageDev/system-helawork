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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RatingProvider>(context);

    // Fetch only once
    if (!_hasFetched && !provider.isLoading && provider.ratings.isEmpty) {
      _hasFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchRatings();
      });
    }
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubmitRatingScreen(
      taskId: 'task-123',
      clientId: 'client-456', 
      clientName: 'Client Name',
    ),
  ),
);

    return Scaffold(
      appBar: AppBar(title: const Text("My Ratings")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.ratings.isEmpty
              ? const Center(child: Text("No ratings yet"))
              : ListView.builder(
                  itemCount: provider.ratings.length,
                  itemBuilder: (context, index) {
                    return RatingCard(rating: provider.ratings[index]);
                  },
                ),
    );
  }
}