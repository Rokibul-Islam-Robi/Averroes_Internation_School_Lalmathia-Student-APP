import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart'; // আপনার কাস্টম ব্যাকগ্রাউন্ড ইমপোর্ট

class WireframeHoliday extends StatefulWidget {
  const WireframeHoliday({Key? key}) : super(key: key);

  @override
  State<WireframeHoliday> createState() => _WireframeHolidayState();
}

class _WireframeHolidayState extends State<WireframeHoliday> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());

  DateTime? _selectedDay;
  String? selectdate;

  // আপনার পরামর্শ অনুযায়ী ৩টি আলাদা List-কে ১টি Map-এর List-এ রূপান্তর করা হয়েছে
  // একই সাথে প্রজেক্টের রিকোয়ারমেন্ট অনুযায়ী বাংলাদেশের ছুটির তালিকা যুক্ত করা হয়েছে
  final List<Map<String, String>> holidayList = [
    {
      "name": "Language Martyrs' Day",
      "date": "21st February",
      "day": "Saturday"
    },
    {
      "name": "Independence Day",
      "date": "26th March",
      "day": "Thursday"
    },
    {
      "name": "Eid-ul-Fitr",
      "date": "31st March", // চাঁদ দেখার ওপর নির্ভরশীল
      "day": "Tuesday"
    },
    {
      "name": "Victory Day",
      "date": "16th December",
      "day": "Wednesday"
    }
  ];

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Holiday'.tr, // লোকালাইজেশন বজায় রাখা হয়েছে
      ),
      body: PageBackground(
        category: PageCategory.holiday,
        child: Column(
          children: [
            // অ্যাপবারের নিচে সঠিক স্পেসিং মেইনটেইন করার জন্য
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: SingleChildScrollView(
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
                          TableCalendar(
                            firstDay: DateTime.now(),
                            focusedDay: DateTime.now(),
                            lastDay: DateTime.utc(2050, 3, 14),
                            headerVisible: true,
                            daysOfWeekVisible: true,
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: WireframeColor.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              todayTextStyle: const TextStyle(
                                color: WireframeColor.white,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: WireframeColor.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              selectedTextStyle: const TextStyle(
                                color: WireframeColor.white,
                              ),
                            ),
                            shouldFillViewport: false,
                            currentDay: _selectedDay,
                            calendarFormat: CalendarFormat.month,
                            pageAnimationEnabled: false,
                            headerStyle: HeaderStyle(
                              leftChevronIcon: SizedBox(
                                height: height / 26,
                                width: height / 26,
                                child: Icon(
                                  Icons.chevron_left,
                                  color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                ),
                              ),
                              rightChevronIcon: SizedBox(
                                height: height / 26,
                                width: height / 26,
                                child: Icon(
                                  Icons.chevron_right,
                                  color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                                ),
                              ),
                              formatButtonVisible: false,
                              decoration: const BoxDecoration(
                                color: WireframeColor.transparent,
                              ),
                              titleCentered: true,
                              titleTextStyle: sansproRegular.copyWith(
                                fontSize: 15,
                                color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                              ),
                            ),
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                selectdate = _selectedDay.toString();
                              });
                            },
                          ),
                          SizedBox(height: height / 26),
                          Text(
                            "List_of_Holiday".tr,
                            style: sansproSemibold.copyWith(fontSize: 16),
                          ),
                          SizedBox(height: height / 36),
                          ListView.builder(
                            itemCount: holidayList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero, // ডিফল্ট প্যাডিং রিমুভ করা হয়েছে
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: height / 36),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: WireframeColor.bggray),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width / 26,
                                    vertical: height / 70,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        holidayList[index]["name"] ?? "",
                                        style: sansproSemibold.copyWith(fontSize: 16),
                                      ),
                                      SizedBox(height: height / 96),
                                      Row(
                                        children: [
                                          Text(
                                            holidayList[index]["date"] ?? "",
                                            style: sansproRegular.copyWith(
                                              fontSize: 14,
                                              color: WireframeColor.textgray,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            holidayList[index]["day"] ?? "",
                                            style: sansproRegular.copyWith(
                                              fontSize: 14,
                                              color: WireframeColor.textgray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
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