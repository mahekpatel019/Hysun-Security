// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowmemberScreen extends StatefulWidget {
  const ShowmemberScreen({super.key});

  @override
  State<ShowmemberScreen> createState() => _ShowmemberScreenState();
}

class _ShowmemberScreenState extends State<ShowmemberScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String searchQuery = '';
  bool showPasswordMember = false;
  bool showPasswordSecurity = false;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchData() async {
    Map<String, List<Map<String, dynamic>>> categorizedData = {
      'members': [],
      'security_guards': [],
    };

    try {
      // Fetch members data
      QuerySnapshot membersSnapshot =
          await _firestore.collection('members').get();
      categorizedData['members']?.addAll(membersSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }));

      // Fetch security_guards data
      QuerySnapshot securityGuardsSnapshot =
          await _firestore.collection('security_gaurds').get();
      categorizedData['security_guards']
          ?.addAll(securityGuardsSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }));
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }

    return categorizedData;
  }

  Future<void> deleteItem(String collectionName, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Text('Error deleting item'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> filterData(List<Map<String, dynamic>> data) {
    if (searchQuery.isEmpty) return data;

    return data.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final email = item['email']?.toString().toLowerCase() ?? '';
      final number = item['number']?.toString().toLowerCase() ?? '';

      return name.contains(searchQuery.toLowerCase()) ||
          email.contains(searchQuery.toLowerCase()) ||
          number.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildHeader(
                screenWidth,
                Colors.green.shade700,
              ),
              _buildSearchAndFilter(screenWidth),
              Expanded(
                child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                  future: fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingWidget();
                    } else if (snapshot.hasError) {
                      return _buildErrorWidget();
                    } else if (!snapshot.hasData ||
                        (snapshot.data!['members']!.isEmpty &&
                            snapshot.data!['security_guards']!.isEmpty)) {
                      return _buildEmptyWidget();
                    }

                    Map<String, List<Map<String, dynamic>>> categorizedData =
                        snapshot.data!;

                    // Get filtered data and counts
                    List<Map<String, dynamic>> filteredMembers =
                        filterData(categorizedData['members']!);
                    List<Map<String, dynamic>> filteredSecurityGuards =
                        filterData(categorizedData['security_guards']!);

                    int membersCount = filteredMembers.length;
                    int securityGuardsCount = filteredSecurityGuards.length;

                    // If "All" is selected, show tabs
                    if (selectedFilter == 'All') {
                      return DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            // Tab Bar
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(25.0),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: TabBar(
                                splashBorderRadius: BorderRadius.circular(25.0),
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.green.shade700,
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.green.shade700,
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                tabs: [
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.people, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Members ($membersCount)'),
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.security, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Security ($securityGuardsCount)'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Tab Bar View
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // Members Tab
                                  SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        _buildCategorySection(
                                          'Members',
                                          filteredMembers,
                                          Icons.people,
                                          Colors.green.shade700,
                                          false,
                                          screenWidth,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Security Guards Tab
                                  SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        _buildCategorySection(
                                          'Security Guards',
                                          filteredSecurityGuards,
                                          Icons.security,
                                          Colors.green.shade700,
                                          true,
                                          screenWidth,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // If specific filter is selected (Members or Security)
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if (selectedFilter == 'Members')
                            _buildCategorySection(
                              'Members ($membersCount)',
                              filteredMembers,
                              Icons.people,
                              Colors.green.shade700,
                              false,
                              screenWidth,
                            ),
                          if (selectedFilter == 'Security')
                            _buildCategorySection(
                              'Security Guards ($securityGuardsCount)',
                              filteredSecurityGuards,
                              Icons.security,
                              Colors.green.shade700,
                              true,
                              screenWidth,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, Color color) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(1), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showFilterOptions(),
                icon: const Icon(Icons.tune, color: Colors.white),
              ),
              IconButton(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Members & Security',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth > 600 ? 32 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Manage community members',
            style: TextStyle(
              color: Colors.white70,
              fontSize: screenWidth > 600 ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              cursorColor: Colors.green.shade700,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Members', 'Security'].map((filter) {
                final isSelected = selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected ? Colors.green[500]! : Colors.grey[300]!,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Map<String, dynamic>> data,
    IconData icon,
    Color color,
    bool isSecurity,
    double screenWidth,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 22 : 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        '${data.length} ${data.length == 1 ? 'person' : 'people'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSecurity)
                  IconButton(
                    onPressed: () => setState(
                        () => showPasswordSecurity = !showPasswordSecurity),
                    icon: Icon(
                      showPasswordSecurity
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: color,
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => setState(
                        () => showPasswordMember = !showPasswordMember),
                    icon: Icon(
                      showPasswordMember
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: _buildMemberCard(item, color, isSecurity, screenWidth),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    Map<String, dynamic> item,
    Color color,
    bool isSecurity,
    double screenWidth,
  ) {
    final showPassword = isSecurity ? showPasswordSecurity : showPasswordMember;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showMemberDetails(item, isSecurity),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.1)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          (item['name'] ?? 'N')
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: screenWidth > 600 ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isSecurity
                                ? 'Shift: ${item['shift'] ?? 'N/A'}'
                                : 'House: ${item['houseNumber'] ?? 'N/A'}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmation(item, isSecurity);
                        } else if (value == 'edit') {
                          _showEditDialog(item, isSecurity);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 10),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          Icons.email, 'Email', item['email'] ?? 'N/A'),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.lock,
                        'Password',
                        showPassword ? (item['password'] ?? 'N/A') : '••••••••',
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                          Icons.phone, 'Phone', item['number'] ?? 'N/A'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading members...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 20),
          const Text(
            'Error loading data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No members found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add some members to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map item, bool isSecurity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // Add content padding to prevent overflow
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.red[400], size: 24),
                const SizedBox(width: 10),
                const Flexible(
                  child: Text(
                    'Delete Confirmation',
                    style: TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Text(
            'Are you sure you want to delete ${item['name'] ?? 'this person'}?',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.left,
          ),
        ),
        actions: [
          // Wrap actions in a responsive layout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // For small screens, stack buttons vertically
                if (MediaQuery.of(context).size.width < 400) ...[
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        deleteItem(
                          isSecurity ? 'security_gaurds' : 'members',
                          item['id'],
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ] else ...[
                  // For larger screens, keep buttons in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          deleteItem(
                            isSecurity ? 'security_gaurds' : 'members',
                            item['id'],
                          );
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetails(Map<String, dynamic> item, bool isSecurity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildDetailRow('Email', item['email'] ?? 'N/A'),
            _buildDetailRow('Password', item['password'] ?? 'N/A'),
            _buildDetailRow('Contact', item['number'] ?? 'N/A'),
            _buildDetailRow(
              isSecurity ? 'Shift' : 'House Number',
              isSecurity
                  ? (item['shift'] ?? 'N/A')
                  : (item['houseNumber'] ?? 'N/A'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item, bool isSecurity) {
    // Add edit functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Show All'),
              onTap: () {
                setState(() => selectedFilter = 'All');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Members Only'),
              onTap: () {
                setState(() => selectedFilter = 'Members');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security Only'),
              onTap: () {
                setState(() => selectedFilter = 'Security');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
