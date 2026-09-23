import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'live_now_card.dart';
import 'live_class_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// LIVE NOW PAGE
//
// Shows active and today's live online class sessions with instant join capability.
// ════════════════════════════════════════════════════════════════════════════

class LiveNowPage extends StatelessWidget {
  const LiveNowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final liveCtrl = Get.put(LiveClassController());

    return Scaffold(
      backgroundColor: const Color(0xffF3F5FB),
      appBar: AppBar(
        backgroundColor: WireframeColor.appcolor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Live Now",
          style: sansproSemibold.copyWith(fontSize: 18, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: liveCtrl.refreshLiveClasses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(width / 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LiveNowCard(width: width - (width / 13), height: height / 8),
              SizedBox(height: height / 36),
              Text(
                "All Active & Scheduled Live Classes",
                style: sansproBold.copyWith(fontSize: 16, color: WireframeColor.black),
              ),
              SizedBox(height: height / 60),
              Obx(() {
                if (liveCtrl.isLoading.value && liveCtrl.classes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (liveCtrl.classes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height / 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.video_camera_back_outlined, size: 48, color: WireframeColor.textgray.withAlpha(120)),
                          const SizedBox(height: 12),
                          Text(
                            "No live classes active at this moment.",
                            textAlign: TextAlign.center,
                            style: sansproRegular.copyWith(
                              fontSize: 14,
                              color: WireframeColor.textgray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: liveCtrl.classes.length,
                  separatorBuilder: (_, __) => SizedBox(height: height / 80),
                  itemBuilder: (context, index) {
                    final item = liveCtrl.classes[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WireframeColor.bggray),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(6),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.isLiveNow ? Colors.red.withAlpha(20) : WireframeColor.appcolor.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.isLiveNow ? Icons.live_tv_rounded : Icons.videocam_outlined,
                              color: item.isLiveNow ? Colors.red : WireframeColor.appcolor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: sansproBold.copyWith(fontSize: 14.5, color: WireframeColor.black),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "${item.subject.isNotEmpty ? item.subject : 'Class'} • ${item.timeFormatted}",
                                  style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                                ),
                                if (item.teacher.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.teacher,
                                    style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.appcolor),
                                  ),
                                ],
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.status,
                                style: sansproSemibold.copyWith(fontSize: 11, color: Colors.blue.shade800),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
