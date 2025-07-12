import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final Color primaryGreen;

  const EmptyStateWidget({
    super.key,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 80,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Members Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add new members to get started',
            style: TextStyle(
              fontSize: 16,
              color: primaryGreen.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}