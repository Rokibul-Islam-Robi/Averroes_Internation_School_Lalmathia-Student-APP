import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'exam_controller.dart';
import 'page_hero_header.dart'; // হিরো হেডার ইম্পোর্ট করা হলো

const Color _kAccent  = Color(0xFF5C35FF);
const Color _kGreen   = Color(0xFF4CAF50);
const Color _kRed     = Color(0xFFE53935);
const Color _kOrange  = Color(0xFFFFA726);

class ExamListPage extends StatelessWidget {
  const ExamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ExamController ctrl = Get.put(ExamController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          PageHeroHeader(
            theme: PageHeroTheme.examination,
            title: 'Examinations',
            subtitle: 'Schedules, results & more',
            onBack: () => Navigator.pop(context),
            actions: [
              IconButton(
                icon: const Icon(Icons.volunteer_activism_outlined, color: Colors.white),
                tooltip: 'Promotion Status',
                onPressed: () => Get.to(() => const PromotionPage()),
              ),
            ],
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.isExamListLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.examListHasError.value) {
                return _ErrorPanel(
                    message: ctrl.examListErrorMessage.value,
                    onRetry: ctrl.fetchExamList);
              }
              if (ctrl.exams.isEmpty) {
                return const _EmptyPanel(message: 'No exams found for your class.');
              }
              return RefreshIndicator(
                color: _kAccent,
                onRefresh: ctrl.fetchExamList,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: ctrl.exams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final exam = ctrl.exams[i];
                    return _ExamCard(exam: exam, ctrl: ctrl);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamItem exam;
  final ExamController ctrl;
  const _ExamCard({required this.exam, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isCompleted = exam.status.toLowerCase() == 'completed';
    final isOngoing   = exam.status.toLowerCase() == 'ongoing';
    final statusColor = isCompleted ? _kGreen : isOngoing ? _kOrange : Colors.black38;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => ExamDetailPage(exam: exam)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: _kAccent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.description_outlined, color: _kAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sansproSemibold.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 3),
                    Text('${exam.type} • ${exam.session}',
                        style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(exam.status,
                    style: sansproSemibold.copyWith(fontSize: 11, color: statusColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamDetailPage extends StatelessWidget {
  final ExamItem exam;
  const ExamDetailPage({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final ExamController ctrl = Get.find<ExamController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(exam.name,
            style: sansproSemibold.copyWith(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _hubTile(
            icon: Icons.calendar_month_outlined,
            color: _kAccent,
            title: 'Exam Routine',
            subtitle: 'View subject-wise schedule, date & venue',
            onTap: () => Get.to(() => ExamRoutinePage(exam: exam)),
          ),
          const SizedBox(height: 10),
          _hubTile(
            icon: Icons.badge_outlined,
            color: _kOrange,
            title: 'Admit Card',
            subtitle: 'Download your admit card as PDF',
            onTap: () async {
              Get.snackbar('Downloading...', 'Please wait',
                  duration: const Duration(seconds: 1));
              final path = await ctrl.downloadAdmitCard(exam.examId);
              if (path != null) await OpenFilex.open(path);
            },
          ),
          const SizedBox(height: 10),
          _hubTile(
            icon: Icons.bar_chart_rounded,
            color: _kGreen,
            title: 'Results',
            subtitle: 'Subject-wise marks, grades & GPA',
            onTap: () => Get.to(() => ExamResultPage(exam: exam)),
          ),
        ],
      ),
    );
  }

  Widget _hubTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: sansproSemibold.copyWith(fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.black45)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamRoutinePage extends StatefulWidget {
  final ExamItem exam;
  const ExamRoutinePage({super.key, required this.exam});

  @override
  State<ExamRoutinePage> createState() => _ExamRoutinePageState();
}

class _ExamRoutinePageState extends State<ExamRoutinePage> {
  final ExamController ctrl = Get.find<ExamController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchRoutine(widget.exam.examId, widget.exam.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text('Exam Routine',
            style: sansproSemibold.copyWith(fontSize: 17)),
      ),
      body: Obx(() {
        if (ctrl.isRoutineLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.routineHasError.value) {
          return _ErrorPanel(
              message: ctrl.routineErrorMessage.value,
              onRetry: () =>
                  ctrl.fetchRoutine(widget.exam.examId, widget.exam.name));
        }
        if (ctrl.routine.isEmpty) {
          return const _EmptyPanel(message: 'Routine not published yet.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: ctrl.routine.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final r = ctrl.routine[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: _kAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          r.date.split(' ').first,
                          style: sansproBold.copyWith(fontSize: 15, color: _kAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.subject,
                              style: sansproSemibold.copyWith(fontSize: 14)),
                          const SizedBox(height: 3),
                          Text('${r.day}, ${r.date}',
                              style: sansproRegular.copyWith(fontSize: 12, color: Colors.black45)),
                          Text('${r.startTime} – ${r.endTime}  •  ${r.venue}',
                              style: sansproRegular.copyWith(fontSize: 12, color: Colors.black45)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class ExamResultPage extends StatefulWidget {
  final ExamItem exam;
  const ExamResultPage({super.key, required this.exam});

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  final ExamController ctrl = Get.find<ExamController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchResult(widget.exam.examId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text('Results',
            style: sansproSemibold.copyWith(fontSize: 17)),
      ),
      body: Obx(() {
        if (ctrl.isResultLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.resultHasError.value) {
          return _ErrorPanel(
              message: ctrl.resultErrorMessage.value,
              onRetry: () => ctrl.fetchResult(widget.exam.examId));
        }
        final r = ctrl.examResult.value;
        if (r == null) return const SizedBox.shrink();

        final isPassed = r.overallResult.toLowerCase() == 'pass';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.examName,
                              style: sansproBold.copyWith(fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('Total: ${r.totalObtained}/${r.totalFull}',
                              style: sansproRegular.copyWith(fontSize: 13, color: Colors.black54)),
                          Text('GPA: ${r.gpa}',
                              style: sansproRegular.copyWith(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: (isPassed ? _kGreen : _kRed).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        r.overallResult,
                        style: sansproBold.copyWith(color: isPassed ? _kGreen : _kRed, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade100),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(0.8),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFF5F6FA)),
                      children: [
                        _Cell(text: 'Subject', bold: true),
                        _Cell(text: 'Marks', bold: true),
                        _Cell(text: 'Full', bold: true),
                        _Cell(text: 'Grade', bold: true),
                      ],
                    ),
                    ...r.subjects.map((s) {
                      final pass = s.status.toLowerCase() == 'pass';
                      return TableRow(children: [
                        _Cell(text: s.subject),
                        _Cell(
                            text: s.marksObtained,
                            color: pass ? _kGreen : _kRed),
                        _Cell(text: s.fullMarks),
                        _Cell(text: s.grade, bold: true),
                      ]);
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;
  const _Cell({required this.text, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontFamily: bold ? "SourceSansProBold" : "SourceSansProRegular",
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  final ExamController ctrl = Get.find<ExamController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchPromotion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text('Promotion Status',
            style: sansproSemibold.copyWith(fontSize: 17)),
      ),
      body: Obx(() {
        if (ctrl.isPromotionLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.promotionHasError.value) {
          return _ErrorPanel(
              message: ctrl.promotionErrorMessage.value,
              onRetry: ctrl.fetchPromotion);
        }
        final p = ctrl.promotion.value;
        if (p == null) return const SizedBox.shrink();

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: (p.isPromoted ? _kGreen : _kRed).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        p.isPromoted
                            ? Icons.trending_up_rounded
                            : Icons.info_outline_rounded,
                        color: p.isPromoted ? _kGreen : _kRed,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      p.isPromoted ? 'Promoted!' : 'Not Promoted',
                      style: sansproBold.copyWith(
                        fontSize: 22,
                        color: p.isPromoted ? _kGreen : _kRed,
                      ),
                    ),
                    if (p.isPromoted) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Next class: ${p.promotedToClass} – ${p.promotedToSection}',
                        style: sansproRegular.copyWith(fontSize: 15, color: Colors.black54),
                      ),
                      Text(
                        'Session: ${p.session}',
                        style: sansproRegular.copyWith(fontSize: 13, color: Colors.black38),
                      ),
                    ],
                    if (p.remarks.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        p.remarks,
                        textAlign: TextAlign.center,
                        style: sansproRegular.copyWith(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(
              color: Color(0xFFFFEFEF), shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded, size: 28, color: _kRed),
        ),
        const SizedBox(height: 12),
        Text('Something went wrong',
            style: sansproSemibold.copyWith(fontSize: 14)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 13, color: Colors.black45)),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text('Try again', style: sansproSemibold.copyWith(color: Colors.white)),
        ),
      ]),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String message;
  const _EmptyPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(
              color: Color(0xFFEEEBFF), shape: BoxShape.circle),
          child: const Icon(Icons.inbox_outlined, size: 28, color: _kAccent),
        ),
        const SizedBox(height: 12),
        Text('Nothing here yet',
            style: sansproSemibold.copyWith(fontSize: 14)),
        const SizedBox(height: 4),
        Text(message,
            style: sansproRegular.copyWith(fontSize: 13, color: Colors.black45)),
      ]),
    );
  }
}