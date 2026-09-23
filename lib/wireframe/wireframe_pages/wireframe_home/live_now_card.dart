import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'live_class_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// LIVE NOW CARD — Real Dynamic Live Class Integration
//
// Automatically watches LiveClassController for the current active or upcoming
// live class. Enables "Join" button only inside the permitted join window.
// ════════════════════════════════════════════════════════════════════════════

class LiveNowCard extends StatefulWidget {
  final double width;
  final double height;

  const LiveNowCard({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<LiveNowCard> createState() => _LiveNowCardState();
}

class _LiveNowCardState extends State<LiveNowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final liveCtrl = Get.put(LiveClassController());

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = liveCtrl.activeLiveClass;
      final isLive = active != null && active.isLiveNow;
      final hasClass = active != null;

      final title = hasClass ? active.title : "No Live Class Right Now";
      final teacherSubtitle = hasClass
          ? "${active.teacher.isNotEmpty ? active.teacher : 'Teacher'} • ${active.timeFormatted}"
          : "Check timetable for scheduled classes";

      return Container(
        width: widget.width,
        padding: EdgeInsets.all(widget.width / 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLive
                ? const [Color(0xffFF4B2B), Color(0xffFF416C)]
                : const [Color(0xff1E3C72), Color(0xff2A5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isLive
                  ? const Color(0xffFF416C).withAlpha(80)
                  : const Color(0xff1E3C72).withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLive ? Icons.live_tv_rounded : Icons.video_camera_front_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: widget.width / 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLive)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha((_pulseAnimation.value * 255).round().clamp(0, 255)),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "LIVE NOW",
                              style: sansproBold.copyWith(
                                fontSize: 11,
                                color: WireframeColor.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    Text(
                      hasClass ? "UPCOMING CLASS" : "LIVE CLASSES",
                      style: sansproBold.copyWith(
                        fontSize: 10.5,
                        color: Colors.white.withAlpha(200),
                        letterSpacing: 0.8,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sansproBold.copyWith(
                      fontSize: 16,
                      color: WireframeColor.white,
                    ),
                  ),
                  Text(
                    teacherSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sansproRegular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withAlpha(210),
                    ),
                  ),
                ],
              ),
            ),
            if (hasClass && isLive) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => liveCtrl.joinClass(active),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xffFF416C),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Join",
                  style: sansproBold.copyWith(fontSize: 13),
                ),
              ),
            ] else if (hasClass) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  active.status,
                  style: sansproSemibold.copyWith(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}