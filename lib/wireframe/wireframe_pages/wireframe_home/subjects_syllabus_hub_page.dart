import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_subjects.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/syllabus_page.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUBJECTS & SYLLABUS — hub page with 2 categories
//   1) Subjects  → subjects assigned to the student's class/section
//   2) Syllabus  → subject-wise syllabus documents
// This screen only routes to the existing Subjects and Syllabus pages; none
// of their own logic or UI has been changed.
// ════════════════════════════════════════════════════════════════════════════

class SubjectsSyllabusHubPage extends StatelessWidget {
  const SubjectsSyllabusHubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(title: 'Subjects & Syllabus'),
      body: PageBackground(
        category: PageCategory.syllabus,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "View your class subjects and their syllabus documents.",
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
                      icon: Icons.menu_book_outlined,
                      title: "Subjects".tr,
                      subtitle: "Subjects assigned to your class & section".tr,
                      badgeBg: WireframeColor.subjectsBadgeBg,
                      iconColor: WireframeColor.subjectsBadgeIcon,
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const WireframeSubjects())),
                    ),
                    SizedBox(height: height / 46),
                    _CategoryCard(
                      width: width,
                      height: height,
                      icon: Icons.import_contacts_outlined,
                      title: "Syllabus".tr,
                      subtitle: "Subject-wise syllabus documents".tr,
                      badgeBg: const Color(0xffFCE4D6),
                      iconColor: const Color(0xffC65911),
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const SyllabusListPage())),
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
