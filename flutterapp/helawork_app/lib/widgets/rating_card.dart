import 'package:flutter/material.dart';

class RatingCard extends StatelessWidget {
  final Map<String, dynamic> rating;

  const RatingCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text("Task: ${rating['task'] ?? 'N/A'}"),
        subtitle: Text(rating['review'] ?? "No review"),
        trailing: Text("⭐ ${rating['score'] ?? 0}"),
      ),
    );
  }
}
