import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// SCHOOL FACILITIES PAGE
//
// Side drawer → "School Facilities" থেকে আসা static info page — কোনো API
// call নেই, About page-এর মতোই simple ListView-based লেআউট।
// ════════════════════════════════════════════════════════════════════════════
class WireframeFacilities extends StatelessWidget {
  const WireframeFacilities({Key? key}) : super(key: key);

  static const List<Map<String, dynamic>> _facilities = [
    {
      'icon': Icons.smart_display_outlined,
      'title': 'Facility_Smart_Classrooms',
      'desc': 'Facility_Smart_Classrooms_Desc',
    },
    {
      'icon': Icons.science_outlined,
      'title': 'Facility_Science_Labs',
      'desc': 'Facility_Science_Labs_Desc',
    },
    {
      'icon': Icons.menu_book_outlined,
      'title': 'Facility_Library',
      'desc': 'Facility_Library_Desc',
    },
    {
      'icon': Icons.directions_bus_filled_outlined,
      'title': 'Facility_Transport',
      'desc': 'Facility_Transport_Desc',
    },
    {
      'icon': Icons.sports_soccer_outlined,
      'title': 'Facility_Sports',
      'desc': 'Facility_Sports_Desc',
    },
    {
      'icon': Icons.mosque_outlined,
      'title': 'Facility_Prayer_Hall',
      'desc': 'Facility_Prayer_Hall_Desc',
    },
    {
      'icon': Icons.restaurant_outlined,
      'title': 'Facility_Cafeteria',
      'desc': 'Facility_Cafeteria_Desc',
    },
    {
      'icon': Icons.medical_services_outlined,
      'title': 'Facility_Medical_Room',
      'desc': 'Facility_Medical_Room_Desc',
    },
    {
      'icon': Icons.videocam_outlined,
      'title': 'Facility_Security',
      'desc': 'Facility_Security_Desc',
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
      appBar: PageAppBar(title: 'School_Facilities'.tr),
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
                    'School_Facilities_Intro'.tr,
                    style: sansproRegular.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: themeCtrl.isdark ? WireframeColor.white : WireframeColor.black,
                    ),
                  ),
                  SizedBox(height: height / 36),
                  ..._facilities.map(
                    (f) => Padding(
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
                              child: Icon(f['icon'] as IconData,
                                  size: height / 40, color: WireframeColor.appcolor),
                            ),
                            SizedBox(width: width / 36),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (f['title'] as String).tr,
                                    style: sansproSemibold.copyWith(
                                      fontSize: 14,
                                      color: themeCtrl.isdark
                                          ? WireframeColor.white
                                          : WireframeColor.black,
                                    ),
                                  ),
                                  SizedBox(height: height / 250),
                                  Text(
                                    (f['desc'] as String).tr,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
