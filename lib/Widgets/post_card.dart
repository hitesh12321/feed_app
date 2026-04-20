import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 20, // Heavy shadow - GPU test ke liye
              spreadRadius: 5,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Post Title'),
                  SizedBox(height: 8),
                  Text(
                    'This is a sample post description to test GPU performance.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
