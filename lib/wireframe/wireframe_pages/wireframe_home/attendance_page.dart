import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import '../../wireframe_gloabelclass/wireframe_icons.dart';
import 'package:get/get.dart';
import 'attendance_controller.dart';
import 'student_controller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// STUDENT CURRENT-MONTH ATTENDANCE PAGE
// Matched to Student_Attendance_API_Current_Month.md
// Displays real student attendance, biometric punches, statistics & calendar
// ════════════════════════════════════════════════════════════════════════════

const Color _kPresentColor = Color(0xFF10B981); // Emerald Green
const Color _kLateColor = Color(0xFFF59E0B);    // Amber Orange
const Color _kAbsentColor = Color(0xFFEF4444);  // Coral Red
const Color _kLeaveColor = Color(0xFF8B5CF6);   // Purple
const Color _kNotRecorded = Color(0xFF94A3B8);  // Slate Gray

// Light colorful pastel palette for day numbers
const List<Map<String, Color>> _kDayNumberPalette = [
  {'bg': Color(0xffEFF6FF), 'border': Color(0xffBFDBFE), 'text': Color(0xff1D4ED8)}, // Soft Blue
  {'bg': Color(0xffECFDF5), 'border': Color(0xffA7F3D0), 'text': Color(0xff047857)}, // Soft Emerald
  {'bg': Color(0xffFFF7ED), 'border': Color(0xffFED7AA), 'text': Color(0xffC2410C)}, // Soft Warm Orange
  {'bg': Color(0xffFAF5FF), 'border': Color(0xffE9D5FF), 'text': Color(0xff7E22CE)}, // Soft Purple
  {'bg': Color(0xffF0FDFA), 'border': Color(0xff99F6E4), 'text': Color(0xff0F766E)}, // Soft Teal
  {'bg': Color(0xffFFF1F2), 'border': Color(0xffFECDD3), 'text': Color(0xffBE123C)}, // Soft Rose
  {'bg': Color(0xffFEFCE8), 'border': Color(0xffFEF08A), 'text': Color(0xffA16207)}, // Soft Amber
  {'bg': Color(0xffEEF2FF), 'border': Color(0xffC7D2FE), 'text': Color(0xff4338CA)}, // Soft Indigo
];

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({Key? key}) : super(key: key);

  @override
  State<AttendanceCalendarPage> createState() => _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage>
    with SingleTickerProviderStateMixin {
  final AttendanceController ctrl = Get.put(AttendanceController());
  final StudentController studentCtrl = Get.put(StudentController());
  late TabController _tabController;
  String _selectedLogFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Attendance'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Attendance',
            onPressed: () => ctrl.refreshAttendance(),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            tooltip: 'Range Report',
            onPressed: () => Get.to(() => const AttendanceRangeReportPage()),
          ),
        ],
      ),
      body: PageBackground(
        category: PageCategory.attendance,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),

            // ── Main Content Area ──
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (ctrl.hasError.value) {
                  return _buildErrorState(height);
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Month & Student Info Header Card
                        _buildStudentMonthBanner(context, width, height),
                        const SizedBox(height: 12),

                        // 2. Attendance Summary KPI Cards
                        _buildSummaryKpiGrid(width, height),
                        const SizedBox(height: 12),

                        // 3. Attendance Percentage & Punch Rate Card
                        _buildPercentageBanner(width, height),
                        const SizedBox(height: 12),

                        // 4. Tab Selector (Calendar View / Daily Punch Logs)
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xffE2E8F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(3.5),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            labelColor: WireframeColor.appcolor,
                            unselectedLabelColor: const Color(0xff64748B),
                            labelStyle: sansproBold.copyWith(fontSize: 13),
                            unselectedLabelStyle: sansproSemibold.copyWith(fontSize: 13),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: "Calendar View"),
                              Tab(text: "Daily Punch Logs"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 5. Tab Content
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            return _tabController.index == 0
                                ? _buildCalendarContainer(context, width, height)
                                : _buildDailyLogList(context, width, height);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
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
  // HEADER CARD: Student info & Month details
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStudentMonthBanner(BuildContext context, double width, double height) {
    final studentData = ctrl.student.value;
    final profileData = studentCtrl.profile.value;
    final monthData = ctrl.currentMonth.value;

    final String name = studentData?.studentName.isNotEmpty == true
        ? studentData!.studentName
        : (profileData?.studentName.isNotEmpty == true ? profileData!.studentName : "Student");
    final String cls = studentData?.className.isNotEmpty == true
        ? studentData!.className
        : (profileData?.className.isNotEmpty == true ? profileData!.className : "Class");
    final String sec = studentData?.sectionName.isNotEmpty == true
        ? studentData!.sectionName
        : (profileData?.section.isNotEmpty == true ? profileData!.section : "");
    final String roll = studentData?.rollNo.isNotEmpty == true
        ? studentData!.rollNo
        : (profileData?.studentId.isNotEmpty == true ? profileData!.studentId : "");
    final String monthLabel = monthData?.label.isNotEmpty == true
        ? monthData!.label
        : _getMonthLabel(ctrl.focusedMonth.value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Month Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xffEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: Color(0xff2563EB), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthLabel,
                    style: sansproBold.copyWith(fontSize: 16, color: const Color(0xff0F172A)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xff86EFAC),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 12,
                      color: Color(0xff16A34A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Live Record",
                      style: sansproBold.copyWith(
                        fontSize: 10.5,
                        color: const Color(0xff16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xffF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              // Student Profile Picture
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: WireframeColor.appcolor.withAlpha(60), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Obx(() {
                    final photoUrl = studentCtrl.profile.value?.profilePhotoUrl;
                    if (photoUrl != null && photoUrl.isNotEmpty) {
                      return Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          WireframePngimage.dp,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    return Image.asset(
                      WireframePngimage.dp,
                      fit: BoxFit.cover,
                    );
                  }),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff1E293B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "$cls${sec.isNotEmpty ? ' ($sec)' : ''}${roll.isNotEmpty ? ' • ID: $roll' : ''}",
                      style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUMMARY KPI GRID (Present, Absent)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSummaryKpiGrid(double width, double height) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _kpiCard(
              title: "Present",
              count: ctrl.presentCount,
              icon: Icons.check_circle_rounded,
              color: _kPresentColor,
              bgColor: const Color(0xffECFDF5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _kpiCard(
              title: "Late",
              count: ctrl.lateCount,
              icon: Icons.access_time_filled_rounded,
              color: _kLateColor,
              bgColor: const Color(0xffFEF3C7),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _kpiCard(
              title: "Absent",
              count: ctrl.absentCount,
              icon: Icons.cancel_rounded,
              color: _kAbsentColor,
              bgColor: const Color(0xffFEF2F2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            "$count",
            style: sansproBold.copyWith(fontSize: 18, color: const Color(0xff0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: sansproSemibold.copyWith(fontSize: 12, color: const Color(0xff64748B)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PERCENTAGE BANNER & BIOMETRIC RATE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPercentageBanner(double width, double height) {
    final double pct = ctrl.attendancePercentage;
    final int attended = ctrl.attendedDays;
    final int totalEvaluated = ctrl.totalEvaluatedClassDays;
    final int punchDays = ctrl.devicePunchDays;
    final bool hasRecords = ctrl.hasAttendanceRecorded;

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
            color: const Color(0xff0B1E4D).withAlpha(40),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Monthly Attendance Record",
                style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.white.withAlpha(200)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: !hasRecords
                      ? Colors.white.withAlpha(25)
                      : (pct >= 80 ? const Color(0xff10B981).withAlpha(40) : const Color(0xffF59E0B).withAlpha(40)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  !hasRecords
                      ? "In Progress"
                      : (pct >= 80 ? "Excellent" : (pct >= 60 ? "Average" : "In Progress")),
                  style: sansproSemibold.copyWith(
                    fontSize: 10.5,
                    color: !hasRecords
                        ? Colors.white.withAlpha(180)
                        : (pct >= 80 ? const Color(0xff34D399) : const Color(0xffFCD34D)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasRecords
                ? (pct % 1 == 0 ? "${pct.toInt()}%" : "${pct.toStringAsFixed(1)}%")
                : "—",
            style: sansproBold.copyWith(fontSize: 28, color: Colors.white, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: hasRecords ? (pct / 100).clamp(0.0, 1.0) : 0.0,
              minHeight: 6,
              backgroundColor: Colors.white.withAlpha(35),
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 80 ? const Color(0xff10B981) : (pct >= 60 ? const Color(0xffF59E0B) : const Color(0xff38BDF8)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$attended / $totalEvaluated Class Days",
                style: sansproSemibold.copyWith(fontSize: 11, color: Colors.white.withAlpha(180)),
              ),
              Text(
                "$punchDays Biometric Punch Days",
                style: sansproSemibold.copyWith(fontSize: 11, color: Colors.white.withAlpha(180)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CALENDAR CONTAINER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCalendarContainer(BuildContext context, double width, double height) {
    final monthVal = ctrl.currentMonth.value?.value;
    DateTime activeDate = ctrl.focusedMonth.value;
    if (monthVal != null && monthVal.contains('-')) {
      final parts = monthVal.split('-');
      if (parts.length >= 2) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (y != null && m != null) {
          activeDate = DateTime(y, m, 1);
        }
      }
    }

    final firstDay = DateTime(activeDate.year, activeDate.month, 1);
    final daysInMonth = DateTime(activeDate.year, activeDate.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sun

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day Header
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: sansproBold.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox.shrink();
              }
              final dayNum = index - startWeekday + 1;
              final dayDate = DateTime(activeDate.year, activeDate.month, dayNum);
              final rec = ctrl.getRecordForDay(dayDate);

              final bool isRecordedLate = (rec != null && (rec.status.toUpperCase() == 'L' || rec.statusEnum == AttendanceStatus.late));
              final bool isRecordedPresent = (rec != null && !isRecordedLate && (rec.status.toUpperCase() == 'P' || rec.statusEnum == AttendanceStatus.present || rec.totalPunches > 0));
              final bool isFridayOff = (dayDate.weekday == DateTime.friday || rec?.isFriday == true || rec?.statusEnum == AttendanceStatus.holiday) && !isRecordedPresent && !isRecordedLate;
              final bool isRecordedAbsent = (rec != null && rec.statusEnum == AttendanceStatus.absent && !isFridayOff && !isRecordedPresent && !isRecordedLate);

              Color bg;
              Color border;
              Color textCol;

              if (isRecordedLate) {
                bg = const Color(0xffFEF3C7);
                border = _kLateColor;
                textCol = const Color(0xffB45309);
              } else if (isRecordedPresent) {
                bg = const Color(0xffDCFCE7);
                border = _kPresentColor;
                textCol = const Color(0xff166534);
              } else if (isRecordedAbsent) {
                bg = const Color(0xffFEE2E2);
                border = _kAbsentColor;
                textCol = const Color(0xff991B1B);
              } else if (isFridayOff) {
                bg = const Color(0xffF1F5F9);
                border = const Color(0xffCBD5E1);
                textCol = const Color(0xff64748B);
              } else {
                bg = const Color(0xffF8FAFC);
                border = const Color(0xffE2E8F0);
                textCol = const Color(0xff94A3B8);
              }

              final today = DateTime.now();
              final bool isToday = rec?.isToday ?? (dayDate.day == today.day && dayDate.month == today.month && dayDate.year == today.year);

              return InkWell(
                onTap: () => _showDayDetailModal(context, dayDate, rec),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isToday ? WireframeColor.appcolor : border, width: isToday ? 2 : 1),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$dayNum",
                        style: sansproBold.copyWith(
                          fontSize: 13,
                          color: textCol,
                        ),
                      ),
                      if (isRecordedPresent || isRecordedLate || isRecordedAbsent) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: border,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Legend Footer - Present, Late, Absent
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(_kPresentColor, "Present"),
              const SizedBox(width: 18),
              _legendItem(_kLateColor, "Late"),
              const SizedBox(width: 18),
              _legendItem(_kAbsentColor, "Absent"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: sansproSemibold.copyWith(fontSize: 10, color: const Color(0xff64748B)),
        ),
      ],
    );
  }

  Widget _logFilterChip(String label, int count) {
    final bool isSelected = _selectedLogFilter == label;
    final Color activeColor = label == 'Present'
        ? _kPresentColor
        : (label == 'Late'
            ? _kLateColor
            : (label == 'Absent' ? _kAbsentColor : WireframeColor.appcolor));

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLogFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xffE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withAlpha(35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: sansproBold.copyWith(
                fontSize: 12,
                color: isSelected ? Colors.white : const Color(0xff64748B),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withAlpha(40) : const Color(0xffF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: sansproBold.copyWith(
                  fontSize: 10.5,
                  color: isSelected ? Colors.white : const Color(0xff475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DAILY LOG & PUNCH RECORDS LIST (Total Classes Only - Excludes Friday/Off Days)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDailyLogList(BuildContext context, double width, double height) {
    final rawList = ctrl.classAttendanceList;

    final list = rawList.where((rec) {
      if (_selectedLogFilter == 'All') return true;
      if (_selectedLogFilter == 'Present') {
        return (rec.status.toUpperCase() == 'P' || rec.statusEnum == AttendanceStatus.present) &&
            rec.status.toUpperCase() != 'L' &&
            rec.statusEnum != AttendanceStatus.late;
      }
      if (_selectedLogFilter == 'Late') {
        return rec.status.toUpperCase() == 'L' || rec.statusEnum == AttendanceStatus.late;
      }
      if (_selectedLogFilter == 'Absent') {
        return rec.statusEnum == AttendanceStatus.absent;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _logFilterChip('All', rawList.length),
              const SizedBox(width: 8),
              _logFilterChip('Present', ctrl.presentCount),
              const SizedBox(width: 8),
              _logFilterChip('Late', ctrl.lateCount),
              const SizedBox(width: 8),
              _logFilterChip('Absent', ctrl.absentCount),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                "No class attendance logs found for '$_selectedLogFilter'.",
                style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final rec = list[i];
              final int dayNum = int.tryParse(rec.date.split('-').last) ?? (i + 1);
              final colorMap = _kDayNumberPalette[(dayNum - 1) % _kDayNumberPalette.length];

              final bool isLate = (rec.status.toUpperCase() == 'L' || rec.statusEnum == AttendanceStatus.late);
              final bool isPresent = !isLate && (rec.status.toUpperCase() == 'P' || rec.statusEnum == AttendanceStatus.present || rec.totalPunches > 0);
              final bool isOffDay = (rec.isFriday || rec.statusEnum == AttendanceStatus.holiday) && !isPresent && !isLate;
              final bool isAbsent = (rec.statusEnum == AttendanceStatus.absent) && !isOffDay && !isPresent && !isLate;
              final bool isLeave = (rec.statusEnum == AttendanceStatus.leave) && !isOffDay && !isPresent && !isLate;

              final Color statusColor;
              final Color statusBg;
              final Color statusBorder;
              final String displayLabel;
              final IconData statusIcon;

              if (isLate) {
                statusColor = const Color(0xffD97706);
                statusBg = const Color(0xffFEF3C7);
                statusBorder = const Color(0xffFDE68A);
                displayLabel = "Late";
                statusIcon = Icons.access_time_filled_rounded;
              } else if (isPresent) {
                statusColor = const Color(0xff15803D);
                statusBg = const Color(0xffDCFCE7);
                statusBorder = const Color(0xff86EFAC);
                displayLabel = "Present";
                statusIcon = Icons.check_circle_rounded;
              } else if (isOffDay) {
                statusColor = const Color(0xff475569);
                statusBg = const Color(0xffF1F5F9);
                statusBorder = const Color(0xffCBD5E1);
                displayLabel = "Off Day";
                statusIcon = Icons.event_available_rounded;
              } else if (isAbsent) {
                statusColor = const Color(0xffB91C1C);
                statusBg = const Color(0xffFEE2E2);
                statusBorder = const Color(0xffFECACA);
                displayLabel = "Absent";
                statusIcon = Icons.cancel_rounded;
              } else if (isLeave) {
                statusColor = const Color(0xff7C3AED);
                statusBg = const Color(0xffFAF5FF);
                statusBorder = const Color(0xffE9D5FF);
                displayLabel = "Leave";
                statusIcon = Icons.time_to_leave_rounded;
              } else {
                statusColor = const Color(0xff64748B);
                statusBg = const Color(0xffF1F5F9);
                statusBorder = const Color(0xffCBD5E1);
                displayLabel = "Not Recorded";
                statusIcon = Icons.hourglass_empty_rounded;
              }

              return InkWell(
                onTap: () {
                  final dt = DateTime.tryParse(rec.date) ?? DateTime.now();
                  _showDayDetailModal(context, dt, rec);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffF1F5F9), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Day Icon with light colorful duotone styling
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorMap['bg'],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorMap['border']!, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: colorMap['text']!.withAlpha(18),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            dayNum.toString().padLeft(2, '0'),
                            style: sansproBold.copyWith(fontSize: 16, color: colorMap['text']),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rec.day,
                                  style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff1E293B)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  rec.date,
                                  style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.login_rounded, size: 13, color: Color(0xff16A34A)),
                                const SizedBox(width: 3),
                                Text(
                                  rec.formattedCheckIn,
                                  style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff334155)),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.logout_rounded, size: 13, color: Color(0xffEA580C)),
                                const SizedBox(width: 3),
                                Text(
                                  rec.formattedCheckOut,
                                  style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff334155)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Light colorful indicator badge for status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusBorder, width: 1.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              displayLabel,
                              style: sansproBold.copyWith(fontSize: 11, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DAY DETAILS MODAL BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════════════
  void _showDayDetailModal(BuildContext context, DateTime date, DailyAttendanceRecord? rec) {
    final bool isLate = (rec != null && (rec.status.toUpperCase() == 'L' || rec.statusEnum == AttendanceStatus.late));
    final bool isPresent = (rec != null && !isLate && (rec.status.toUpperCase() == 'P' || rec.statusEnum == AttendanceStatus.present || rec.totalPunches > 0));
    final bool isOffDay = (date.weekday == DateTime.friday || rec?.isFriday == true || rec?.statusEnum == AttendanceStatus.holiday) && !isPresent && !isLate;
    final bool isAbsent = (rec != null && rec.statusEnum == AttendanceStatus.absent) && !isOffDay && !isPresent && !isLate;
    final bool isLeave = (rec != null && rec.statusEnum == AttendanceStatus.leave) && !isOffDay && !isPresent && !isLate;

    final Color statusColor;
    final Color statusBg;
    final String statusLabel;

    if (isLate) {
      statusColor = const Color(0xffD97706);
      statusBg = const Color(0xffFEF3C7);
      statusLabel = "Late Attendance";
    } else if (isPresent) {
      statusColor = const Color(0xff15803D);
      statusBg = const Color(0xffDCFCE7);
      statusLabel = "Present";
    } else if (isOffDay) {
      statusColor = const Color(0xff475569);
      statusBg = const Color(0xffF1F5F9);
      statusLabel = "Off Day";
    } else if (isAbsent) {
      statusColor = const Color(0xffB91C1C);
      statusBg = const Color(0xffFEE2E2);
      statusLabel = "Absent";
    } else if (isLeave) {
      statusColor = const Color(0xff7C3AED);
      statusBg = const Color(0xffFAF5FF);
      statusLabel = "Leave";
    } else {
      statusColor = const Color(0xff64748B);
      statusBg = const Color(0xffF1F5F9);
      statusLabel = "Not Recorded";
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_weekdayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}",
                        style: sansproBold.copyWith(fontSize: 16, color: const Color(0xff0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rec?.source != null && rec!.source != 'none'
                            ? "Source: ${rec.source.replaceAll('_', ' ').toUpperCase()}"
                            : (isOffDay ? "Weekly Holiday / Off Day" : (isAbsent ? "Formally Marked Absent" : "No Attendance Recorded")),
                        style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: sansproBold.copyWith(fontSize: 12, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: const Color(0xffF1F5F9)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _punchInfoBox(
                      icon: Icons.login_rounded,
                      iconColor: const Color(0xff16A34A),
                      label: "Check-in Punch",
                      time: rec?.formattedCheckIn ?? "—",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _punchInfoBox(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xffD97706),
                      label: "Check-out Punch",
                      time: rec?.formattedCheckOut ?? "—",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _punchInfoBox(
                      icon: Icons.fingerprint_rounded,
                      iconColor: const Color(0xff2563EB),
                      label: "Total Punches",
                      time: "${rec?.totalPunches ?? 0} Punches",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _punchInfoBox(
                      icon: Icons.verified_user_rounded,
                      iconColor: const Color(0xff7C3AED),
                      label: "Status Verification",
                      time: isOffDay
                          ? "Weekly Off Day"
                          : (rec?.isRecorded == true ? "Recorded" : "Pending"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // SMS Message status box in biometric punch system
              _smsNotificationBox(
                isPresent: isPresent,
                rec: rec,
                date: date,
              ),
              if (rec?.remarks != null && rec!.remarks!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Text(
                    "Note: ${rec.remarks}",
                    style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff475569)),
                  ),
                ),
              ],
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _smsNotificationBox({
    required bool isPresent,
    required DailyAttendanceRecord? rec,
    required DateTime date,
  }) {
    final hasPunch = rec != null && rec.totalPunches > 0;
    final checkIn = rec?.formattedCheckIn;
    final bool hasValidCheckIn = checkIn != null && checkIn.isNotEmpty && checkIn != "—";
    final isSmsSent = isPresent || (hasPunch && hasValidCheckIn);
    final dateStr = "${date.day} ${_getMonthName(date.month)} ${date.year}";
    final timeStr = hasValidCheckIn ? checkIn : "Recorded Time";

    final Color iconColor = isSmsSent ? const Color(0xff6366F1) : const Color(0xff94A3B8);
    final Color badgeBg = isSmsSent ? const Color(0xffEEF2FF) : const Color(0xffF1F5F9);
    final Color badgeText = isSmsSent ? const Color(0xff4F46E5) : const Color(0xff64748B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.sms_rounded, color: iconColor, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "SMS Message",
                      style: sansproRegular.copyWith(fontSize: 10.5, color: const Color(0xff64748B)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSmsSent ? "Received" : "Not Received",
                        style: sansproBold.copyWith(fontSize: 9.5, color: badgeText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isSmsSent
                      ? "Biometric punch SMS sent to guardian at $timeStr on $dateStr"
                      : "No biometric punch SMS generated on $dateStr",
                  style: sansproSemibold.copyWith(
                    fontSize: 11.5,
                    color: const Color(0xff1E293B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            isSmsSent ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isSmsSent ? const Color(0xff10B981) : const Color(0xff94A3B8),
          ),
        ],
      ),
    );
  }



  Widget _punchInfoBox({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: sansproRegular.copyWith(fontSize: 10, color: const Color(0xff64748B)),
                ),
                Text(
                  time,
                  style: sansproBold.copyWith(fontSize: 13, color: const Color(0xff0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(double height) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xffFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xffDC2626), size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              "Could not load attendance",
              style: sansproBold.copyWith(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              ctrl.errorMessage.value,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ctrl.refreshAttendance(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: WireframeColor.appcolor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _getMonthName(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  String _weekdayName(int w) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[w - 1];
  }
}

// ════════════════════════════════════════════════════════════════════════════
// RANGE REPORT PAGE
// ════════════════════════════════════════════════════════════════════════════

class AttendanceRangeReportPage extends StatelessWidget {
  const AttendanceRangeReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController ctrl = Get.find<AttendanceController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Attendance Report'.tr,
      ),
      body: PageBackground(
        category: PageCategory.attendance,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _DatePickerTile(label: 'From', obs: ctrl.rangeFrom)),
                    const SizedBox(width: 10),
                    Expanded(child: _DatePickerTile(label: 'To', obs: ctrl.rangeTo)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: ctrl.fetchRangeReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WireframeColor.appcolor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Go', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (ctrl.isRangeLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (ctrl.rangeHasError.value) {
                  return Center(
                    child: Text(
                      ctrl.rangeErrorMessage.value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (ctrl.rangeData.isEmpty) {
                  return const Center(
                    child: Text(
                      'Select a date range above and tap Go.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                final days = ctrl.rangeData;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = days[i];
                    Color col;
                    switch (d.status) {
                      case AttendanceStatus.present:
                        col = _kPresentColor;
                        break;
                      case AttendanceStatus.late:
                        col = _kLateColor;
                        break;
                      case AttendanceStatus.absent:
                        col = _kAbsentColor;
                        break;
                      case AttendanceStatus.leave:
                        col = _kLeaveColor;
                        break;
                      case AttendanceStatus.holiday:
                        col = const Color(0xff64748B);
                        break;
                      default:
                        col = _kNotRecorded;
                        break;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${d.date.day.toString().padLeft(2, '0')}-${d.date.month.toString().padLeft(2, '0')}-${d.date.year}',
                              style: sansproSemibold.copyWith(fontSize: 13.5, color: const Color(0xff1E293B)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: col.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              d.status == AttendanceStatus.holiday ? 'OFF DAY' : d.status.name.toUpperCase(),
                              style: sansproBold.copyWith(fontSize: 11, color: col),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final RxString obs;
  const _DatePickerTile({required this.label, required this.obs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          obs.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        }
      },
      child: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black45),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                obs.value.isEmpty ? label : obs.value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: obs.value.isEmpty ? Colors.black38 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}