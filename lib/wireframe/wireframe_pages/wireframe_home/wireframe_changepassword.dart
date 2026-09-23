import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// আপনার নতুন প্রজেক্টের নাম অনুযায়ী থিম কন্ট্রোলারের পাথ আপডেট করা হয়েছে
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import '../../wireframe_gloabelclass/wireframe_color.dart';

import 'page_background.dart';

class WireframeChangePassword extends StatefulWidget {
  const WireframeChangePassword({Key? key}) : super(key: key);

  @override
  State<WireframeChangePassword> createState() => _WireframeChangePasswordState();
}

class _WireframeChangePasswordState extends State<WireframeChangePassword> {
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
      resizeToAvoidBottomInset: false,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        // এখানে ট্রান্সলেশন (.tr) যুক্ত করা হয়েছে যেন ল্যাঙ্গুয়েজ চেঞ্জ হলে কাজ করে
        title: 'Change_Password'.tr,
      ),
      body: PageBackground(
        category: PageCategory.profile,
        child: Column(
          children: [
            // স্ট্যাটাস বার ও নচ হ্যান্ডেল করার পারফেক্ট স্পেসিং রাখা হয়েছে
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
                    padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Old Password Field ---
                        Padding(
                          padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Old_Password".tr,
                                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                              ),
                              SizedBox(height: height / 96),
                              SizedBox(
                                height: height / 26,
                                child: TextField(
                                  obscureText: true, // পাসওয়ার্ড ফিল্ডের জন্য এটি দরকার
                                  style: sansproRegular.copyWith(
                                      fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                                  cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                  decoration: InputDecoration(
                                    hintText: "Enter Old Password",
                                    hintStyle: sansproRegular.copyWith(
                                        fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: WireframeColor.bggray),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: WireframeColor.bggray),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height / 36),

                        // --- New Password Field ---
                        Padding(
                          padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "New_Password".tr,
                                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                              ),
                              SizedBox(height: height / 96),
                              SizedBox(
                                height: height / 26,
                                child: TextField(
                                  obscureText: true,
                                  style: sansproRegular.copyWith(
                                      fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                                  cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                  decoration: InputDecoration(
                                    hintText: "Enter New Password",
                                    hintStyle: sansproRegular.copyWith(
                                        fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: WireframeColor.bggray),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: WireframeColor.bggray),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height / 36),

                        // --- Retype Password Field ---
                        Padding(
                          padding: EdgeInsets.only(top: height / 46, bottom: height / 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Retype_Password".tr,
                                style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                              ),
                              SizedBox(height: height / 96),
                              SizedBox(
                                height: height / 26,
                                child: TextField(
                                  obscureText: true,
                                  style: sansproRegular.copyWith(
                                      fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                                  cursorColor: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                  decoration: InputDecoration(
                                    hintText: "Enter Retype Password",
                                    hintStyle: sansproRegular.copyWith(
                                        fontSize: 16, color: themedata.isdark ? WireframeColor.white : WireframeColor.black),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: WireframeColor.bggray),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: WireframeColor.bggray),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height / 26),

                        // --- Change Password Button ---
                        Container(
                          width: width / 1,
                          height: height / 18,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "CHANGE_PASSWORD  ".tr,
                              style: sansproSemibold.copyWith(fontSize: 16, color: WireframeColor.white),
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