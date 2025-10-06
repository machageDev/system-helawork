import 'package:flutter/material.dart';
import 'package:helawork_app/providers/rating_provider.dart';
import 'package:provider/provider.dart';

class SubmitRatingScreen extends StatefulWidget {
  final String taskId;
  final String clientId;
  final String clientName;

  const SubmitRatingScreen({
    super.key,
    required this.taskId,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<SubmitRatingScreen> createState() => _SubmitRatingScreenState();
}

class _SubmitRatingScreenState extends State<SubmitRatingScreen> {
  final _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rate ${widget.clientName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "How was your experience with ${widget.clientName}?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            SizedBox(height: 10),
            Text("$_selectedRating / 5"),
            
            SizedBox(height: 20),
            
            // Comment
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comments (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            
            SizedBox(height: 30),
            
            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              child: _isSubmitting 
                  ? CircularProgressIndicator()
                  : Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<RatingProvider>(context, listen: false);
      await provider.submitRating(
        taskId: widget.taskId,
        clientId: widget.clientId,
        rating: _selectedRating,
        comment: _commentController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rating submitted successfully!')),
      );
      
      Navigator.pop(context); // Go back after submission
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}