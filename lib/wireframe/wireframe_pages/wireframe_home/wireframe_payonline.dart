import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// Ekhane project name 'averroes_student_app' perfectly bosiye dewa hoyeche
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import '../../wireframe_gloabelclass/wireframe_color.dart';
import '../../wireframe_gloabelclass/wireframe_icons.dart';

import 'page_background.dart';

class WireframePayonline extends StatefulWidget {
  const WireframePayonline({Key? key}) : super(key: key);

  @override
  State<WireframePayonline> createState() => _WireframePayonlineState();
}

class _WireframePayonlineState extends State<WireframePayonline> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: "Pay_online".tr, // Anubad (.tr) bojay rakha hoyeche
      ),
      body: PageBackground(
        category: PageCategory.fees,
        child: Column(
          children: [
            // Appbar-er pechone content jeno dhaka na pore shejonyo spacing
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: height / 36),
                child: Container(
                  decoration: BoxDecoration(
                    color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width / 26,
                      vertical: height / 56,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Date Field ---
                        Padding(
                          padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date".tr,
                                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                              ),
                              TextField(
                                style: sansproSemibold.copyWith(
                                  fontSize: 16,
                                  color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                ),
                                cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                decoration: InputDecoration(
                                  hintText: "01 Feb 2020",
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Image.asset(WireframePngimage.calendericon, height: height / 36),
                                  ),
                                  hintStyle: sansproSemibold.copyWith(
                                    fontSize: 16,
                                    color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: WireframeColor.bggray),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: WireframeColor.bggray),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height / 96),

                        // --- Period Field ---
                        Padding(
                          padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Period".tr,
                                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                              ),
                              TextField(
                                style: sansproSemibold.copyWith(
                                  fontSize: 16,
                                  color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                ),
                                cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                decoration: InputDecoration(
                                  hintText: "01 Feb 2020",
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Image.asset(WireframePngimage.calendericon, height: height / 36),
                                  ),
                                  hintStyle: sansproSemibold.copyWith(
                                    fontSize: 16,
                                    color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: WireframeColor.bggray),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: WireframeColor.bggray),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height / 96),

                        // --- Total Fees Field ---
                        Padding(
                          padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total_fees".tr,
                                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                              ),
                              TextField(
                                style: sansproSemibold.copyWith(
                                  fontSize: 16,
                                  color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                ),
                                cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                decoration: InputDecoration(
                                  hintText: "₹999",
                                  hintStyle: sansproSemibold.copyWith(
                                    fontSize: 16,
                                    color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: WireframeColor.bggray),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: WireframeColor.bggray),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // --- Pay Now Button ---
                        Container(
                          width: width / 1,
                          height: height / 15,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: width / 26),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: width / 1.3,
                                  child: Center(
                                    child: Text(
                                      "PAY_NOW".tr,
                                      style: sansproSemibold.copyWith(fontSize: 16, color: WireframeColor.white),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_forward, size: height / 36, color: WireframeColor.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}