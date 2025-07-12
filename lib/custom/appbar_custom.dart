import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hysun_security_2/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppBar buildFancyAppBar(String title) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade700, Colors.green.shade900],
        ),
        // borderRadius: const BorderRadius.only(
        //   bottomLeft: Radius.circular(25),
        //   bottomRight: Radius.circular(25),
        // ),
      ),
    ),
    title: Row(
      children: [
        Hero(
          tag: 'profileIcon',
          child: Material(
            color: Colors.transparent,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green.shade700),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications, color: Colors.white),
        onPressed: () {
          // Handle notification action
        },
      ),
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () async {
          showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.green.shade50,
              title: const Text("Logout Alert"),
              content: const Text("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setInt('status', 5);
                    print("Status set to 5");
                    Get.offAll(() => const LoginScreen());
                  },
                  child:
                      const Text("Logout", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}
