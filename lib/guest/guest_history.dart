import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GuestHistoryScreen extends StatefulWidget {
  const GuestHistoryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GuestHistoryScreenState createState() => _GuestHistoryScreenState();
}

class _GuestHistoryScreenState extends State<GuestHistoryScreen> {
  // Controller for search input
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest History'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by member name or number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase(); // Update the search query
                });
              },
            ),
          ),

          // Guest List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query updated to order by 'timestamp' in descending order
              stream: FirebaseFirestore.instance
                  .collection('guest_history')
                  .orderBy('timestamp',
                      descending: true) // Sorting by timestamp
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No guest history available.'));
                }

                final guestDocuments = snapshot.data!.docs;

                // Filter the guest data based on the search query
                final filteredGuests = guestDocuments.where((doc) {
                  final guestData = doc.data() as Map<String, dynamic>;
                  final memberDetails =
                      guestData['memberDetails'] as Map<String, dynamic>;
                  final memberName =
                      memberDetails['name'].toString().toLowerCase();
                  final memberNumber =
                      memberDetails['number'].toString().toLowerCase();

                  // Check if the search query matches either the member's name or number
                  return memberName.contains(_searchQuery) ||
                      memberNumber.contains(_searchQuery);
                }).toList();

                if (filteredGuests.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }

                return ListView.builder(
                  itemCount: filteredGuests.length,
                  itemBuilder: (context, index) {
                    final guestData =
                        filteredGuests[index].data() as Map<String, dynamic>;
                    final memberDetails =
                        guestData['memberDetails'] as Map<String, dynamic>;

                    // Get the timestamp and format it
                    final timestamp =
                        (guestData['timestamp'] as Timestamp).toDate();
                    final formattedDate = DateFormat('MM/dd/yyyy hh:mm a')
                        .format(timestamp); // Updated to 12-hour format

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Highlighted Member Details
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Member Details',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                  const SizedBox(height: 5),
                                  Text('Name: ${memberDetails['name']}',
                                      style: const TextStyle(fontSize: 14)),
                                  Text(
                                      'House Number: ${memberDetails['houseNumber']}',
                                      style: const TextStyle(fontSize: 14)),
                                  Text('Number: ${memberDetails['number']}',
                                      style: const TextStyle(fontSize: 14)),
                                  Text('Email: ${memberDetails['email']}',
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Guest Details
                            Text(
                              'Guest Name : ${guestData['guestName']}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text('Guest Number:  ${guestData['guestNumber']}'),

                            // Display Timestamp
                            const SizedBox(height: 5),
                            Text('Date and Time : $formattedDate',
                                style: const TextStyle(color: Colors.black)),

                            const SizedBox(height: 10),

                            // Display Guest Image
                            guestData['guestImage'] != null
                                ? Image.network(guestData['guestImage'],
                                    height: 150, width: 150, fit: BoxFit.cover)
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
