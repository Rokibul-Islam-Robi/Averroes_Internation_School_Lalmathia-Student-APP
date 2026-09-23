import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// আপনার নতুন প্রজেক্টের নাম অনুযায়ী ইম্পোর্ট পাথ পরিবর্তন করা হয়েছে
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_theme.dart';

import '../wireframe_gloabelclass/wireframe_prefsname.dart';

class WireframeThemecontroler extends GetxController {
  var isdark = false;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  // শেয়ার্ড প্রেফারেন্স থেকে থিম স্টেট নিরাপদে লোড করার মেথড
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // প্রথমবার অ্যাপ ইনস্টল করলেও যেন ক্র্যাশ না করে সেজন্য ?? false দেওয়া হয়েছে
    isdark = prefs.getBool(wireframeDarkMode) ?? false;
    update();
  }

  // থিম পরিবর্তনের মূল মেথড (টাইপ সেফ এবং ডাটা সেভিং সহ)
  Future<void> changeTheme(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (state == true) {
      Get.changeTheme(WireframeMythemes.darkTheme);
      isdark = true;
    } else {
      Get.changeTheme(WireframeMythemes.lightTheme);
      isdark = false;
    }

    // নতুন থিমটি শেয়ার্ড প্রেফারেন্সে সেভ করা হচ্ছে
    await prefs.setBool(wireframeDarkMode, isdark);
    update();
  }
}