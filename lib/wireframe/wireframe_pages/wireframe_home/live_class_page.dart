import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';
import 'live_now_card.dart';
import 'live_class_controller.dart';

class LiveClassPage extends StatefulWidget {
  const LiveClassPage({super.key});

  @override
  State<LiveClassPage> createState() => _LiveClassPageState();
}

class _LiveClassPageState extends State<LiveClassPage> {
  final themedata = Get.put(WireframeThemecontroler());
  final liveCtrl = Get.put(LiveClassController());
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    liveCtrl.fetchTodayLiveClasses();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Live Now'.tr,
      ),
      body: PageBackground(
        category: PageCategory.liveClass,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Obx(() {
                  return RefreshIndicator(
                    onRefresh: liveCtrl.refreshLiveClasses,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 26, vertical: height / 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Live Class Card
                          LiveNowCard(width: width, height: height),

                          SizedBox(height: height / 30),

                          // Section Header & View History Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Live Classes".tr,
                                style: sansproBold.copyWith(
                                  fontSize: 18,
                                  color: themedata.isdark
                                      ? WireframeColor.white
                                      : WireframeColor.black,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showHistory = !_showHistory;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      _showHistory ? Icons.visibility_off : Icons.history_rounded,
                                      size: 18,
                                      color: WireframeColor.appcolor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showHistory ? 'Hide History'.tr : 'View History'.tr,
                                      style: sansproSemibold.copyWith(
                                        fontSize: 13,
                                        color: WireframeColor.appcolor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / 50),

                          if (_showHistory) ...[
                            Text(
                              "Live Class History (Completed)".tr,
                              style: sansproBold.copyWith(
                                fontSize: 15,
                                color: WireframeColor.appcolor,
                              ),
                            ),
                            SizedBox(height: height / 60),
                            _buildCompletedHistoryList(width),
                          ] else ...[
                            Text(
                              "Today's Classes".tr,
                              style: sansproBold.copyWith(
                                fontSize: 16,
                                color: themedata.isdark
                                    ? WireframeColor.white
                                    : WireframeColor.black,
                              ),
                            ),
                            SizedBox(height: height / 50),
                            if (liveCtrl.classes.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                    "No scheduled live classes today.",
                                    style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                                  ),
                                ),
                              )
                            else
                              ...liveCtrl.classes.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildClassItem(
                                  item: item,
                                  height: height,
                                  width: width,
                                ),
                              )),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassItem({
    required LiveClassModel item,
    required double height,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width / 26),
      decoration: BoxDecoration(
        color: themedata.isdark ? WireframeColor.lightblack : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WireframeColor.bggray.withAlpha(100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.isLiveNow ? Colors.red.withAlpha(20) : WireframeColor.appcolor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isLiveNow ? Icons.live_tv_rounded : Icons.videocam_outlined,
              color: item.isLiveNow ? Colors.red : WireframeColor.appcolor,
            ),
          ),
          SizedBox(width: width / 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: sansproBold.copyWith(
                    fontSize: 16,
                    color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.teacher.isNotEmpty ? item.teacher : 'Teacher'} • ${item.timeFormatted}",
                  style: sansproRegular.copyWith(
                    fontSize: 13,
                    color: WireframeColor.textgray,
                  ),
                ),
              ],
            ),
          ),
          if (item.joinAllowed)
            ElevatedButton(
              onPressed: () => liveCtrl.joinClass(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF416C),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Join", style: sansproBold.copyWith(color: Colors.white, fontSize: 12)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status,
                style: sansproSemibold.copyWith(
                  fontSize: 11,
                  color: Colors.blue[800],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedHistoryList(double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themedata.isdark ? WireframeColor.lightblack : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WireframeColor.bggray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Sessions Recorded",
                  style: sansproBold.copyWith(
                    fontSize: 14.5,
                    color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Completed sessions will appear in your Smart Classroom archives",
                  style: sansproRegular.copyWith(
                    fontSize: 11.5,
                    color: WireframeColor.textgray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}