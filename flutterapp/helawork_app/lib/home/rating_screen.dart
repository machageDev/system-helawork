import 'package:flutter/material.dart';
import 'package:helawork_app/providers/rating_provider.dart';
import 'package:helawork_app/widgets/rating_card.dart';
import 'package:provider/provider.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RatingProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.ratings.isEmpty && !provider.isLoading) {
        provider.fetchRatings();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("My Ratings")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text("Error: ${provider.error!}"))
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