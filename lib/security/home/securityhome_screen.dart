import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:hysun_security_2/guest/guest_history.dart';
import 'package:hysun_security_2/security/home/components/empty_widget.dart';
import 'package:hysun_security_2/security/home/components/member_card.dart';

class SecurityHomeScreen extends StatefulWidget {
  final PreferredSizeWidget appBar;
  const SecurityHomeScreen({
    super.key,
    required this.appBar,
  });

  @override
  State<SecurityHomeScreen> createState() => _SecurityHomeScreenState();
}

class _SecurityHomeScreenState extends State<SecurityHomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorTween;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Define theme colors
  final primaryGreen = const Color(0xFF2E7D32); // Deep green
  final secondaryGreen = const Color(0xFF81C784); // Light green
  final accentGreen = const Color(0xFF00C853); // Vibrant green
  final lightGreen = const Color(0xFFE8F5E9); // Very light green

  Future<List<Map<String, dynamic>>> fetchMembers() async {
    QuerySnapshot membersSnapshot =
        await _firestore.collection('members').get();
    return membersSnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add document ID for deletion reference
      return data;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _colorTween = ColorTween(
      begin: const Color(0xFFE8F5E9),
      end: const Color(0xFFC8E6C9),
    ).animate(_colorAnimationController);

    // Add a listener to search query changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade200,
        onPressed: () {
          Get.to(() => const GuestHistoryScreen());
        },
        child: const Center(
          child: Icon(Icons.history),
        ),
      ),
      appBar: widget.appBar,
      body: AnimatedBuilder(
        animation: _colorAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _colorTween.value ?? lightGreen,
                  Colors.white,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Column(
          children: [
            // Add a search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by name or house number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchMembers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGreen.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryGreen),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading Members...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return EmptyStateWidget(primaryGreen: primaryGreen);
                  }

                  List<Map<String, dynamic>> members = snapshot.data!;

                  // Filter members based on the search query
                  List<Map<String, dynamic>> filteredMembers =
                      members.where((member) {
                    String name = member['name']?.toLowerCase() ?? '';
                    String houseNumber =
                        member['houseNumber']?.toLowerCase() ?? '';
                    return name.contains(_searchQuery) ||
                        houseNumber.contains(_searchQuery);
                  }).toList();

                  if (filteredMembers.isEmpty) {
                    return EmptyStateWidget(primaryGreen: primaryGreen);
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: MemberCard(
                                member: filteredMembers[index],
                                primaryGreen: primaryGreen,
                                secondaryGreen: secondaryGreen,
                                lightGreen: lightGreen,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
