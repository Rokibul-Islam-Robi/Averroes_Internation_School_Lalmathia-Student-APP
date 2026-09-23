import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/student_controller.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/report_card_controller.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_support.dart';

// ════════════════════════════════════════════════════════════════════════════
// Result Page — Modern, Corporate Level Published Result & Marksheet
// Connected 100% to live ERP API:
//  - GET /api/student/results
//  - GET /api/student/results/{examId}
// ════════════════════════════════════════════════════════════════════════════

class WireframeResult extends StatelessWidget {
  const WireframeResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReportCardController resultCtrl = Get.put(ReportCardController());
    final StudentController studentCtrl = Get.put(StudentController());
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Academic Results',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Results',
            onPressed: () => resultCtrl.fetchPublishedResults(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.headset_mic_outlined, color: Colors.white),
              onPressed: () => Get.to(() => const WireframeSupport()),
            ),
          ),
        ],
      ),
      body: PageBackground(
        category: PageCategory.result,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),

            Expanded(
              child: Obx(() {
                if (resultCtrl.isExamListLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: WireframeColor.appcolor),
                  );
                }

                if (resultCtrl.examListHasError.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w / 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: Color(0xffFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_off_rounded, color: Color(0xffDC2626), size: 40),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Could Not Load Results',
                            style: sansproBold.copyWith(fontSize: 17, color: WireframeColor.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            resultCtrl.examListErrorMessage.value,
                            textAlign: TextAlign.center,
                            style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WireframeColor.appcolor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                            ),
                            onPressed: () => resultCtrl.fetchPublishedResults(),
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                            label: Text(
                              'Try Again',
                              style: sansproBold.copyWith(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (resultCtrl.publishedResults.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => resultCtrl.fetchPublishedResults(),
                    color: WireframeColor.appcolor,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: 12),
                      children: [
                        _buildStudentHeroCard(studentCtrl, null, w, h),
                        SizedBox(height: h / 12),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: const BoxDecoration(
                                  color: Color(0xffEEF2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.workspace_premium_outlined, color: WireframeColor.appcolor, size: 48),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Published Results Yet',
                                style: sansproBold.copyWith(fontSize: 17, color: WireframeColor.black),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Exam results for this session will appear here once officially published by the school administration.',
                                textAlign: TextAlign.center,
                                style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final selectedDetail = resultCtrl.selectedResultDetail.value ?? resultCtrl.publishedResults.first;

                return RefreshIndicator(
                  onRefresh: () => resultCtrl.fetchPublishedResults(),
                  color: WireframeColor.appcolor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: 8),
                    children: [
                      // 1. Student Profile Hero Card
                      _buildStudentHeroCard(studentCtrl, selectedDetail, w, h),

                      SizedBox(height: h / 55),

                      // 2. Published Exams Horizontal Selector
                      if (resultCtrl.publishedResults.length > 1) ...[
                        _buildExamSelector(resultCtrl, w),
                        SizedBox(height: h / 55),
                      ],

                      // 3. Performance Summary Grid (GPA, Marks, Position, Attendance)
                      _buildPerformanceSummary(selectedDetail, w, h),

                      SizedBox(height: h / 50),

                      // 4. Subject-wise Marksheet Breakdown
                      _buildSubjectMarksheetSection(resultCtrl, selectedDetail, w, h),

                      SizedBox(height: h / 30),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. STUDENT PROFILE HERO CARD (Corporate Level)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStudentHeroCard(
    StudentController studentCtrl,
    PublishedResultItem? resultItem,
    double w,
    double h,
  ) {
    return Obx(() {
      final p = studentCtrl.profile.value;
      final ctx = resultItem?.academicContext;

      final studentName = p?.studentName.isNotEmpty == true
          ? p!.studentName
          : (ctx?.rollNo.isNotEmpty == true ? 'Student' : (p?.studentName.isNotEmpty == true ? p!.studentName : 'Student'));

      final studentId = p?.studentId.isNotEmpty == true
          ? p!.studentId
          : (p?.rollNo.isNotEmpty == true
              ? p!.rollNo
              : (ctx?.rollNo.isNotEmpty == true ? ctx!.rollNo : ''));

      final className = ctx?.className.isNotEmpty == true
          ? ctx!.className
          : (p?.className.isNotEmpty == true ? p!.className : 'Pre KG');

      final sectionName = ctx?.sectionName.isNotEmpty == true
          ? ctx!.sectionName
          : (p?.section.isNotEmpty == true ? p!.section : 'Aqua');

      final sessionName = resolveCurrentAcademicSession(ctx?.sessionName ?? p?.academicYear);
      final photo = p?.profilePhotoUrl ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff0B1E4D), Color(0xff1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0B1E4D).withAlpha(60),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white.withAlpha(25), width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar with Ring
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(200), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: photo.isNotEmpty
                        ? Image.network(
                            photo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
                          )
                        : Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: sansproBold.copyWith(
                          fontSize: 16.5,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ID: $studentId  ·  Class: $className ($sectionName)',
                        style: sansproRegular.copyWith(
                          fontSize: 12.5,
                          color: Colors.white.withAlpha(220),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Academic Session: $sessionName',
                        style: sansproSemibold.copyWith(
                          fontSize: 11.5,
                          color: const Color(0xff93C5FD),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withAlpha(25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xff34D399), size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'Official ERP Published Report Card',
                        style: sansproSemibold.copyWith(fontSize: 11.5, color: Colors.white.withAlpha(220)),
                      ),
                    ],
                  ),
                  if (resultItem?.summary?.overallGrade != null && resultItem!.summary!.overallGrade != '—')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xff10B981),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        resultItem.summary!.overallGrade,
                        style: sansproBold.copyWith(fontSize: 11, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. EXAM SELECTOR PILLS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildExamSelector(ReportCardController ctrl, double w) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ctrl.publishedResults.map((item) {
          final isSelected = (ctrl.selectedExamId.value == item.exam.id) ||
              (ctrl.selectedExamId.value == 0 && item == ctrl.publishedResults.first);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => ctrl.selectExam(item.exam.id),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? WireframeColor.appcolor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? WireframeColor.appcolor : const Color(0xffCBD5E1),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: WireframeColor.appcolor.withAlpha(40),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 15,
                      color: isSelected ? Colors.white : const Color(0xff475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.exam.name,
                      style: sansproBold.copyWith(
                        fontSize: 12.5,
                        color: isSelected ? Colors.white : const Color(0xff334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. PERFORMANCE SUMMARY BENTO GRID (GPA, Marks, Position, Attendance)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPerformanceSummary(PublishedResultItem item, double w, double h) {
    final s = item.summary;
    final att = item.attendance;

    final String gpaText = s != null ? s.gradePoint.toStringAsFixed(2) : '—';
    final String gradeText = s?.overallGrade ?? '—';
    final String marksText = s != null && s.fullMarks > 0
        ? '${s.obtainedMarks.toInt()} / ${s.fullMarks.toInt()}'
        : '—';
    final String pctText = s != null && s.percentage > 0 ? '${s.percentage.toStringAsFixed(1)}%' : '';
    final String posText = s?.positionInSection != null && s!.positionInSection! > 0
        ? _formatOrdinal(s.positionInSection!)
        : '—';
    final String attText = att != null && att.workingDays > 0
        ? '${att.presentDays}/${att.workingDays} (${att.percentage.toStringAsFixed(1)}%)'
        : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
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
              Text(
                item.exam.name,
                style: sansproBold.copyWith(fontSize: 15.5, color: const Color(0xff0B1E4D)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xffDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xff16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      'Published',
                      style: sansproBold.copyWith(fontSize: 10.5, color: const Color(0xff16A34A)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2x2 Metric Grid
          Row(
            children: [
              // Card 1: GPA & Overall Grade
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: const Color(0xff10B981),
                  bgColor: const Color(0xffECFDF5),
                  title: 'Grade & GPA',
                  value: gradeText != '—' ? '$gradeText (GPA $gpaText)' : 'GPA $gpaText',
                  subtitle: s != null && s.hasFailedSubject ? 'Review Needed' : 'Passed',
                ),
              ),
              const SizedBox(width: 10),
              // Card 2: Total Marks
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.analytics_rounded,
                  iconColor: const Color(0xff2563EB),
                  bgColor: const Color(0xffEFF6FF),
                  title: 'Total Marks',
                  value: marksText,
                  subtitle: pctText.isNotEmpty ? 'Score: $pctText' : 'Marks Secured',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              // Card 3: Position in Section
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.military_tech_rounded,
                  iconColor: const Color(0xffD97706),
                  bgColor: const Color(0xffFFFBEB),
                  title: 'Section Position',
                  value: posText,
                  subtitle: 'Class Standing',
                ),
              ),
              const SizedBox(width: 10),
              // Card 4: Exam Attendance
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.how_to_reg_rounded,
                  iconColor: const Color(0xff7C3AED),
                  bgColor: const Color(0xffF5F3FF),
                  title: 'Exam Attendance',
                  value: attText,
                  subtitle: 'Working Days',
                ),
              ),
            ],
          ),

          if (s?.remarks != null && s!.remarks.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xffFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rate_review_outlined, color: Color(0xff92400E), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Teacher Remarks: "${s.remarks}"',
                      style: sansproSemibold.copyWith(fontSize: 12, color: const Color(0xff92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: sansproRegular.copyWith(fontSize: 11, color: const Color(0xff475569)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: sansproBold.copyWith(fontSize: 14, color: const Color(0xff0F172A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: sansproRegular.copyWith(fontSize: 10.5, color: const Color(0xff64748B)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. SUBJECT-WISE MARKSHEET BREAKDOWN
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSubjectMarksheetSection(
    ReportCardController ctrl,
    PublishedResultItem item,
    double w,
    double h,
  ) {
    return Obx(() {
      if (ctrl.isDetailLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: WireframeColor.appcolor),
          ),
        );
      }

      final subjects = item.subjects;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subject-Wise Marksheet',
                style: sansproBold.copyWith(fontSize: 15.5, color: const Color(0xff0B1E4D)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${subjects.length} Subjects',
                  style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff475569)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (subjects.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              alignment: Alignment.center,
              child: Text(
                'Detailed subject marks will appear once entries are finalized.',
                style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...subjects.map((sub) => _buildSubjectCard(sub, w, h)),
        ],
      );
    });
  }

  Widget _buildSubjectCard(SubjectMarkDetail sub, double w, double h) {
    final double total = sub.total ?? 0.0;
    final double full = sub.fullMarks > 0 ? sub.fullMarks : 100.0;
    final double pct = full > 0 ? (total / full) * 100.0 : 0.0;

    Color gradeBg = const Color(0xffDCFCE7);
    Color gradeText = const Color(0xff16A34A);
    if (sub.grade == 'F' || sub.passed == false) {
      gradeBg = const Color(0xffFEE2E2);
      gradeText = const Color(0xffDC2626);
    } else if (sub.grade == 'B' || sub.grade == 'C') {
      gradeBg = const Color(0xffFEF3C7);
      gradeText = const Color(0xffD97706);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Subject Code Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sub.code.isNotEmpty ? sub.code : 'SUB',
                  style: sansproBold.copyWith(fontSize: 11, color: WireframeColor.appcolor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.name,
                      style: sansproBold.copyWith(fontSize: 14, color: const Color(0xff0F172A)),
                    ),
                    Text(
                      'Pass Marks: ${sub.passMarks.toInt()}  ·  Full Marks: ${sub.fullMarks.toInt()}',
                      style: sansproRegular.copyWith(fontSize: 11, color: const Color(0xff64748B)),
                    ),
                  ],
                ),
              ),
              if (sub.grade != null && sub.grade!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gradeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sub.grade!,
                    style: sansproBold.copyWith(fontSize: 12.5, color: gradeText),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Assessment Breakdown (HW, CT, Exam, Total)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarkColumn('Homework', sub.homework != null ? sub.homework!.toStringAsFixed(0) : '—'),
                _buildMarkColumn('Class Test', sub.classTest != null ? sub.classTest!.toStringAsFixed(0) : '—'),
                _buildMarkColumn('Exam', sub.exam != null ? sub.exam!.toStringAsFixed(0) : '—'),
                _buildMarkColumn(
                  'Total',
                  sub.total != null ? '${sub.total!.toStringAsFixed(0)}/${sub.fullMarks.toInt()}' : '—',
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xffE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 80 ? const Color(0xff10B981) : (pct >= 50 ? const Color(0xff2563EB) : const Color(0xffEF4444)),
              ),
            ),
          ),

          if (sub.highestInSection != null && sub.highestInSection! > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xffF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Highest in Section: ${sub.highestInSection!.toInt()}',
                      style: sansproRegular.copyWith(fontSize: 11, color: const Color(0xff64748B)),
                    ),
                  ],
                ),
                Text(
                  sub.isAbsent
                      ? 'Absent'
                      : (sub.passed == true ? 'Passed' : 'Needs Improvement'),
                  style: sansproSemibold.copyWith(
                    fontSize: 11,
                    color: sub.passed == true ? const Color(0xff16A34A) : const Color(0xffDC2626),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkColumn(String label, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: sansproRegular.copyWith(fontSize: 10.5, color: const Color(0xff64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: (isBold ? sansproBold : sansproSemibold).copyWith(
            fontSize: 12.5,
            color: isBold ? WireframeColor.appcolor : const Color(0xff1E293B),
          ),
        ),
      ],
    );
  }

  String _formatOrdinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
}

