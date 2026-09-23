import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// LEADERSHIP MESSAGE PAGE
//
// About page → "Our Leadership" section থেকে chairman/principal card এ ট্যাপ
// করলে এই একই page টা reuse হয় (দুইজনের জন্য আলাদা page না বানিয়ে একটাই
// widget-এ name/designation/photo/message parameter হিসেবে পাঠানো হয়)।
// একদম নিচে school logo + info footer হিসেবে থাকে (About page-এর সাথে সামঞ্জস্যপূর্ণ)।
// ════════════════════════════════════════════════════════════════════════════
class WireframeLeadershipMessage extends StatelessWidget {
  final String name;
  final String designation;
  final String imageAsset;
  final String message;

  const WireframeLeadershipMessage({
    Key? key,
    required this.name,
    required this.designation,
    required this.imageAsset,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    Get.put(WireframeThemecontroler());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(title: designation),
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
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.asset(
                            imageAsset,
                            height: height / 6.5,
                            width: height / 6.5,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: height / 6.5,
                              width: height / 6.5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: WireframeColor.lightgray,
                              ),
                              child: Icon(Icons.person,
                                  size: height / 10, color: WireframeColor.appcolor),
                            ),
                          ),
                        ),
                        SizedBox(height: height / 56),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: sansproBold.copyWith(
                            fontSize: 19,
                            color: themeCtrl.isdark ? WireframeColor.white : WireframeColor.black,
                          ),
                        ),
                        SizedBox(height: height / 200),
                        Text(
                          designation,
                          textAlign: TextAlign.center,
                          style: sansproSemibold.copyWith(fontSize: 13, color: WireframeColor.appcolor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height / 26),
                  const Divider(color: WireframeColor.bggray),
                  SizedBox(height: height / 36),
                  Text(
                    message,
                    textAlign: TextAlign.justify,
                    style: sansproRegular.copyWith(
                      fontSize: 13.5,
                      height: 1.65,
                      color: themeCtrl.isdark ? const Color(0xffCBD5E1) : const Color(0xff64748B),
                    ),
                  ),
                  SizedBox(height: height / 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
