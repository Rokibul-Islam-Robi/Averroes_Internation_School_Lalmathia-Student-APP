import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import '../../wireframe_gloabelclass/wireframe_icons.dart';

import 'page_background.dart';
import 'wireframe_leadership_message.dart';

// ════════════════════════════════════════════════════════════════════════════
// ABOUT PAGE
//
// 3-dot AppBar মেনু থেকে আসা "About" entry — school name, official address,
// school-এর ইতিহাস এবং leadership info দেখায়। এটা পুরোপুরি static (কোনো API
// call নেই), তাই কোনো controller/loading state লাগে না।
// ════════════════════════════════════════════════════════════════════════════
class WireframeAbout extends StatelessWidget {
  const WireframeAbout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Get.put() এখানে controller register করার জন্য call করা হচ্ছে (যদি আগে
    // থেকে registered না থাকে), কিন্তু variable হিসেবে রাখা হয়নি কারণ নিচে
    // GetBuilder নিজের themeCtrl ব্যবহার করে — তাই const local variable
    // hold করার দরকার নেই (unused_local_variable warning এড়াতে)।
    Get.put(WireframeThemecontroler());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'About'.tr, // Localization support এর জন্য .tr রাখা ভালো
      ),
      body: PageBackground(
        category: PageCategory.general,
        child: GetBuilder<WireframeThemecontroler>(
          builder: (themeCtrl) {
            return Container(
              margin: EdgeInsets.only(
                // AppBar এবং Status bar এর নিচে যেন কন্টেন্ট না ঢেকে যায়
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
              ),
              decoration: BoxDecoration(
                color: themeCtrl.isdark ? WireframeColor.black : WireframeColor.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              // Column-এর জায়গায় ListView ব্যবহার করায় স্ক্রিন ছোট হলেও স্ক্রোল হবে, কোনো ওভারফ্লো হবে না
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: width / 26,
                  vertical: height / 36,
                ),
                children: [
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            WireframePngimage.averroesLogo,
                            height: height / 8,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.school,
                              size: height / 8,
                              color: WireframeColor.appcolor,
                            ),
                          ),
                        ),
                        SizedBox(height: height / 56),
                        Text(
                          "Averroes International School Lalmatia",
                          textAlign: TextAlign.center,
                          style: sansproBold.copyWith(
                            fontSize: 19,
                            color: themeCtrl.isdark
                                ? WireframeColor.white
                                : WireframeColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height / 26),
                  const Divider(color: WireframeColor.bggray),
                  SizedBox(height: height / 36),
                  Text(
                    "About_App_Description".tr,
                    textAlign: TextAlign.justify,
                    style: sansproRegular.copyWith(
                      fontSize: 13.5,
                      height: 1.6,
                      color: themeCtrl.isdark
                          ? const Color(0xffCBD5E1)
                          : const Color(0xff64748B),
                    ),
                  ),
                  SizedBox(height: height / 36),

                  // ── School Address — নতুন যোগ করা হলো ──
                  const Divider(color: WireframeColor.bggray),
                  SizedBox(height: height / 36),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: height / 40, color: WireframeColor.appcolor),
                      SizedBox(width: width / 36),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "School_Address".tr,
                              style: sansproSemibold.copyWith(
                                fontSize: 14,
                                color: themeCtrl.isdark
                                    ? WireframeColor.white
                                    : WireframeColor.black,
                              ),
                            ),
                            SizedBox(height: height / 200),
                            Text(
                              "School_Address_Value".tr,
                              style: sansproRegular.copyWith(
                                  fontSize: 13, color: WireframeColor.textgray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Our Leadership — Chairman & Principal card গুলো, ট্যাপ
                  // করলে সংশ্লিষ্ট leadership message page-এ নিয়ে যায় ──────────
                  SizedBox(height: height / 26),
                  const Divider(color: WireframeColor.bggray),
                  SizedBox(height: height / 36),
                  Text(
                    "Our_Leadership".tr,
                    style: sansproSemibold.copyWith(
                      fontSize: 15,
                      color: themeCtrl.isdark ? WireframeColor.white : WireframeColor.black,
                    ),
                  ),
                  SizedBox(height: height / 46),
                  _LeadershipCard(
                    name: "Khan Md Aktaruzzaman",
                    designation: "Founding_Chairman_MD".tr,
                    imageAsset: WireframePngimage.chairmanPhoto,
                    message: "Chairman_Message".tr,
                    isDark: themeCtrl.isdark,
                    height: height,
                    width: width,
                  ),
                  SizedBox(height: height / 56),
                  _LeadershipCard(
                    name: "Dalia Nowrin",
                    designation: "Principal".tr,
                    imageAsset: WireframePngimage.principalPhoto,
                    message: "Principal_Message".tr,
                    isDark: themeCtrl.isdark,
                    height: height,
                    width: width,
                  ),

                  SizedBox(height: height / 26),
                  const Divider(color: WireframeColor.bggray),
                  SizedBox(height: height / 36),
                  Text(
                    "© 2026 Averroes International School Lalmatia",
                    textAlign: TextAlign.center,
                    style: sansproRegular.copyWith(
                      fontSize: 12,
                      color: WireframeColor.textgray,
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

// ════════════════════════════════════════════════════════════════════════════
// Leadership card উইজেট — photo + name + designation + "Read Message" arrow
// button, ট্যাপ করলে WireframeLeadershipMessage page-এ নিয়ে যায়।
// ════════════════════════════════════════════════════════════════════════════
class _LeadershipCard extends StatelessWidget {
  final String name;
  final String designation;
  final String imageAsset;
  final String message;
  final bool isDark;
  final double height;
  final double width;

  const _LeadershipCard({
    required this.name,
    required this.designation,
    required this.imageAsset,
    required this.message,
    required this.isDark,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WireframeLeadershipMessage(
            name: name,
            designation: designation,
            imageAsset: imageAsset,
            message: message,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 56),
        decoration: BoxDecoration(
          color: isDark ? WireframeColor.lightblack : WireframeColor.lightgray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                imageAsset,
                height: height / 16,
                width: height / 16,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: height / 16,
                  width: height / 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: WireframeColor.white,
                  ),
                  child: Icon(Icons.person, color: WireframeColor.appcolor, size: height / 24),
                ),
              ),
            ),
            SizedBox(width: width / 36),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: sansproSemibold.copyWith(
                      fontSize: 14,
                      color: isDark ? WireframeColor.white : WireframeColor.black,
                    ),
                  ),
                  SizedBox(height: height / 250),
                  Text(
                    designation,
                    style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: WireframeColor.appcolor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: height / 46, color: WireframeColor.appcolor),
            ),
          ],
        ),
      ),
    );
  }
}