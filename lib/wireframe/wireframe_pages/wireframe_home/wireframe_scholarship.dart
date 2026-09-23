import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// SCHOLARSHIP PAGE
//
// Side drawer → "Scholarship" থেকে আসা static info page — School_Facilities
// page-এর মতোই একই লেআউট প্যাটার্ন অনুসরণ করা হয়েছে।
// ════════════════════════════════════════════════════════════════════════════
class WireframeScholarship extends StatelessWidget {
  const WireframeScholarship({Key? key}) : super(key: key);

  static const List<Map<String, dynamic>> _scholarships = [
    {
      'icon': Icons.emoji_events_outlined,
      'title': 'Scholarship_Merit',
      'desc': 'Scholarship_Merit_Desc',
    },
    {
      'icon': Icons.family_restroom_outlined,
      'title': 'Scholarship_Sibling',
      'desc': 'Scholarship_Sibling_Desc',
    },
    {
      'icon': Icons.menu_book_outlined,
      'title': 'Scholarship_Hifz',
      'desc': 'Scholarship_Hifz_Desc',
    },
    {
      'icon': Icons.volunteer_activism_outlined,
      'title': 'Scholarship_Need_Based',
      'desc': 'Scholarship_Need_Based_Desc',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    Get.put(WireframeThemecontroler());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(title: 'Scholarship'.tr),
      body: PageBackground(
        category: PageCategory.general,
        child: GetBuilder<WireframeThemecontroler>(
          builder: (themeCtrl) {
            return Container(
              margin: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
              ),
              decoration: BoxDecoration(
                color: themeCtrl.isdark ? WireframeColor.black : WireframeColor.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: width / 26,
                  vertical: height / 36,
                ),
                children: [
                  Text(
                    'Scholarship_Intro'.tr,
                    style: sansproRegular.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: themeCtrl.isdark ? WireframeColor.white : WireframeColor.black,
                    ),
                  ),
                  SizedBox(height: height / 36),
                  ..._scholarships.map(
                    (s) => Padding(
                      padding: EdgeInsets.only(bottom: height / 56),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width / 36,
                          vertical: height / 56,
                        ),
                        decoration: BoxDecoration(
                          color: themeCtrl.isdark
                              ? WireframeColor.lightblack
                              : WireframeColor.lightgray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: WireframeColor.appcolor.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(s['icon'] as IconData,
                                  size: height / 40, color: WireframeColor.appcolor),
                            ),
                            SizedBox(width: width / 36),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (s['title'] as String).tr,
                                    style: sansproSemibold.copyWith(
                                      fontSize: 14,
                                      color: themeCtrl.isdark
                                          ? WireframeColor.white
                                          : WireframeColor.black,
                                    ),
                                  ),
                                  SizedBox(height: height / 250),
                                  Text(
                                    (s['desc'] as String).tr,
                                    style: sansproRegular.copyWith(
                                        fontSize: 12.5, color: WireframeColor.textgray),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height / 56),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width / 30,
                      vertical: height / 46,
                    ),
                    decoration: BoxDecoration(
                      color: WireframeColor.appcolor.withAlpha(18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WireframeColor.appcolor.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: height / 40, color: WireframeColor.appcolor),
                        SizedBox(width: width / 36),
                        Expanded(
                          child: Text(
                            'Scholarship_Contact_Note'.tr,
                            style: sansproRegular.copyWith(
                              fontSize: 12.5,
                              color: themeCtrl.isdark ? WireframeColor.white : WireframeColor.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
