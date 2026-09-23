import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/teachers_materials_classes_page.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/teachers_materials_announcements_page.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/teachers_materials_documents_page.dart';

// ════════════════════════════════════════════════════════════════════════════
// TEACHERS MATERIALS — hub page with 3 categories
//   1) Classes            → section/class-wise materials provided by teachers
//   2) Announcements       → important notices from teachers
//   3) Official Documents  → official docs, class materials, performance reports
// ════════════════════════════════════════════════════════════════════════════

class TeachersMaterialsPage extends StatelessWidget {
  const TeachersMaterialsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(title: 'Teachers Materials'),
      body: PageBackground(
        category: PageCategory.teachersMaterials,
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "View classes, notices, and official documents shared by your teachers.",
                style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.white.withAlpha(230)),
              ),
            ),
            SizedBox(height: height / 46),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: WireframeColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 36),
                  children: [
                    _CategoryCard(
                      width: width,
                      height: height,
                      icon: Icons.class_outlined,
                      title: "Classes".tr,
                      subtitle: "Class materials shared by teachers, section & class wise".tr,
                      badgeBg: WireframeColor.subjectsBadgeBg,
                      iconColor: WireframeColor.subjectsBadgeIcon,
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const TeachersMaterialsClassesPage())),
                    ),
                    SizedBox(height: height / 46),
                    _CategoryCard(
                      width: width,
                      height: height,
                      icon: Icons.campaign_outlined,
                      title: "Announcements".tr,
                      subtitle: "Important notices shared by teachers".tr,
                      badgeBg: const Color(0xffFEF3C7),
                      iconColor: const Color(0xffD97706),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const TeachersMaterialsAnnouncementsPage())),
                    ),
                    SizedBox(height: height / 46),
                    _CategoryCard(
                      width: width,
                      height: height,
                      icon: Icons.folder_shared_outlined,
                      title: "Official Documents".tr,
                      subtitle: "Academic documents, class materials & performance reports".tr,
                      badgeBg: const Color(0xffE0E7FF),
                      iconColor: const Color(0xff4F46E5),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const TeachersMaterialsDocumentsPage())),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color badgeBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.width,
    required this.height,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      highlightColor: WireframeColor.transparent,
      splashColor: WireframeColor.transparent,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width / 22, vertical: height / 42),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [badgeBg, Color.lerp(badgeBg, WireframeColor.white, 0.55) ?? badgeBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withAlpha(45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: height / 17,
              width: height / 17,
              decoration: BoxDecoration(
                color: WireframeColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            SizedBox(width: width / 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: sansproSemibold.copyWith(fontSize: 15.5, color: WireframeColor.black),
                  ),
                  SizedBox(height: height / 250),
                  Text(
                    subtitle,
                    style: sansproRegular.copyWith(fontSize: 11.5, color: WireframeColor.appgray),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: iconColor),
          ],
        ),
      ),
    );
  }
}
