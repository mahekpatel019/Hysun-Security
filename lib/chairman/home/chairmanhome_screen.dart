// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hysun_security_2/chairman/screens/complaints_screen.dart';
import 'package:hysun_security_2/chairman/screens/notice_screen.dart';
import 'package:hysun_security_2/chairman/screens/add_member.dart';
import 'package:hysun_security_2/chairman/screens/parking_screen.dart';
import 'package:hysun_security_2/chairman/screens/showmember_screen.dart';
import 'package:hysun_security_2/chairman/screens/add_security.dart';

class ChairmanhomeScreen extends StatefulWidget {
  final PreferredSizeWidget appBar;

  const ChairmanhomeScreen({
    super.key,
    required this.appBar,
  });

  @override
  State<ChairmanhomeScreen> createState() => _ChairmanhomeScreenState();
}

class _ChairmanhomeScreenState extends State<ChairmanhomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  // Firebase counts
  int totalMembers = 0;
  int activeComplaints = 0;
  int securityGuards = 0;
  bool isLoading = true;

  // For managing async operations
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    // Managing all states of the screen
    _initializeAnimations();
    _fetchCounts();
  }

  void _initializeAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Dispose animation controllers
    _floatingController.dispose();
    super.dispose();
  }

  // Safe setState wrapper
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _fetchCounts() async {
    if (!mounted) return;

    try {
      _safeSetState(() {
        isLoading = true;
      });

      // Fetch all counts simultaneously
      final results = await Future.wait([
        _getTotalMembers(),
        _getActiveComplaints(),
        _getSecurityGuards(),
      ]);

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      _safeSetState(() {
        totalMembers = results[0];
        activeComplaints = results[1];
        securityGuards = results[2];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching counts: $e');
      if (mounted) {
        _safeSetState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<int> _getTotalMembers() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('members')
          .get();
      
      // Check if widget is still mounted
      if (!mounted) return 0;
      
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching members count: $e');
      return 0;
    }
  }

  Future<int> _getActiveComplaints() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('status', whereIn: ['active', 'pending', 'open'])
          .get();
      
      // Check if widget is still mounted
      if (!mounted) return 0;
      
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching complaints count: $e');
      return 0;
    }
  }

  Future<int> _getSecurityGuards() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('security_gaurds')
          .get();
      
      // Check if widget is still mounted
      if (!mounted) return 0;
      
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching security count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if widget is mounted
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade100,
              Colors.green.shade50,
              Colors.white,
              Colors.green.shade50,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchCounts,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 16,
                      20,
                      isTablet ? 32 : 16,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEnhancedWelcomeSection(isTablet),
                        SizedBox(height: isTablet ? 30 : 20),
                        _buildStatsRow(),
                        SizedBox(height: isTablet ? 30 : 20),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 16,
                  ),
                  sliver: _buildResponsiveDashboardGrid(isTablet),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEnhancedWelcomeSection(bool isTablet) {
    return AnimationLimiter(
      child: AnimationConfiguration.staggeredList(
        position: 0,
        duration: const Duration(milliseconds: 600),
        child: SlideAnimation(
          verticalOffset: -50.0,
          child: FadeInAnimation(
            child: Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade600,
                    Colors.green.shade700,
                    Colors.green.shade800,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chairman Dashboard',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade100,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your community with efficiency',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingAnimation.value),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            size: isTablet ? 40 : 35,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Members',
            isLoading ? '-' : totalMembers.toString(),
            Icons.people,
            isLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active Complaints',
            isLoading ? '-' : activeComplaints.toString(),
            Icons.warning,
            isLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Security Guards',
            isLoading ? '-' : securityGuards.toString(),
            Icons.security,
            isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.green.shade600,
            size: 24,
          ),
          const SizedBox(height: 8),
          isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade700,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveDashboardGrid(bool isTablet) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        childAspectRatio: isTablet ? 1.2 : 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: isTablet ? 3 : 2,
            child: ScaleAnimation(
              scale: 0.5,
              child: FadeInAnimation(
                child: _buildEnhancedDashboardCard(
                  title: _getDashboardItemTitle(index),
                  icon: _getDashboardItemIcon(index),
                  gradientColors: _getDashboardItemGradient(index),
                  onTap: () => _handleDashboardItemTap(index),
                  index: index,
                ),
              ),
            ),
          );
        },
        childCount: 7,
      ),
    );
  }

  List<Color> _getDashboardItemGradient(int index) {
    switch (index) {
      case 0:
        return [Colors.green.shade400, Colors.green.shade600];
      case 1:
        return [Colors.green.shade500, Colors.green.shade700];
      case 2:
        return [Colors.green.shade600, Colors.green.shade800];
      case 3:
        return [Colors.green.shade400, Colors.green.shade700];
      case 4:
        return [Colors.green.shade500, Colors.green.shade800];
      case 5:
        return [Colors.green.shade400, Colors.green.shade600];
      case 6:
        return [Colors.green.shade600, Colors.green.shade700];
      default:
        return [Colors.green.shade400, Colors.green.shade600];
    }
  }

  Widget _buildEnhancedDashboardCard({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          onTap();
        }
      },
      child: Hero(
        tag: 'dashboard_card_$index',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradientColors[1].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (mounted) {
                  onTap();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        if (mounted) {
          _showQuickActionMenu();
        }
      },
      backgroundColor: Colors.green.shade700,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Quick Action',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showQuickActionMenu() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  'Add Member',
                  Icons.person_add,
                  () => Get.to(() => const AddMemberScreen()),
                ),
                _buildQuickActionButton(
                  'New Notice',
                  Icons.announcement,
                  () => Get.to(() => const NoticeScreen()),
                ),
                _buildQuickActionButton(
                  'View Complaints',
                  Icons.warning,
                  () => Get.to(() => const ComplaintsScreen()),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          Navigator.pop(context);
          onTap();
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDashboardItemTitle(int index) {
    switch (index) {
      case 0:
        return 'Add Members';
      case 1:
        return 'Add Security';
      case 2:
        return 'Complaints';
      case 3:
        return 'Notices';
      case 4:
        return 'Finance';
      case 5:
        return 'Show Members & Security';
      case 6:
        return 'Parking';
      default:
        return '';
    }
  }

  IconData _getDashboardItemIcon(int index) {
    switch (index) {
      case 0:
        return Icons.person_add_alt_1;
      case 1:
        return Icons.security;
      case 2:
        return Icons.warning_amber_rounded;
      case 3:
        return Icons.announcement_rounded;
      case 4:
        return Icons.attach_money_rounded;
      case 5:
        return Icons.people_outline_rounded;
      case 6:
        return Icons.local_parking_rounded;
      default:
        return Icons.error;
    }
  }

  void _handleDashboardItemTap(int index) {
    if (!mounted) return;

    switch (index) {
      case 0:
        Get.to(() => const AddMemberScreen());
        break;
      case 1:
        Get.to(() => const AddSecurityScreen());
        break;
      case 2:
        Get.to(() => const ComplaintsScreen());
        break;
      case 3:
        Get.to(() => const NoticeScreen());
        break;
      case 4:
        // Get.to(() => const FinanceScreen());
        break;
      case 5:
        Get.to(() => const ShowmemberScreen());
        break;
      case 6:
        Get.to(() => const FancyParkingScreen());
        break;
    }
  }
}