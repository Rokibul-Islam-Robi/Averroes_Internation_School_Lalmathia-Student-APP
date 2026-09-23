import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_academic_info.dart';
import 'student_controller.dart';
import 'fees_overview_page.dart';
import 'wireframe_about.dart';
import 'wireframe_facilities.dart';
import 'wireframe_profile.dart';
import 'wireframe_scholarship.dart';
import 'wireframe_support.dart';
import 'appointment_page.dart';
import 'id_card_replacement_page.dart';

// ════════════════════════════════════════════════════════════════════════════
// APP SIDE DRAWER (আগের 3-dot PopupMenuButton-এর জায়গায় এখন modern corporate
// sidebar/drawer)।
//
// গঠন:
//   1) Header — "E-Student" brand badge + student photo/name/class (tap করলে
//      Profile page-এ যায়)
//   2) Menu list — Profile, About, School Facilities, School Fees,
//      Scholarship, Help & Support, Settings
//   3) নিচে Logout — আগের মতোই confirmation dialog দেখিয়ে
//      WireframeAcademicInfo (login flow) এ পাঠায়।
// ════════════════════════════════════════════════════════════════════════════
class WireframeAppDrawer extends StatelessWidget {
  const WireframeAppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final studentCtrl = Get.put(StudentController());

    return Drawer(
      backgroundColor: WireframeColor.white,
      width: width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(studentCtrl: studentCtrl, height: height, width: width),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: height / 56),
                children: [
                  _drawerItem(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    label: "Profile".tr,
                    onTap: () => _navigate(context, const WireframeProfile()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    label: "About".tr,
                    onTap: () => _navigate(context, const WireframeAbout()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.apartment_rounded,
                    label: "School_Facilities".tr,
                    onTap: () => _navigate(context, const WireframeFacilities()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.payments_outlined,
                    label: "School_Fees".tr,
                    onTap: () => _navigate(context, const FeesOverviewPage()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.school_outlined,
                    label: "Scholarship".tr,
                    onTap: () => _navigate(context, const WireframeScholarship()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.event_available_rounded,
                    label: "Appointment".tr,
                    onTap: () => _navigate(context, const AppointmentPage()),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.badge_outlined,
                    label: "ID Card Replacement",
                    onTap: () => _navigate(context, const IdCardReplacementPage()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 70),
                    child: const Divider(color: WireframeColor.bggray),
                  ),
                  _drawerItem(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    label: "Help_Support".tr,
                    onTap: () => _navigate(context, const WireframeSupport()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 90),
              child: const Divider(color: WireframeColor.bggray),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: height / 46, top: height / 150),
              child: _drawerItem(
                context: context,
                icon: Icons.logout_rounded,
                label: "Logout".tr,
                accent: WireframeColor.red,
                onTap: () {
                  Navigator.pop(context); // আগে drawer বন্ধ করা হচ্ছে
                  _confirmLogout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── drawer বন্ধ করে পেজে navigate করার helper ──
  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Logout confirmation — আগে wireframe_home.dart এর onbackpressed()-এ যেমন ছিল ঠিক সেভাবেই ──
  Future<void> _confirmLogout(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Center(
          child: Text(
            "Averroes International School",
            textAlign: TextAlign.end,
            style: sansproSemibold.copyWith(fontSize: 18),
          ),
        ),
        content: Text(
          "Are_You_sure_to_logout_from_this_app".tr,
          style: sansproRegular.copyWith(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: WireframeColor.appcolor),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("No", style: sansproSemibold.copyWith(color: WireframeColor.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(dialogContext);
              if (Get.isRegistered<StudentController>()) {
                await Get.find<StudentController>().logout();
              }
              await WireframeSession.clearSession();

              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WireframeAcademicInfo()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: WireframeColor.appcolor),
            child: Text("Yes", style: sansproSemibold.copyWith(color: WireframeColor.white)),
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
                style: sansproSemibold.copyWith(fontSize: 15, color: WireframeColor.black),
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
// Drawer header — School Logo & 2-Line Name + Student Identity White Card
// ════════════════════════════════════════════════════════════════════════════
class _DrawerHeader extends StatelessWidget {
  final StudentController studentCtrl;
  final double height;
  final double width;

  const _DrawerHeader({
    required this.studentCtrl,
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
          // ── School Brand Header (Small Round Logo + 2-line Name) ──
          Center(
            child: Column(
              children: [
                Container(
                  height: 52,
                  width: 52,
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
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        color: WireframeColor.appcolor,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Averroes International",
                  textAlign: TextAlign.center,
                  style: sansproBold.copyWith(
                    fontSize: 14.5,
                    height: 1.2,
                    letterSpacing: 0.3,
                    color: WireframeColor.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "School Lalmatia",
                  textAlign: TextAlign.center,
                  style: sansproBold.copyWith(
                    fontSize: 12.5,
                    height: 1.2,
                    letterSpacing: 0.5,
                    color: const Color(0xffFFC94D),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height / 52),

          // ── Student Identity Card (Modern Floating Card System) ──
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const WireframeProfile()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Obx(() {
                    final profile = studentCtrl.profile.value;
                    return Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: WireframeColor.appcolor.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WireframeColor.appcolor.withAlpha(60),
                          width: 1.5,
                        ),
                        image: (profile != null && profile.profilePhotoUrl.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(profile.profilePhotoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (profile == null || profile.profilePhotoUrl.isEmpty)
                          ? const Icon(Icons.person_rounded,
                              color: WireframeColor.appcolor, size: 24)
                          : null,
                    );
                  }),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      final profile = studentCtrl.profile.value;
                      final String name = profile?.studentName.isNotEmpty == true
                          ? profile!.studentName
                          : "Hi Student".tr;
                      final String studentId = profile?.studentId.isNotEmpty == true
                          ? profile!.studentId
                          : "";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: name,
                              style: sansproBold.copyWith(
                                fontSize: 14,
                                color: const Color(0xff0F172A),
                              ),
                              children: [
                                if (studentId.isNotEmpty)
                                  TextSpan(
                                    text: " ($studentId)",
                                    style: sansproRegular.copyWith(
                                      fontSize: 11.5,
                                      color: const Color(0xff64748B),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            profile != null
                                ? "${profile.currentAcademicSession.isNotEmpty ? '${profile.currentAcademicSession} | ' : ''}Class: ${profile.className.isNotEmpty ? profile.className : '—'}${profile.section.isNotEmpty ? ' | Section: ${profile.section}' : ''}"
                                : "View Profile".tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sansproRegular.copyWith(
                              fontSize: 11,
                              color: const Color(0xff64748B),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xff94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
