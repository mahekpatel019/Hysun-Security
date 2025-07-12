import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final CollectionReference _membersCollection =
      FirebaseFirestore.instance.collection('members');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Complaints',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.green.shade700),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _membersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade600,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No complaints found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          List<Map<String, dynamic>> allComplaints = [];

          for (var doc in snapshot.data!.docs) {
            var memberData = doc.data() as Map<String, dynamic>?;
            var complaints = memberData?['complaints'] as List<dynamic>?;

            if (complaints != null) {
              for (var complaint in complaints) {
                // Add complaints to the list
                allComplaints.add({
                  'name': complaint['name'] ?? 'Anonymous',
                  'complaint': complaint['complaint'] ?? 'No complaint text',
                  'timestamp': (complaint['timestamp'] as Timestamp?)?.toDate(),
                });
              }
            }
          }

          // Sort all complaints by timestamp in descending order
          allComplaints.sort((a, b) {
            DateTime? timeA = a['timestamp'];
            DateTime? timeB = b['timestamp'];
            if (timeA == null || timeB == null) return 0;
            return timeB.compareTo(timeA); // Newest first
          });

          if (allComplaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No complaints found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allComplaints.length,
            itemBuilder: (context, index) {
              var complaintData = allComplaints[index];
              DateTime? timestamp = complaintData['timestamp'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              complaintData['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          if (timestamp != null) ...[
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        complaintData['complaint'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pending', // Make dynamic if complaint status available
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}';
  }
}
