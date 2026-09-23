import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'page_background.dart';

class WireframeDatesheet extends StatefulWidget {
  const WireframeDatesheet({Key? key}) : super(key: key);

  @override
  State<WireframeDatesheet> createState() => _WireframeDatesheetState();
}

class _WireframeDatesheetState extends State<WireframeDatesheet> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  final themedata = Get.put(WireframeThemecontroler());

  List date = ["11", "13", "15", "18", "20", "22", "25"];
  List sub = [
    "Science",
    "English",
    "Hindi",
    "Math",
    "Social Study",
    "Drawing",
    "Computer"
  ];
  List day = [
    "Monday",
    "Wednesday",
    "Friday",
    "Monday",
    "Wednesday",
    "Friday",
    "Monday"
  ];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      // ── এখানে leading প্যারামিটারটি ফেলে দিয়ে এরর ফিক্স করা হলো ──
      appBar: PageAppBar(
        title: "Date_Sheet".tr,
      ),
      body: PageBackground(
        category: PageCategory.examination,
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: height / 36),
                  child: Container(
                    decoration: BoxDecoration(
                        color: themedata.isdark
                            ? WireframeColor.black
                            : WireframeColor.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 26, vertical: height / 56),
                        child: SingleChildScrollView( // স্ক্রোলিং সেফটি এর জন্য যুক্ত করা হলো
                          child: Column(
                            children: [
                              ListView.builder(
                                itemCount: sub.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                date[index],
                                                style: sansproSemibold.copyWith(fontSize: 26),
                                              ),
                                              Text(
                                                "JAN",
                                                style: sansproSemibold.copyWith(fontSize: 13),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: width / 20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sub[index],
                                                style: sansproSemibold.copyWith(fontSize: 16),
                                              ),
                                              SizedBox(height: height / 200),
                                              Text(
                                                day[index],
                                                style: sansproRegular.copyWith(
                                                    fontSize: 12,
                                                    color: WireframeColor.textgray),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.watch_later_outlined,
                                            size: height / 36,
                                            color: WireframeColor.textgray,
                                          ),
                                          SizedBox(width: width / 56),
                                          Text(
                                            "09:00 AM",
                                            style: sansproRegular.copyWith(
                                                fontSize: 13,
                                                color: WireframeColor.textgray),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height / 120),
                                      const Divider(color: WireframeColor.textgray, indent: 45),
                                      SizedBox(height: height / 120),
                                    ],
                                  );
                                },
                              )
                            ],
                          ),
                        )),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}