// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hyson_security/screen/guest_history.dart';
// import 'package:hyson_security/screen/videocall_screen.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class GuestAddScreen extends StatefulWidget {
//   final Map<String, dynamic> member;
//   const GuestAddScreen({super.key, required this.member});

//   @override
//   State<GuestAddScreen> createState() => _GuestAddScreenState();
// }

// class _GuestAddScreenState extends State<GuestAddScreen> {
//   final TextEditingController _guestNameController = TextEditingController();
//   final TextEditingController _guestNumberController = TextEditingController();
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//   bool _isSubmitting = false; // For submit button loading

//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       setState(() {
//         _image = File(image.path);
//       });
//     }
//   }

//   Future<void> _submitForm() async {
//     if (_guestNameController.text.isEmpty ||
//         _guestNumberController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields')),
//       );
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       String? downloadUrl;

//       // Check if an image is selected, if so upload it to Firebase Storage
//       if (_image != null) {
//         String imageName = DateTime.now().millisecondsSinceEpoch.toString();
//         Reference storageRef =
//             FirebaseStorage.instance.ref().child('guest_images/$imageName.jpg');
//         UploadTask uploadTask = storageRef.putFile(_image!);
//         TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
//         downloadUrl = await storageSnapshot.ref.getDownloadURL();
//       }

//       // Only include the member's name, number, and house number in Firestore
//       Map<String, dynamic> memberDetails = {
//         'name': widget.member['name'] ?? 'N/A',
//         'number': widget.member['number'] ?? 'N/A',
//         'houseNumber': widget.member['houseNumber'] ?? 'N/A',
//         'email': widget.member['email'] ?? 'N/A',
//       };

//       // Create guest data map, with optional guestImage
//       Map<String, dynamic> guestData = {
//         'guestName': _guestNameController.text,
//         'guestNumber': _guestNumberController.text,
//         'guestImage':
//             downloadUrl ?? null, // If no image is uploaded, this will be null
//         'memberDetails': memberDetails,
//         'timestamp': FieldValue.serverTimestamp(),
//       };

//       // Store guest details in Firestore under guest_history collection
//       await FirebaseFirestore.instance
//           .collection('guest_history')
//           .add(guestData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Guest details submitted successfully!')),
//       );

//       // Clear form fields after submission
//       _guestNameController.clear();
//       _guestNumberController.clear();
//       setState(() {
//         _image = null;
//         _isSubmitting = false;
//       });

//       Get.to(() => const GuestHistoryScreen());
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to submit guest details: $e')),
//       );
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.green.shade700,
//         title: const Text(
//           'Add Guest',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildMemberDetailsCard(),
//                   const SizedBox(height: 20),
//                   _buildGuestDetailsCard(),
//                   const SizedBox(height: 20),
//                   _buildImageCaptureSection(),
//                   const SizedBox(height: 20),

//                   // Submit Button
//                   Center(
//                     child: _isSubmitting
//                         ? const CircularProgressIndicator()
//                         : ElevatedButton.icon(
//                             onPressed: _submitForm,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                               padding: EdgeInsets.symmetric(
//                                   horizontal:
//                                       constraints.maxWidth < 600 ? 30 : 50,
//                                   vertical: 15),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             icon: const Icon(Icons.check),
//                             label: const Text(
//                               'Submit',
//                               style: TextStyle(fontSize: 18),
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildMemberDetailsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Member Details',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const Divider(height: 20),
//             _buildDetailRow(
//                 Icons.person, 'Name', widget.member['name'] ?? 'N/A'),
//             const SizedBox(height: 10),
//             _buildDetailRow(Icons.home, 'House Number',
//                 widget.member['houseNumber'] ?? 'N/A'),
//             const SizedBox(height: 10),
//             _buildDetailRow(
//                 Icons.phone, 'Number', widget.member['number'] ?? 'N/A'),
//             const SizedBox(height: 10),
//             _buildDetailRow(
//                 Icons.email, "Email", widget.member['email'] ?? 'N/A'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGuestDetailsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Add Guest Details',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const Divider(height: 20),
//             _buildTextField(
//               controller: _guestNameController,
//               label: 'Guest Name',
//               icon: Icons.person_add,
//             ),
//             const SizedBox(height: 15),
//             _buildTextField(
//               controller: _guestNumberController,
//               label: 'Guest Number',
//               icon: Icons.phone,
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageCaptureSection() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _image != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.file(
//                       _image!,
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                 : Container(
//                     height: 200,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Icon(
//                       Icons.camera_alt,
//                       size: 50,
//                       color: Colors.grey,
//                     ),
//                   ),
//             const SizedBox(height: 15),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               icon: const Icon(Icons.camera_alt),
//               label: const Text(
//                 'Capture Image',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Get.to(() => const VideoCallScreen());
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               icon: const Icon(Icons.video_call),
//               label: const Text(
//                 'Video Call',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.blue),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             '$label: $value',
//             style: const TextStyle(fontSize: 16),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.grey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.blue),
//         ),
//       ),
//     );
//   }
// }