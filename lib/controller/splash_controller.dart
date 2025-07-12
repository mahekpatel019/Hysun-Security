import 'package:get/get.dart';
import 'package:hysun_security_2/home/home_screen.dart';
import 'package:hysun_security_2/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    checkStatus();
  }

  // Method to check status and navigate accordingly
  void checkStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Delay for 3 seconds

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int status =
        prefs.getInt('status') ?? 5; // Default to 0 if no value is found

    if (status == 0 || status == 1 || status == 2) {
      // Navigate to LoginScreen
      Get.offAll(() =>  const HomeScreen());
    } else {
      // Navigate to HomeScreen
      Get.offAll(() => const LoginScreen());
    }
  }
}
