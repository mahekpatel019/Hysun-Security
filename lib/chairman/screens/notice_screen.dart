// lib/notice/notice_screen.dart (UPDATED)
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final TextEditingController _noticeController = TextEditingController();
  final TextEditingController _noticeNameController = TextEditingController();

  // This will be initialized after fetching chairmanId
  late CollectionReference _noticesCollection;
  String? _chairmanId; // To store the chairman's ID

  @override
  void initState() {
    super.initState();
    _loadChairmanIdAndInitializeFirestore();
  }

  // Load the chairmanId from SharedPreferences and then initialize Firestore collection
  Future<void> _loadChairmanIdAndInitializeFirestore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId'); // Chairman's userId is their own ID

    if (id == null || id.isEmpty) {
      // Handle case where chairmanId is not found (e.g., not logged in as chairman)
      // You might want to show an error or navigate back to login.
      debugPrint('Error: Chairman ID not found in SharedPreferences.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error: Chairman ID not found. Please log in as Chairman.')),
        );
        // Optionally, navigate back or show an error screen
        // Get.offAll(() => const RoleSelectionScreen());
      }
      return;
    }

    setState(() {
      _chairmanId = id;
      // Initialize the collection reference with the chairman's ID
      _noticesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(_chairmanId)
          .collection('notices');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if chairmanId is not yet loaded
    if (_chairmanId == null) {
      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'Notice Board',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green.shade600,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        backgroundColor: Colors.green.shade50,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.green.shade600,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Notice Board',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      backgroundColor: Colors.green.shade50,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Use the dynamically initialized _noticesCollection
              stream: _noticesCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
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
                          Icons.notifications_off_outlined,
                          size: 60,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notices found',
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

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: snapshot.data!.docs.map((doc) {
                    DateTime? timestamp = doc['timestamp']?.toDate();
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.green.shade50,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.announcement,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      doc['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      _showNoticeForm(context, doc);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _deleteNotice(doc.id);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  doc['notice'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timestamp != null
                                        ? _formatDate(timestamp)
                                        : 'No date available',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoticeForm(context);
        },
        backgroundColor: Colors.green.shade600,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showNoticeForm(BuildContext context, [DocumentSnapshot? doc]) {
    if (doc != null) {
      _noticeNameController.text = doc['name'];
      _noticeController.text = doc['notice'];
    } else {
      _noticeNameController.clear();
      _noticeController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doc != null ? 'Update Notice' : 'Add Notice',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _noticeNameController,
                  decoration: InputDecoration(
                    labelText: 'Notice Title',
                    labelStyle: TextStyle(color: Colors.green.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
                    prefixIcon: Icon(
                      Icons.title,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noticeController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Notice Content',
                    labelStyle: TextStyle(color: Colors.green.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
                    prefixIcon: Icon(
                      Icons.description,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_noticeNameController.text.isEmpty ||
                        _noticeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all notice fields.')),
                      );
                      return;
                    }
                    if (doc != null) {
                      _updateNotice(doc.id);
                    } else {
                      _addNotice();
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 8),
                      Text(
                        'Submit',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addNotice() async {
    if (_chairmanId == null) {
      debugPrint('Error: Chairman ID is null. Cannot add notice.');
      return;
    }
    try {
      await _noticesCollection.add({
        'name': _noticeNameController.text,
        'notice': _noticeController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'chairmanId': _chairmanId, // Link notice to the chairman
      });
      _noticeController.clear();
      _noticeNameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice added successfully!')),
      );
    } catch (e) {
      debugPrint('Error adding notice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add notice: $e')),
      );
    }
  }

  Future<void> _updateNotice(String id) async {
    if (_chairmanId == null) {
      debugPrint('Error: Chairman ID is null. Cannot update notice.');
      return;
    }
    try {
      await _noticesCollection.doc(id).update({
        'name': _noticeNameController.text,
        'notice': _noticeController.text,
        // No need to update timestamp unless explicitly desired
      });
      _noticeController.clear();
      _noticeNameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice updated successfully!')),
      );
    } catch (e) {
      debugPrint('Error updating notice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notice: $e')),
      );
    }
  }

  Future<void> _deleteNotice(String id) async {
    if (_chairmanId == null) {
      debugPrint('Error: Chairman ID is null. Cannot delete notice.');
      return;
    }
    try {
      await _noticesCollection.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice deleted successfully!')),
      );
    } catch (e) {
      debugPrint('Error deleting notice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete notice: $e')),
      );
    }
  }

  String _formatDate(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }
}
