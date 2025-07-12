import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class MemberModel {
  final TextEditingController houseNumber;
  final TextEditingController name;
  final TextEditingController number;
  final TextEditingController email;
  final TextEditingController password;
  final RxBool isNameValid = true.obs; // Validates name
  final RxBool isHouseNumberValid = true.obs; // Validates house number
  final RxBool isNumberValid = true.obs; // Validates phone number

  MemberModel({
    required this.houseNumber,
    required this.name,
    required this.number,
    required this.email,
    required this.password,
  });
}

class AddMemberController extends GetxController {
  var members = <MemberModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    addNewMember(); // Initialize with one member
  }

  void addNewMember() {
    members.add(MemberModel(
      houseNumber: TextEditingController(),
      name: TextEditingController(),
      number: TextEditingController(),
      email: TextEditingController(),
      password: TextEditingController(),
    ));
  }

  bool validateMember(int index) {
    final member = members[index];
    bool isValid = true;

    // Validate the 'name' field
    if (member.name.text.isEmpty) {
      member.isNameValid.value = false;
      isValid = false;
    } else {
      member.isNameValid.value = true;
    }

    // Validate the 'house number' field
    if (member.houseNumber.text.isEmpty) {
      member.isHouseNumberValid.value = false;
      isValid = false;
    } else {
      member.isHouseNumberValid.value = true;
    }

    // Validate the 'number' field
    if (member.number.text.isEmpty) {
      member.isNumberValid.value = false;
      isValid = false;
    } else {
      member.isNumberValid.value = true;
    }

    return isValid;
  }

  bool validateAllMembers() {
    bool allValid = true;
    for (var i = 0; i < members.length; i++) {
      if (!validateMember(i)) {
        allValid = false;
      }
    }
    return allValid;
  }

  void updateEmailAndPassword(int index) {
    final name = members[index].name.text;
    if (name.isEmpty) {
      members[index].isNameValid.value = false; // Show error if name is empty
      return;
    }
    members[index].email.text = generateEmail(name);
    members[index].password.text = generatePassword(name);
  }

  String generateEmail(String name) {
    final sanitizedName =
        name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final random = Random();
    final randomNum = random.nextInt(1000);
    return '$sanitizedName$randomNum@gmail.com';
  }

  String generatePassword(String name) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final namePrefix =
        name.substring(0, name.length > 3 ? 3 : name.length).toUpperCase();
    final randomSuffix =
        List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
    return '$namePrefix$randomSuffix';
  }

  void saveAllMembers() async {
    if (!validateAllMembers()) {
      Get.snackbar("Validation Error", "Please fill all required fields.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    // Reference to Firestore collection
    CollectionReference membersCollection =
        FirebaseFirestore.instance.collection('members');

    try {
      for (var member in members) {
        // Create a new document for each member
        await membersCollection.add({
          'houseNumber': member.houseNumber.text,
          'name': member.name.text,
          'number': member.number.text,
          'email': member.email.text,
          'password': member.password.text,
          'status': 1,
        });
      }    
      // Clear all fields after saving
      clearAllMembers();

      Get.snackbar("Success", "All members saved successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to save members: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  void clearAllMembers() {
    for (var member in members) {
      member.houseNumber.clear();
      member.name.clear();
      member.number.clear();
      member.email.clear();
      member.password.clear();
    }
  }

  void deleteMember(int index) {
    if (members.isNotEmpty) {
      members.removeAt(index);
    }
  }
}
