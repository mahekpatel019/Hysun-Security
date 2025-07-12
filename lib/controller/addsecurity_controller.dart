import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SecurityModel {
  final TextEditingController name;
  final TextEditingController number;
  final TextEditingController email;
  final TextEditingController password;
  final RxString selectedShift = ''.obs; // Add this line for shift selection
  final RxBool isNameValid = true.obs;
  final RxBool isNumberValid = true.obs;

  SecurityModel({
    required this.name,
    required this.number,
    required this.email,
    required this.password,
  });
}

class AddSecurityController extends GetxController {
  var securityMembers = <SecurityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    addNewSecurityMember(); // Initialize with one security member
  }

  void addNewSecurityMember() {
    securityMembers.add(SecurityModel(
      name: TextEditingController(),
      number: TextEditingController(),
      email: TextEditingController(),
      password: TextEditingController(),
    ));
  }

  bool validateSecurityMember(int index) {
    final member = securityMembers[index];
    bool isValid = true;

    if (member.name.text.isEmpty) {
      member.isNameValid.value = false;
      isValid = false;
    } else {
      member.isNameValid.value = true;
    }

    if (member.number.text.isEmpty) {
      member.isNumberValid.value = false;
      isValid = false;
    } else {
      member.isNumberValid.value = true;
    }

    if (member.selectedShift.value.isEmpty) { // Check if shift is selected
      isValid = false;
    }

    return isValid;
  }

  bool validateAllSecurityMembers() {
    bool allValid = true;
    for (var i = 0; i < securityMembers.length; i++) {
      if (!validateSecurityMember(i)) {
        allValid = false;
      }
    }
    return allValid;
  }

  void updateEmailAndPassword(int index) {
    final name = securityMembers[index].name.text;
    if (name.isEmpty) {
      securityMembers[index].isNameValid.value = false;
      return;
    }
    securityMembers[index].email.text = generateEmail(name);
    securityMembers[index].password.text = generatePassword(name);
  }

  String generateEmail(String name) {
    final sanitizedName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final random = Random();
    final randomNum = random.nextInt(1000);
    return '$sanitizedName$randomNum@gmail.com';
  }

  String generatePassword(String name) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final namePrefix = name.substring(0, name.length > 3 ? 3 : name.length).toUpperCase();
    final randomSuffix = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
    return '$namePrefix$randomSuffix';
  }

  void saveAllSecurityMembers() async {
    if (!validateAllSecurityMembers()) {
      Get.snackbar("Validation Error", "Please fill all required fields.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    CollectionReference securityCollection = FirebaseFirestore.instance.collection('security_gaurds');

    try {
      for (var member in securityMembers) {
        await securityCollection.add({
          'shift': member.selectedShift.value, // Save the selected shift
          'name': member.name.text,
          'number': member.number.text,
          'email': member.email.text,
          'password': member.password.text,
          'status':2,
        });
      }
  
      clearAllSecurityMembers();

      Get.snackbar("Success", "All security members saved successfully!",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to save security members: $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void clearAllSecurityMembers() {
    for (var member in securityMembers) {
      member.name.clear();
      member.number.clear();
      member.email.clear();
      member.password.clear();
      member.selectedShift.value = ''; // Clear the selected shift
    }
  }

  void deleteSecurityMember(int index) {
    if (securityMembers.isNotEmpty) {
      securityMembers.removeAt(index);
    }
  }
}
