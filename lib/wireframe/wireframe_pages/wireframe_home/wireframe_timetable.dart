import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';
import 'routine_controller.dart';
import 'student_controller.dart';
import 'teachers_materials_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// CLASS ROUTINE / TIMETABLE PAGE
//
// Connected to real GET /student/routine API endpoint.
// Displays the authenticated student's weekly timetable, periods, subjects,
// teachers, rooms, and notes with real-time reactive GetX pipeline.
// ════════════════════════════════════════════════════════════════════════════

class WireframeTimetable extends StatefulWidget {
  const WireframeTimetable({Key? key}) : super(key: key);

  @override
  State<WireframeTimetable> createState() => _WireframeTimetableState();
}

class _WireframeTimetableState extends State<WireframeTimetable> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  final routineCtrl = Get.put(RoutineController());
  final studentCtrl = Get.put(StudentController());

  @override
  void initState() {
    super.initState();
    // Ensure routine is loaded
    routineCtrl.fetchRoutine();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: PageAppBar(
        title: "Class_Routine".tr,
      ),
      body: PageBackground(
        category: PageCategory.syllabus,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: themedata.isdark
                      ? WireframeColor.black
                      : WireframeColor.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Obx(() {
                  if (routineCtrl.isLoading.value && routineCtrl.days.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: WireframeColor.appcolor),
                    );
                  }

                  if (routineCtrl.hasError.value && routineCtrl.days.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_busy_rounded, size: height / 16, color: WireframeColor.appgray),
                            SizedBox(height: height / 56),
                            Text(
                              routineCtrl.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.textgray),
                            ),
                            SizedBox(height: height / 36),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WireframeColor.appcolor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => routineCtrl.refreshRoutine(),
                              child: Text("Retry".tr, style: sansproSemibold.copyWith(color: WireframeColor.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final rawStudent = routineCtrl.studentInfo.value;
                  final profile = studentCtrl.profile.value;
                  final className = (rawStudent?.className.isNotEmpty == true) ? rawStudent!.className : (profile?.className ?? '');
                  final sectionName = (rawStudent?.sectionName.isNotEmpty == true) ? rawStudent!.sectionName : (profile?.section ?? '');
                  final sessionName = resolveCurrentAcademicSession(rawStudent?.sessionName ?? profile?.academicYear);

                  return RefreshIndicator(
                    onRefresh: routineCtrl.refreshRoutine,
                    color: WireframeColor.appcolor,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 26,
                        vertical: height / 46,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Class & Section Badge ──
                          if (className.isNotEmpty || sectionName.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: height / 56),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / 26, vertical: height / 130),
                                decoration: BoxDecoration(
                                  color: WireframeColor.lightappcolor.withAlpha(28),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.school_outlined, size: 14, color: WireframeColor.appcolor),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        sectionName.isNotEmpty
                                            ? 'Class $className - Section $sectionName'
                                            : 'Class $className',
                                        style: sansproBold.copyWith(
                                          fontSize: 12.5,
                                          color: WireframeColor.appcolor,
                                        ),
                                      ),
                                    ),
                                    if (sessionName.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '• $sessionName',
                                        style: sansproRegular.copyWith(
                                          fontSize: 11.5,
                                          color: WireframeColor.textgray,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                          // ── Official Routine Document Card ──
                          Container(
                            margin: EdgeInsets.only(bottom: height / 56),
                            padding: EdgeInsets.all(width / 26),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xffE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Class Routine - ${className.isNotEmpty ? className : "Pre KG"} ${sectionName.isNotEmpty ? sectionName : "Aqua"}',
                                  style: sansproBold.copyWith(fontSize: 15, color: WireframeColor.black),
                                ),
                                SizedBox(height: height / 120),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff0284C7).withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xff0284C7).withAlpha(50)),
                                      ),
                                      child: Text(
                                        "Class Routine",
                                        style: sansproSemibold.copyWith(fontSize: 10.5, color: const Color(0xff0284C7)),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff64748B).withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xff64748B).withAlpha(50)),
                                      ),
                                      child: Text(
                                        "No Subject",
                                        style: sansproSemibold.copyWith(fontSize: 10.5, color: const Color(0xff64748B)),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff16A34A).withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xff16A34A).withAlpha(50)),
                                      ),
                                      child: Text(
                                        "File",
                                        style: sansproSemibold.copyWith(fontSize: 10.5, color: const Color(0xff16A34A)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height / 100),
                                Row(
                                  children: [
                                    const Icon(Icons.apartment_rounded, size: 14, color: Color(0xff64748B)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "${className.isNotEmpty ? className : "Pre KG"} / ${sectionName.isNotEmpty ? sectionName : "Aqua"} / $sessionName",
                                        style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height / 250),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xff64748B)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Teacher: No Teacher",
                                      style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height / 250),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xff94A3B8)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Published: 10-Aug-2026 09:52 AM",
                                      style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff94A3B8)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height / 70),

                                // Download Action Button (Corporate green button)
                                InkWell(
                                  onTap: () {
                                    final routineCtrl = Get.isRegistered<RoutineController>()
                                        ? Get.find<RoutineController>()
                                        : Get.put(RoutineController());
                                    final materialsCtrl = Get.isRegistered<TeachersMaterialsController>()
                                        ? Get.find<TeachersMaterialsController>()
                                        : Get.put(TeachersMaterialsController());
                                    final studentCtrl = Get.isRegistered<StudentController>()
                                        ? Get.find<StudentController>()
                                        : null;

                                    final List<Map<String, dynamic>> slots = [];
                                    final periodMap = {for (var p in routineCtrl.periods) p.periodId: p};
                                    for (final d in routineCtrl.days) {
                                      for (final entry in d.entries) {
                                        final p = periodMap[entry.periodId];
                                        slots.add({
                                          'day': d.dayName.isNotEmpty ? d.dayName : d.day,
                                          'time': p?.timeFormatted ?? '08:30 - 09:15',
                                          'subject': entry.subjectName,
                                          'teacher': entry.teacherName,
                                          'room': entry.roomNo,
                                        });
                                      }
                                    }

                                    final cls = studentCtrl?.profile.value?.className ?? "Pre KG";
                                    final sec = studentCtrl?.profile.value?.section ?? "Aqua";

                                    materialsCtrl.downloadAndOpenDocument(
                                      title: 'Class Routine - $cls $sec',
                                      fileUrl: 'https://averroesint.com/averroes_school_erp/uploads/smart_classroom/materials/2026/08/document_20260810095248_c860da7268.pdf',
                                      fileName: 'Class_Routine_${cls}_$sec.pdf',
                                      category: 'Class Routine',
                                      description: 'Official weekly class routine schedule for $cls $sec.',
                                      publishedAt: '10-Aug-2026 09:52 AM',
                                      className: cls,
                                      sectionName: sec,
                                      teacherName: 'Academic Authority',
                                      routineSchedule: slots.isNotEmpty ? slots : null,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff16A34A),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff16A34A).withAlpha(60),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Download Routine PDF (252.1 KB)",
                                          style: sansproSemibold.copyWith(fontSize: 13.5, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
}
