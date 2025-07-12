// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FancyParkingScreen extends StatefulWidget {
  const FancyParkingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FancyParkingScreenState createState() => _FancyParkingScreenState();
}

class _FancyParkingScreenState extends State<FancyParkingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> parkingList = [];
  String searchQuery = '';
  String filterStatus = 'All';

  final List<String> statusOptions = [
    'All',
    'Available',
    'Occupied',
    'Reserved'
  ];

  @override
  void initState() {
    super.initState();
    _fetchParkingSpots();
  }

  Future<void> _fetchParkingSpots() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('parking').get();
      setState(() {
        parkingList = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            "id": doc.id,
            "spot": data['spot'] ?? '',
            "member": data['member'] ?? '',
            "vehicle": data['vehicle'] ?? '',
            "status": data['status'] ?? 'Available',
            "checkInTime": data['checkInTime'] != null
                ? (data['checkInTime'] as Timestamp).toDate()
                : null,
            "checkOutTime": data['checkOutTime'] != null
                ? (data['checkOutTime'] as Timestamp).toDate()
                : null,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching parking spots: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load parking data: $e')),
      );
    }
  }

  Future<void> _addOrUpdateParkingSpot(
    String spot,
    String member,
    String vehicle,
    String status, {
    String? id,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) async {
    try {
      final data = {
        'spot': spot,
        'member': member,
        'vehicle': vehicle,
        'status': status,
        'checkInTime':
            checkInTime != null ? Timestamp.fromDate(checkInTime) : null,
        'checkOutTime':
            checkOutTime != null ? Timestamp.fromDate(checkOutTime) : null,
      };

      if (id == null) {
        await _firestore.collection('parking').add(data);
      } else {
        await _firestore.collection('parking').doc(id).update(data);
      }
      _fetchParkingSpots();
    } catch (e) {
      print('Error adding/updating parking spot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save parking data: $e')),
      );
    }
  }

  Future<void> _checkIn(String id) async {
    try {
      await _firestore.collection('parking').doc(id).update({
        'status': 'Occupied',
        'checkInTime': Timestamp.now(),
        'checkOutTime': null,
      });
      _fetchParkingSpots();
    } catch (e) {
      print('Error checking in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check in: $e')),
      );
    }
  }

  Future<void> _checkOut(String id) async {
    try {
      await _firestore.collection('parking').doc(id).update({
        'status': 'Available',
        'checkOutTime': Timestamp.now(),
      });
      _fetchParkingSpots();
    } catch (e) {
      print('Error checking out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check out: $e')),
      );
    }
  }

  String _calculateDuration(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null) return 'N/A';
    final end = checkOut ?? DateTime.now();
    final duration = end.difference(checkIn);
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }

  void _showParkingDialog({Map<String, dynamic>? parkingSpot}) {
    final TextEditingController spotController =
        TextEditingController(text: parkingSpot?['spot']);
    final TextEditingController memberController =
        TextEditingController(text: parkingSpot?['member']);
    final TextEditingController vehicleController =
        TextEditingController(text: parkingSpot?['vehicle']);
    String status = parkingSpot?['status'] ?? 'Available';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              parkingSpot == null ? 'Add Parking Spot' : 'Edit Parking Spot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: spotController,
                  decoration: const InputDecoration(labelText: 'Parking Spot'),
                ),
                TextField(
                  controller: memberController,
                  decoration: const InputDecoration(labelText: 'Member Name'),
                ),
                TextField(
                  controller: vehicleController,
                  decoration: const InputDecoration(labelText: 'Vehicle Type'),
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  items:
                      ['Available', 'Occupied', 'Reserved'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    status = newValue!;
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addOrUpdateParkingSpot(
                  spotController.text,
                  memberController.text,
                  vehicleController.text,
                  status,
                  id: parkingSpot?['id'],
                  checkInTime: status == 'Occupied' ? DateTime.now() : null,
                );
                Navigator.pop(context);
              },
              child: Text(parkingSpot == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChart() {
    int available =
        parkingList.where((spot) => spot['status'] == 'Available').length;
    int occupied =
        parkingList.where((spot) => spot['status'] == 'Occupied').length;
    int reserved =
        parkingList.where((spot) => spot['status'] == 'Reserved').length;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: available.toDouble(),
            color: Colors.green,
            title: 'Available\n$available',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: occupied.toDouble(),
            color: Colors.red,
            title: 'Occupied\n$occupied',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: reserved.toDouble(),
            color: Colors.orange,
            title: 'Reserved\n$reserved',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredParkingList = parkingList.where((spot) {
      final matchesSearch = spot['spot']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          spot['member'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          spot['vehicle'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter =
          filterStatus == 'All' || spot['status'] == filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fancy Parking Management'),
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: filterStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.greenAccent.withOpacity(
                          0.1), // Background color with green accent
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                        borderSide: const BorderSide(
                          color: Colors.green, // Green border color
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green, // Green icon color
                      size: 28, // Icon size
                    ),
                    style: const TextStyle(
                      color: Colors.green, // Green text color
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white, // Dropdown background color
                    items: statusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.black87, // Dropdown item text color
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        filterStatus = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 250,
              child: _buildPieChart(),
            ),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: filteredParkingList.length,
                  itemBuilder: (context, index) {
                    final spot = filteredParkingList[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                "Spot: ${spot['spot']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Member: ${spot['member'] ?? 'None'}"),
                                  Text("Vehicle: ${spot['vehicle'] ?? 'None'}"),
                                  Text(
                                    "Status: ${spot['status']}",
                                    style: TextStyle(
                                      color: spot['status'] == 'Available'
                                          ? Colors.green
                                          : spot['status'] == 'Occupied'
                                              ? Colors.red
                                              : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                      "Duration: ${_calculateDuration(spot['checkInTime'], spot['checkOutTime'])}"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showParkingDialog(parkingSpot: spot),
                                  ),
                                  if (spot['status'] == 'Available' ||
                                      spot['status'] == 'Reserved')
                                    IconButton(
                                      icon: const Icon(Icons.login,
                                          color: Colors.green),
                                      onPressed: () => _checkIn(spot['id']),
                                    )
                                  else if (spot['status'] == 'Occupied')
                                    IconButton(
                                      icon: const Icon(Icons.logout,
                                          color: Colors.red),
                                      onPressed: () => _checkOut(spot['id']),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showParkingDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Spot'),
        ),
      ),
    );
  }
}
