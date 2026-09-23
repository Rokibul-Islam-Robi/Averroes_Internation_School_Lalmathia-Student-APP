import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_academic_info.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'driver_controller.dart';
import 'driver_live_bus_map_page.dart';
import 'driver_qr_scan_page.dart';
import 'driver_trip_history_page.dart';
import 'driver_support_page.dart';

// ════════════════════════════════════════════════════════════════════════════
// DRIVER APP DRAWER — CORPORATE NAVIGATION SIDEBAR
//
// Mirroring the Student App Drawer design with Driver Profile, Transport Tools,
// Help & Support, Dark Mode toggle, and Logout flow.
// ════════════════════════════════════════════════════════════════════════════
class DriverAppDrawer extends StatelessWidget {
  const DriverAppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final driverCtrl = Get.isRegistered<DriverController>()
        ? Get.find<DriverController>()
        : Get.put(DriverController());
    final themedata = Get.put(WireframeThemecontroler());

    return Drawer(
      backgroundColor: themedata.isdark ? WireframeColor.black : WireframeColor.white,
      width: width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            _DriverDrawerHeader(driverCtrl: driverCtrl, height: height, width: width),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: height / 60),
                children: [
                  _drawerItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    label: 'Driver Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.map_rounded,
                    label: 'Live Bus Map',
                    onTap: () => _navigate(context, const DriverLiveBusMapPage()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Scan Student QR',
                    onTap: () {
                      final trip = driverCtrl.activeTrip.value;
                      if (trip == null || trip.status != 'running') {
                        Navigator.pop(context);
                        Get.snackbar('Notice', 'Please start a trip first before scanning student QR.');
                        return;
                      }
                      _navigate(context, const DriverQrScanPage());
                    },
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.history_toggle_off_rounded,
                    label: 'Trip History',
                    onTap: () => _navigate(context, const DriverTripHistoryPage()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 80),
                    child: const Divider(color: WireframeColor.bggray),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    label: 'Help & Support',
                    accent: const Color(0xff16A34A),
                    onTap: () => _navigate(context, const DriverSupportPage()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: themedata.isdark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    label: themedata.isdark ? 'Light Mode' : 'Dark Mode',
                    accent: const Color(0xff6366F1),
                    onTap: () {
                      themedata.isdark = !themedata.isdark;
                      themedata.update();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 90),
              child: const Divider(color: WireframeColor.bggray),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: height / 50, top: height / 150),
              child: _drawerItem(
                context: context,
                icon: Icons.logout_rounded,
                label: 'Logout',
                accent: WireframeColor.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout(context, driverCtrl);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _confirmLogout(BuildContext context, DriverController driverCtrl) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Center(
          child: Text(
            'Averroes Transport Portal',
            textAlign: TextAlign.center,
            style: sansproSemibold.copyWith(fontSize: 17),
          ),
        ),
        content: Text(
          'Are you sure you want to logout from the Driver account?',
          textAlign: TextAlign.center,
          style: sansproRegular.copyWith(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffE2E8F0),
              foregroundColor: const Color(0xff334155),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: sansproSemibold.copyWith(fontSize: 13)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WireframeColor.appcolor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              final nav = Navigator.of(dialogContext);
              await driverCtrl.logout();
              await WireframeSession.clearSession();
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WireframeAcademicInfo()),
                (route) => false,
              );
            },
            child: Text('Logout', style: sansproSemibold.copyWith(fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color accent = WireframeColor.appcolor,
  }) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap,
      highlightColor: accent.withAlpha(18),
      splashColor: accent.withAlpha(18),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 90),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accent.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: height / 42, color: accent),
            ),
            SizedBox(width: width / 26),
            Expanded(
              child: Text(
                label,
                style: sansproSemibold.copyWith(fontSize: 14.5, color: const Color(0xff0F172A)),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: height / 42, color: WireframeColor.textgray),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DRAWER HEADER — SCHOOL LOGO & DRIVER IDENTITY PROFILE CARD
// ════════════════════════════════════════════════════════════════════════════
class _DriverDrawerHeader extends StatelessWidget {
  final DriverController driverCtrl;
  final double height;
  final double width;

  const _DriverDrawerHeader({
    required this.driverCtrl,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(width / 24, height / 56, width / 24, height / 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0B1E4D), WireframeColor.appcolor, WireframeColor.lightappcolor],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── School Brand Header (Round Logo + Title) ──
          Center(
            child: Column(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      WireframePngimage.averroesLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Averroes International School',
                  textAlign: TextAlign.center,
                  style: sansproBold.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Driver Transport Portal',
                  textAlign: TextAlign.center,
                  style: sansproRegular.copyWith(
                    color: Colors.white.withAlpha(210),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height / 50),

          // ── Driver Identity Card (White Floating Card with Photo) ──
          Obx(() {
            final user = driverCtrl.driverUser.value;
            final name = user?.name.isNotEmpty == true ? user!.name : 'Assigned Driver';
            final username = user?.username.isNotEmpty == true ? user!.username : 'driver17';
            final phone = user?.phone ?? '01796409920';
            final photo = user?.photoUrl ?? '';

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: WireframeColor.appcolor.withAlpha(50), width: 1.8),
                    ),
                    child: ClipOval(
                      child: photo.isNotEmpty
                          ? Image.network(
                              photo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
                            )
                          : Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: sansproBold.copyWith(
                            fontSize: 14.5,
                            color: const Color(0xff0B1E4D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'UID: $username  ·  $phone',
                          style: sansproRegular.copyWith(
                            fontSize: 11.5,
                            color: const Color(0xff64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
