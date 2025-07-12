import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hysun_security_2/chairman/home/chairmanhome_screen.dart';
import 'package:hysun_security_2/custom/appbar_custom.dart';
import 'package:hysun_security_2/member/home/memberhome_screen.dart';
import 'package:hysun_security_2/security/home/securityhome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RxInt status = 0.obs;
  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    status.value =
        prefs.getInt('status') ?? 5; // Default to 0 if no value is found
    debugPrint("Current status: $status"); // Print the status
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => status.value == 0
          ? ChairmanhomeScreen(appBar: buildFancyAppBar("CHAIRMAN"))
          : status.value == 1
              ? MemberHomeScreen(
                  appBar: buildFancyAppBar("Member"),
                )
              : status.value == 2
                  ? SecurityHomeScreen(
                      appBar: buildFancyAppBar("Security"),
                    )
                  : const SizedBox(),
    );
  }
}
