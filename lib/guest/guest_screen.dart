// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hysun_security_2/guest/guest_history.dart';
import 'package:hysun_security_2/security/guest/components/guest_details_card.dart';
import 'package:hysun_security_2/security/guest/components/image_capture.dart';
import 'package:hysun_security_2/security/guest/components/member_details_card.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuestAddScreen extends StatefulWidget {
  final Map<String, dynamic> member;
  const GuestAddScreen({super.key, required this.member});

  @override
  State<GuestAddScreen> createState() => _GuestAddScreenState();
}

class _GuestAddScreenState extends State<GuestAddScreen> {
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _guestNumberController = TextEditingController();
  File? _image;
  // ignore: unused_field
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (_guestNameController.text.isEmpty ||
        _guestNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? downloadUrl;

      if (_image != null) {
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
            FirebaseStorage.instance.ref().child('guest_images/$imageName.jpg');
        UploadTask uploadTask = storageRef.putFile(_image!);
        TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
        downloadUrl = await storageSnapshot.ref.getDownloadURL();
      }

      Map<String, dynamic> memberDetails = {
        'name': widget.member['name'] ?? 'N/A',
        'number': widget.member['number'] ?? 'N/A',
        'houseNumber': widget.member['houseNumber'] ?? 'N/A',
        'email': widget.member['email'] ?? 'N/A',
      };

      Map<String, dynamic> guestData = {
        'guestName': _guestNameController.text,
        'guestNumber': _guestNumberController.text,
        'guestImage': downloadUrl,
        'memberDetails': memberDetails,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('guest_history')
          .add(guestData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest details submitted successfully!')),
      );

      _guestNameController.clear();
      _guestNumberController.clear();
      setState(() {
        _image = null;
        _isSubmitting = false;
      });

      Get.to(() => const GuestHistoryScreen());
    } catch (e) {
      log("Error to submit data");
      log(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit guest details: $e')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text(
          'Add Guest',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MemberDetailsCard(member: widget.member),
                  const SizedBox(height: 20),
                  GuestDetailsCard(
                    guestNameController: _guestNameController,
                    guestNumberController: _guestNumberController,
                  ),
                  const SizedBox(height: 20),
                  ImageCaptureSection(
                    image: _image,
                    onImagePicked: (File? image) {
                      setState(() {
                        _image = image;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      constraints.maxWidth < 600 ? 30 : 50,
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text(
                              'Submit',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
