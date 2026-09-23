import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'page_hero_header.dart';
import 'live_now_card.dart';
import 'live_class_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// TODAY LIVE CLASSES PAGE
//
// Connected to real GET /student/live-classes/today API.
// Features 2 dynamic tabs:
//   1) Schedule Classes: All non-cancelled live classes for the student today.
//   2) My Live Classes: Live Now banner + list of ongoing & upcoming classes.
// ════════════════════════════════════════════════════════════════════════════

class TodayLiveClassesPage extends StatefulWidget {
  const TodayLiveClassesPage({Key? key}) : super(key: key);

  @override
  State<TodayLiveClassesPage> createState() => _TodayLiveClassesPageState();
}

class _TodayLiveClassesPageState extends State<TodayLiveClassesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final liveCtrl = Get.put(LiveClassController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    liveCtrl.fetchTodayLiveClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          PageHeroHeader(
            theme: PageHeroTheme.homework,
            title: 'Today Live Classes',
            subtitle: 'All scheduled live classes for today',
            onBack: () => Navigator.pop(context),
          ),
          Container(
            color: WireframeColor.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: WireframeColor.appcolor,
              labelColor: WireframeColor.appcolor,
              unselectedLabelColor: WireframeColor.textgray,
              labelStyle: sansproBold.copyWith(fontSize: 14),
              unselectedLabelStyle: sansproRegular.copyWith(fontSize: 14),
              tabs: const [
                Tab(
                  icon: Icon(Icons.calendar_today_rounded, size: 18),
                  text: "Schedule Classes",
                ),
                Tab(
                  icon: Icon(Icons.video_camera_front_rounded, size: 18),
                  text: "My Live Classes",
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (liveCtrl.isLoading.value && liveCtrl.classes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (liveCtrl.hasError.value && liveCtrl.classes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.videocam_off_rounded, size: 48, color: WireframeColor.appgray),
                        const SizedBox(height: 12),
                        Text(
                          liveCtrl.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.textgray),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WireframeColor.appcolor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => liveCtrl.fetchTodayLiveClasses(),
                          child: Text("Retry".tr, style: sansproSemibold.copyWith(color: WireframeColor.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: liveCtrl.refreshLiveClasses,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Schedule Classes
                    _buildScheduledClassesList(liveCtrl.classes),

                    // Tab 2: My Live Classes
                    _buildMyLiveClassesList(
                      width: width,
                      height: height,
                      classes: liveCtrl.classes,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledClassesList(List<LiveClassModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: WireframeColor.textgray.withAlpha(120)),
            const SizedBox(height: 12),
            Text(
              'No Live Classes Scheduled For Today',
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.appgray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: WireframeColor.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: WireframeColor.bggray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: WireframeColor.appcolor.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.subject.isNotEmpty ? item.subject : item.title,
                      style: sansproBold.copyWith(color: WireframeColor.appcolor, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isLiveNow ? Colors.red.withAlpha(30) : Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.status,
                      style: sansproBold.copyWith(
                        color: item.isLiveNow ? Colors.red : Colors.orange.shade800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: sansproBold.copyWith(fontSize: 15.5, color: WireframeColor.black),
              ),
              if (item.teacher.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: WireframeColor.textgray),
                    const SizedBox(width: 4),
                    Text(
                      'Instructor: ${item.teacher}',
                      style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                    ),
                  ],
                ),
              ],
              const Divider(height: 20, color: WireframeColor.bggray),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: WireframeColor.textgray),
                      const SizedBox(width: 4),
                      Text(
                        item.timeFormatted,
                        style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                      ),
                    ],
                  ),
                  if (item.room.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined, size: 14, color: WireframeColor.textgray),
                        const SizedBox(width: 4),
                        Text(
                          'Room: ${item.room}',
                          style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                        ),
                      ],
                    ),
                ],
              ),
              if (item.joinAllowed) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => liveCtrl.joinClass(item),
                    icon: const Icon(Icons.video_call_rounded, size: 18),
                    label: Text("Join Meeting Now", style: sansproBold.copyWith(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF416C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyLiveClassesList({
    required double width,
    required double height,
    required List<LiveClassModel> classes,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your assigned live classes for today are listed below. Click "Join" for ongoing sessions.',
                  style: sansproRegular.copyWith(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dynamic Embedded Live Now Card
        LiveNowCard(width: width, height: height),

        const SizedBox(height: 16),
        Text(
          'Upcoming Live Classes Today',
          style: sansproBold.copyWith(fontSize: 15, color: WireframeColor.black),
        ),
        const SizedBox(height: 10),

        if (classes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No additional classes for today',
                style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
              ),
            ),
          )
        else
          ...classes.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WireframeColor.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WireframeColor.bggray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: sansproBold.copyWith(fontSize: 15, color: WireframeColor.black),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: WireframeColor.appcolor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status,
                          style: sansproBold.copyWith(color: WireframeColor.appcolor, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  if (item.subject.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subject,
                      style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.teacher.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 14, color: WireframeColor.textgray),
                            const SizedBox(width: 4),
                            Text(
                              item.teacher,
                              style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: WireframeColor.textgray),
                          const SizedBox(width: 4),
                          Text(
                            item.timeFormatted,
                            style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (item.joinAllowed) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => liveCtrl.joinClass(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF416C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        child: Text("Join Now", style: sansproBold.copyWith(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}