import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hysun_security_2/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  RxBool isPasswordVisible = false.obs;
  RxString userId = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void showSnackbar(String message) {
    Get.snackbar(
      'Authentication Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> loginUser() async {
    try {
      // Check in chairman, members, and security_guards collections
      bool isLoggedIn = await _checkLogin('chairman', 0);
      if (!isLoggedIn) {
        isLoggedIn = await _checkLogin('members', 1);
      }
      if (!isLoggedIn) {
        isLoggedIn = await _checkLogin('security_gaurds', 2);
      }

      // If the user wasn't found in any of the collections, show error
      if (!isLoggedIn) {
        showSnackbar('Invalid email or password');
      }
    } catch (e) {
      showSnackbar('Login failed: $e');
    }
  }

  Future<bool> _checkLogin(String collectionName, int status) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('email', isEqualTo: email.text)
        .where('password', isEqualTo: password.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Login successful, save the status and proceed
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'status', status); 
          await prefs.setString('userId', querySnapshot.docs.first.id);
          // Set the status based on collection
      Get.snackbar(
        'Success',
        'Login successful as $collectionName',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() =>  const HomeScreen());
      return true; // Return true to indicate successful login
    }
    return false; // Return false if no matching document was found
  }
}
