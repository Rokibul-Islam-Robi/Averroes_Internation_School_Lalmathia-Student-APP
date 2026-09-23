import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';
import 'smart_classroom_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// SMART CLASS ROOM PAGE
//
// Connected to real GET /student/smart-classroom API endpoint.
// Displays published digital classroom materials, interactive sessions, and
// online links for the authenticated student.
// ════════════════════════════════════════════════════════════════════════════

class SmartClassRoomPage extends StatefulWidget {
  const SmartClassRoomPage({super.key});

  @override
  State<SmartClassRoomPage> createState() => _SmartClassRoomPageState();
}

class _SmartClassRoomPageState extends State<SmartClassRoomPage> {
  final themedata = Get.put(WireframeThemecontroler());
  final smartCtrl = Get.put(SmartClassroomController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    smartCtrl.fetchSmartClassroom();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        smartCtrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(
        title: 'Smart Class Room',
      ),
      body: PageBackground(
        category: PageCategory.smartClassRoom,
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
                  if (smartCtrl.isLoading.value && smartCtrl.materials.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (smartCtrl.hasError.value && smartCtrl.materials.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.meeting_room_outlined, size: 48, color: WireframeColor.appgray),
                            const SizedBox(height: 12),
                            Text(
                              smartCtrl.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.textgray),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WireframeColor.appcolor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => smartCtrl.fetchSmartClassroom(),
                              child: Text("Retry".tr, style: sansproSemibold.copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: smartCtrl.refreshSmartClassroom,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 26, vertical: height / 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(width, height),
                          SizedBox(height: height / 30),
                          Text(
                            "Available Smart Classes",
                            style: sansproBold.copyWith(
                              fontSize: 18,
                              color: themedata.isdark
                                  ? WireframeColor.white
                                  : WireframeColor.black,
                            ),
                          ),
                          SizedBox(height: height / 50),

                          if (smartCtrl.materials.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: height / 14),
                                child: Column(
                                  children: [
                                    Icon(Icons.video_library_outlined, size: 48, color: WireframeColor.textgray.withAlpha(120)),
                                    const SizedBox(height: 12),
                                    Text(
                                      "No published smart classroom content found.",
                                      style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.textgray),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...smartCtrl.materials.map((item) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: height / 60),
                                child: _buildClassCard(
                                  item: item,
                                  height: height,
                                  width: width,
                                ),
                              );
                            }).toList(),

                          if (smartCtrl.isLoadingMore.value)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
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

  Widget _buildHeaderCard(double width, double height) {
    return Container(
      width: width,
      padding: EdgeInsets.all(width / 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff4F46E5), Color(0xff7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff4F46E5).withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.meeting_room_rounded, color: Colors.white, size: 28),
              SizedBox(width: width / 30),
              Text(
                "Digital Classroom",
                style: sansproBold.copyWith(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Access published interactive classroom materials, recorded sessions, and discussions.",
            style: sansproRegular.copyWith(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard({
    required SmartClassroomItem item,
    required double height,
    required double width,
  }) {
    final statusColor = item.status.toLowerCase() == "active"
        ? Colors.green
        : (item.status.toLowerCase() == "completed" ? Colors.blueGrey : Colors.orange);

    return Container(
      padding: EdgeInsets.all(width / 26),
      decoration: BoxDecoration(
        color: themedata.isdark ? WireframeColor.lightblack : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WireframeColor.bggray.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.subjectCode.isNotEmpty)
                Text(
                  item.subjectCode,
                  style: sansproBold.copyWith(
                    fontSize: 12,
                    color: WireframeColor.appcolor,
                  ),
                )
              else
                Text(
                  item.subjectName.isNotEmpty ? item.subjectName : 'Digital Class',
                  style: sansproBold.copyWith(
                    fontSize: 12,
                    color: WireframeColor.appcolor,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status,
                  style: sansproSemibold.copyWith(
                    fontSize: 11,
                    color: statusColor.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: sansproBold.copyWith(
              fontSize: 16,
              color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
            ),
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sansproRegular.copyWith(fontSize: 12.5, color: WireframeColor.textgray),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (item.teacherName.isNotEmpty) ...[
                const Icon(Icons.person_outline_rounded, size: 14, color: WireframeColor.textgray),
                const SizedBox(width: 4),
                Text(
                  item.teacherName,
                  style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                ),
                const SizedBox(width: 12),
              ],
              if (item.timeFormatted.isNotEmpty) ...[
                const Icon(Icons.access_time_rounded, size: 14, color: WireframeColor.textgray),
                const SizedBox(width: 4),
                Text(
                  item.timeFormatted,
                  style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                ),
              ],
            ],
          ),
          if (item.openableUrl != null && item.openableUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => smartCtrl.openClassroomUrl(item.openableUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.white),
                label: Text(
                  "Enter Classroom",
                  style: sansproBold.copyWith(fontSize: 13, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WireframeColor.appcolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}