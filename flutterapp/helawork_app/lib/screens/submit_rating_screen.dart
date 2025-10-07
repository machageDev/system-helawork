import 'package:flutter/material.dart';
import 'package:helawork_app/providers/rating_provider.dart';
import 'package:provider/provider.dart';

class SubmitRatingScreen extends StatefulWidget {
  final String taskId;
  final String employerId;
  final String clientName;
  final int freelancerId;

  const SubmitRatingScreen({
    super.key,
    required this.taskId,
    required this.employerId,
    required this.clientName,
    required this.freelancerId,
  });

  @override
  State<SubmitRatingScreen> createState() => _SubmitRatingScreenState();
}

class _SubmitRatingScreenState extends State<SubmitRatingScreen> {
  final _reviewController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<RatingProvider>(context, listen: false);
      await provider.submitRating(
        taskId: int.parse(widget.taskId),
        freelancerId: widget.freelancerId,
        employerId: int.parse(widget.employerId),
        score: _selectedRating,
        review: _reviewController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
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
            const SizedBox(height: 10),
            Text("$_selectedRating / 5"),
            
            const SizedBox(height: 20),
            
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Review (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              child: _isSubmitting 
                  ? const CircularProgressIndicator()
                  : const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
