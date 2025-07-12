import 'package:flutter/material.dart';

class MemberDetailsCard extends StatelessWidget {
  final Map<String, dynamic> member;
  const MemberDetailsCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Member Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.person, 'Name', member['name'] ?? 'N/A'),
            const SizedBox(height: 10),
            _buildDetailRow(
                Icons.home, 'House Number', member['houseNumber'] ?? 'N/A'),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.phone, 'Number', member['number'] ?? 'N/A'),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.email, "Email", member['email'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
