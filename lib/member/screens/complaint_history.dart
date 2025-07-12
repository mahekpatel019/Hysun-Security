import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintsHistoryScreen extends StatefulWidget {
  const ComplaintsHistoryScreen({super.key});

  @override
  State<ComplaintsHistoryScreen> createState() =>
      _ComplaintsHistoryScreenState();
}

class _ComplaintsHistoryScreenState extends State<ComplaintsHistoryScreen> {
  final CollectionReference _membersCollection =
      FirebaseFirestore.instance.collection('members');
  String? memberId;

  @override
  void initState() {
    super.initState();
    loadMemberId();
  }

  Future<void> loadMemberId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        memberId = prefs.getString('userId');
      });
    } catch (e) {
      debugPrint('Error loading member ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaints History',
          style: TextStyle(color: Colors.green.shade700),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.green.shade700),
      ),
      body: memberId == null
          ? Center(
              child: CircularProgressIndicator(color: Colors.green.shade600))
          : FutureBuilder<DocumentSnapshot>(
              future: _membersCollection.doc(memberId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.green.shade600,
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.data() == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 60,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No complaints history',
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

                var complaints = (snapshot.data!.data()
                    as Map<String, dynamic>)['complaints'] as List<dynamic>?;

                if (complaints == null || complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 60,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No complaints history',
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

                // Reverse the complaints list to show the latest first
                complaints = complaints.reversed.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    var complaint = complaints![index] as Map<String, dynamic>;
                    DateTime? timestamp =
                        (complaint['timestamp'] as Timestamp?)?.toDate();

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
                                Text(
                                  complaint['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  timestamp != null
                                      ? _formatDate(timestamp)
                                      : 'No date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              complaint['complaint'] ?? 'No complaint provided',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
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
