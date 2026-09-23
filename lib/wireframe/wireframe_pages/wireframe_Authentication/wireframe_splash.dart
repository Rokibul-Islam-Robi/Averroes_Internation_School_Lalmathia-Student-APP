import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_login.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_home.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_driver/driver_controller.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_driver/driver_dashboard_page.dart';

import '../../wireframe_gloabelclass/wireframe_icons.dart';

class WireframeSplash extends StatefulWidget {
  const WireframeSplash({Key? key}) : super(key: key);

  @override
  State<WireframeSplash> createState() => _WireframeSplashState();
}

class _WireframeSplashState extends State<WireframeSplash> {
  @override
  void initState() {
    super.initState();
    goup();
  }

  // ── Persistent session check — user manually "Logout" na chapa porjonto
  // login-e thakbe, tai app abar khule sorasori dashboard-e niye jaoya hocche
  // (kono session na thakle normal Login page dekhabe, kono bypass/demo
  // session toiri kora hocche na)। ──
  Future<void> goup() async {
    try {
      // Parallelize minimal splash transition with session loading
      final results = await Future.wait([
        Future.delayed(const Duration(milliseconds: 1400)),
        WireframeSession.getSession(),
      ]);

      if (!mounted) return;

      final session = results[1] as Map<String, String>?;

      if (session != null &&
          session['role'] == 'student' &&
          session['token'] != null &&
          session['token']!.isNotEmpty) {
        WireframeLogin.activateStudentControllers(session['token']!);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WireframeHome()),
          );
        }
        return;
      }

      if (session != null &&
          session['role'] == 'driver' &&
          session['token'] != null &&
          session['token']!.isNotEmpty) {
        final driverCtrl = Get.put(DriverController());
        driverCtrl.setAuthToken(session['token']!);
        driverCtrl.fetchDashboard();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DriverDashboardPage()),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint("Splash error: $e");
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WireframeLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.16),
          child: Image.asset(
            WireframePngimage.averroesLogo,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
