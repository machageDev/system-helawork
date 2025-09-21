import 'package:flutter/material.dart';
import 'package:helawork_app/providers/rating_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/rating_card.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RatingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Ratings")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.ratings.length,
              itemBuilder: (context, index) {
                return RatingCard(rating: provider.ratings[index]);
              },
            ),
    );
  }
}
