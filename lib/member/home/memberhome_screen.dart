// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hysun_security_2/member/screens/complaint_history.dart';
import 'package:hysun_security_2/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// ignore: must_be_immutable
class MemberHomeScreen extends StatefulWidget {
  PreferredSizeWidget appBar;

  MemberHomeScreen({
    super.key,
    required this.appBar,
  });

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen>
    with SingleTickerProviderStateMixin {
  final CollectionReference _noticesCollection =
      FirebaseFirestore.instance.collection('notices');

  final CollectionReference membersCollection =
      FirebaseFirestore.instance.collection('members');

  String? memberId;
  String? memberName;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? lastNoticeId;
  StreamSubscription? _noticeSubscription;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    initNotifications();
    loadMemberData();
    saveTokenToFirestore();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(
          message.notification?.title ?? '', message.notification?.body ?? '');
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    FirebaseMessaging.instance.requestPermission();
    listenForNewNotices();
  }

  void saveTokenToFirestore() async {
    String? token = await FirebaseMessaging.instance.getToken();
    final memberDoc = await membersCollection.doc(memberId).get();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('members') // or your member collection
          .doc(memberDoc.id) // replace with logged in user ID
          .update({'fcmToken': token});
    }
  }

  void listenForNewNotices() {
    _noticeSubscription = FirebaseFirestore.instance
        .collection('notices')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var latest = snapshot.docs.first;
        final data = latest.data();
        debugPrint("New Firestore data fetched");
        debugPrint("Latest Notice: ${data['notice']}");
        if (!_hasInitialized) {
          lastNoticeId = latest.id;
          _hasInitialized = true;
          return;
        }
        if (latest.id != lastNoticeId) {
          lastNoticeId = latest.id;
          showNotification(data['name'] ?? 'New Notice', data['notice'] ?? '');
        }
      }
    });
  }

  Future<void> loadMemberData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        memberId = prefs.getString('userId');
      });

      // Fetch member's name from Firestore
      if (memberId != null) {
        final memberDoc = await membersCollection.doc(memberId).get();
        if (memberDoc.exists) {
          setState(() {
            memberName =
                memberDoc.get('name') ?? ''; // Assuming 'name' field exists
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading member data: $e');
    }
  }

  @override
  void dispose() {
    _noticeSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    debugPrint(memberId);
    return Scaffold(
      appBar: widget.appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              color: Colors.green.shade600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(isTablet),
                      const SizedBox(height: 24),

                      // Latest Notice Section
                      _buildLatestNoticeSection(isTablet),

                      const SizedBox(height: 24),

                      // Quick Actions Section
                      _buildQuickActionsSection(isTablet),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.white,
                radius: isTablet ? 30 : 24,
                child: Icon(
                  Icons.person,
                  color: Colors.green.shade600,
                  size: isTablet ? 36 : 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        height: 10.0,
                        color: Colors.white,
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      memberName ?? 'Loading...',
                      style: TextStyle(
                        height: 10.0,
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Stay updated with the latest notices and manage your complaints easily.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestNoticeSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Colors.green.shade600,
              size: isTablet ? 28 : 24,
            ),
            const SizedBox(width: 8),
            Text(
              "Latest Notice",
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _noticesCollection
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(isTablet);
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildNoNoticeCard(isTablet);
            }

            var doc = snapshot.data!.docs.first;
            DateTime? timestamp = doc['timestamp']?.toDate();

            return _buildNoticeCard(doc, timestamp, isTablet);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingCard(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Colors.green.shade600,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading latest notice...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNoticeCard(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: isTablet ? 48 : 40,
              color: Colors.green.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Current Notices',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! No new notices at this time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(
      DocumentSnapshot doc, DateTime? timestamp, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    doc['name'] ?? 'Notice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 20 : 18,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                if (timestamp != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  firstChild: Text(
                    doc['notice'] ?? 'No content available',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  secondChild: Text(
                    doc['notice'] ?? 'No content available',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                if ((doc['notice'] ?? '').length > 100)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? 'Show Less' : 'Read More',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 14 : 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.green.shade600,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.dashboard,
              color: Colors.green.shade600,
              size: isTablet ? 28 : 24,
            ),
            const SizedBox(width: 8),
            Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'New Complaint',
                subtitle: 'Submit a complaint',
                color: Colors.blue,
                onTap: _showAddComplaintDialog,
                isTablet: isTablet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'View History',
                subtitle: 'Check complaint',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComplaintsHistoryScreen(),
                    ),
                  );
                },
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isTablet ? 28 : 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}';
  }

  void _showAddComplaintDialog() {
    final TextEditingController nameController =
        TextEditingController(text: memberName ?? 'Loading...');
    final TextEditingController complaintController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.report_problem, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text("Add Complaint"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: complaintController,
                decoration: InputDecoration(
                  labelText: 'Your Complaint',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    complaintController.text.isNotEmpty) {
                  _addComplaint(nameController.text, complaintController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _addComplaint(String name, String complaint) {
    // Current timestamp
    final timestamp = Timestamp.now();

    // Check if document exists first
    membersCollection.doc(memberId).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        // Document exists, update it
        membersCollection.doc(memberId).update({
          'complaints': FieldValue.arrayUnion([
            {
              'name': name,
              'complaint': complaint,
              'timestamp': timestamp,
            }
          ]),
        }).then((_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Complaint submitted successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating complaint: $error')),
          );
        });
      } else {
        // Document doesn't exist, create it
        membersCollection.doc(memberId).set({
          'complaints': [
            {
              'name': name,
              'complaint': complaint,
              'timestamp': timestamp,
            }
          ],
        }).then((_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Complaint submitted successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating document: $error')),
          );
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking document: $error')),
      );
    });
  }
}
