import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// আপনার প্রজেক্টের সঠিক নাম দিয়ে import path ঠিক করুন
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';

import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart'; // এই কাস্টম উইজেট ফাইলটি ইমপোর্ট করুন

class WireframeAssignment extends StatefulWidget {
  const WireframeAssignment({Key? key}) : super(key: key);

  @override
  State<WireframeAssignment> createState() => _WireframeAssignmentState();
}

class _WireframeAssignmentState extends State<WireframeAssignment> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());

  List lec = ["Surface Areas and Volumes", "Structure of Atoms", "My Bestfriend Essay"];
  List sub = ["Mathematics", "Science", "English"];
  List assigndate = ["10 Nov 20", "10 Oct 20", "10 Sep 20"];
  List lastdate = ["10 Dec 20", "30 Oct 20", "30 Sep 20"];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true, // এটি ১ নং কোডের মতো অ্যাপবারের পেছনের কন্টেন্ট প্রসারিত করবে
      backgroundColor: WireframeColor.appcolor,
      appBar: AppBar(
        backgroundColor: WireframeColor.transparent, // কাস্টম ব্যাকগ্রাউন্ড দেখতে ট্রান্সপারেন্ট রাখুন
        elevation: 0, // শ্যাডো সরিয়ে ফেলুন
        leadingWidth: width / 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              InkWell(
                highlightColor: WireframeColor.transparent,
                splashColor: WireframeColor.transparent,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios_new, size: height / 36, color: WireframeColor.white),
              ),
              SizedBox(width: width / 36),
              Text("Assignment".tr, style: sansproRegular.copyWith(fontSize: 18, color: WireframeColor.white)),
            ],
          ),
        ),
      ),
      body: PageBackground( // এই কাস্টম উইজেটটি ব্যবহার করুন (১ নং কোডের মতো)
        category: PageCategory.homework,
        child: SingleChildScrollView(
          child: Padding(
            // ১ নং কোডের মতো ডায়নামিক টপ প্যাডিং
            padding: EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            child: Container(
              decoration: BoxDecoration(
                color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 56),
                child: ListView.builder(
                  itemCount: sub.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: height / 36),
                      decoration: BoxDecoration(
                        border: Border.all(color: WireframeColor.bggray),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 56),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffE6EFFF),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 150),
                                child: Text(
                                  sub[index],
                                  style: sansproSemibold.copyWith(fontSize: 14, color: WireframeColor.appcolor),
                                ),
                              ),
                            ),
                            SizedBox(height: height / 46),
                            Text(lec[index], style: sansproSemibold.copyWith(fontSize: 14)),
                            SizedBox(height: height / 46),
                            Row(
                              children: [
                                Text("Assign_Date".tr, style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.appgray)),
                                const Spacer(),
                                Text(assigndate[index], style: sansproSemibold.copyWith(fontSize: 14)),
                              ],
                            ),
                            SizedBox(height: height / 40),
                            Row(
                              children: [
                                Text("Last_Submission_Date".tr, style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.appgray)),
                                const Spacer(),
                                Text(lastdate[index], style: sansproSemibold.copyWith(fontSize: 14)),
                              ],
                            ),
                            SizedBox(height: height / 36),
                            Container(
                              width: width, // 'width/1' এর পরিবর্তে শুধু 'width' ব্যবহার করুন
                              height: height / 18,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "To_be_Submitted".tr,
                                  style: sansproSemibold.copyWith(fontSize: 16, color: WireframeColor.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}