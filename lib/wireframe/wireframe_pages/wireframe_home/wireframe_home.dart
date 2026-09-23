import 'dart:async';
import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_login.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/fees_controller.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_events.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_eventdetails.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_profile.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_timetable.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_bus.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/student_controller.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/notification_controller.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/notification_page.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_drawer.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'fees_overview_page.dart';

// Existing new modules
import 'report_card_controller.dart';             // ReportCardController
import 'attendance_controller.dart';              // AttendanceController

// ── ২০২৬-০৮-০৫ dashboard restructure অনুযায়ী নতুন/সরাসরি ব্যবহৃত মডিউল ──
import 'attendance_page.dart';                    // AttendanceCalendarPage
import 'teachers_materials_classes_page.dart';     // TeachersMaterialsClassesPage → Class Materials
import 'teachers_materials_announcements_page.dart'; // TeachersMaterialsAnnouncementsPage → Announcement
import 'teachers_materials_documents_page.dart';   // TeachersMaterialsDocumentsPage → Official Documents
import 'live_now_page.dart';                       // LiveNowPage (API আসার অপেক্ষায়)
import 'today_live_classes_page.dart';             // TodayLiveClassesPage (API আসার অপেক্ষায়)
import 'complain_page.dart';                       // ComplainPage
import 'appointment_page.dart';                    // AppointmentPage (Schedule with School Officials)
import 'wireframe_result.dart';                    // WireframeResult

// ── নিচের মডিউলগুলো client-এর নতুন নির্দেশ অনুযায়ী dashboard থেকে সরানো
// হয়েছে (Assignment, Holiday, Leave Application, Play Quiz, Ask Doubts,
// School Gallery, Class Section Directory, Report Card, Examination,
// old Live Class, Smart Class Room, Result, Teachers Materials hub) —
// পেজ file গুলো প্রজেক্টে এখনো আছে, শুধু dashboard-এ আর import/ব্যবহার
// করা হচ্ছে না।

import '../../wireframe_gloabelclass/wireframe_color.dart';

class WireframeHome extends StatefulWidget {
  const WireframeHome({Key? key}) : super(key: key);

  @override
  State<WireframeHome> createState() => _WireframeHomeState();
}

class _WireframeHomeState extends State<WireframeHome>
    with TickerProviderStateMixin {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  // ── নতুন সাইড ড্রয়ার open করার জন্য — 3-dot আইকনে ট্যাপ করলে এই key দিয়ে
  // Scaffold.of() ছাড়াই সরাসরি drawer খোলা হয় ──
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final themedata = Get.put(WireframeThemecontroler());
  final feesCtrl = Get.put(FeesController());
  final studentCtrl = Get.put(StudentController());
  final notifCtrl = Get.put(NotificationController());
  final attCtrl = Get.put(AttendanceController());
  final reportCardCtrl = Get.put(ReportCardController());

  String _getCurrentAcademicSession(String apiAcademicYear) {
    final trimmed = apiAcademicYear.trim();
    final now = DateTime.now();
    final currentYear = now.year;
    final currentSession = "$currentYear-${currentYear + 1}";

    if (trimmed.isEmpty) return currentSession;
    if (trimmed.contains('$currentYear') && trimmed.contains('${currentYear + 1}')) {
      return trimmed;
    }
    return currentSession;
  }

  // ── Hero header entrance animation — greeting/avatar/chip subtly fade +
  // slide in on first load, ekta modern corporate feel dewar jonno। ──
  late final AnimationController _heroAnimCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _heroFade =
  CurvedAnimation(parent: _heroAnimCtrl, curve: const Interval(0.0, 1.0, curve: Curves.easeOut));
  late final Animation<Offset> _heroSlide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _heroAnimCtrl, curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic)));
  late final Animation<double> _avatarScale = Tween<double>(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _heroAnimCtrl, curve: const Interval(0.25, 1.0, curve: Curves.elasticOut)));

  // ── Slow continuous glow-pulse behind the avatar — small touch that makes
  // the header feel "alive" instead of a static banner (corporate polish). ──
  late final AnimationController _pulseAnimCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  late final Animation<double> _pulseScale =
  Tween<double>(begin: 1.0, end: 1.16).animate(CurvedAnimation(parent: _pulseAnimCtrl, curve: Curves.easeInOut));
  late final Animation<double> _pulseOpacity =
  Tween<double>(begin: 0.35, end: 0.0).animate(CurvedAnimation(parent: _pulseAnimCtrl, curve: Curves.easeOut));

  // ── Upcoming Events — sliding carousel (corporate-style auto-scroll) ──────
  final PageController _eventsPageController =
  PageController(viewportFraction: 0.86);
  Timer? _eventsAutoScrollTimer;
  int _eventsCurrentPage = 0;

  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Victory Day Activities',
      'date': 'Dec 16, 2026',
      'time': '09:00 AM - 01:30 PM',
      'location': 'Averroes Main Campus, Lalmatia, Dhaka',
      'category': 'National Celebration',
      'colors': const [Color(0xff0F5132), Color(0xff1B7A43)],
      'icon': Icons.flag_rounded,
      'image': WireframePngimage.eventVictoryDay,
      'description':
          'Averroes International School Lalmatia cordially invites all students, parents, and faculty members to commemorate our glorious Victory Day with deep national pride and solemn reverence.\n\n'
          'The day begins with the ceremonial hoisting of the National Flag followed by Quran recitation and a special du\'a for our heroic martyrs. Students from all branches will participate in patriotic cultural performances, national anthem recitations, and an inter-class art & poster exhibition celebrating our history. Special awards and certificates will be presented to student achievers.',
      'highlights': [
        '09:00 AM: National Flag Hoisting & Special Du\'a for Martyrs',
        '09:30 AM: Welcome Address by Honorable Principal & Faculty',
        '10:15 AM: Inter-Class Patriotic Art & Poster Exhibition',
        '11:15 AM: Cultural Program (Patriotic Songs & Poetry)',
        '12:30 PM: Prize Distribution & Certificate Awarding Ceremony',
      ],
    },
    {
      'title': 'STEM Week 2025',
      'date': 'Jan 12, 2027',
      'time': '09:00 AM - 02:00 PM',
      'location': 'Lalmatia Campus STEM Labs & Auditorium',
      'category': 'Science & Technology',
      'colors': const [Color(0xffEA580C), Color(0xffF97316)],
      'icon': Icons.science_rounded,
      'image': WireframePngimage.eventStemWeek,
      'description':
          'STEM Week at Averroes International School Lalmatia is a premier academic festival designed to inspire curiosity, creativity, and scientific inquiry among young learners.\n\n'
          'Throughout this week-long event, students engage in hands-on science experiments, robotics demonstrations, coding workshops, mathematical puzzle challenges, and sustainable environmental innovation models. Eminent guest educators and technology experts will conduct interactive keynote sessions, and students will present their team research projects to a panel of expert judges.',
      'highlights': [
        'Day 1: Interactive Chemistry & Physics Experiment Showcase',
        'Day 2: Junior Robotics & Coding Challenge (Scratch & Arduino)',
        'Day 3: Speed Math Olympiad & Logic Puzzle Championship',
        'Day 4: Eco-Innovations & Sustainable Technology Expo',
        'Day 5: Grand Project Judging & Young Scientist Award Ceremony',
      ],
    },
    {
      'title': 'Annual Field Trip',
      'date': 'Feb 02, 2027',
      'time': '08:30 AM - 04:30 PM',
      'location': 'National Museum of Science & Technology, Dhaka',
      'category': 'Outdoor Study Tour',
      'colors': const [Color(0xff0284C7), Color(0xff38BDF8)],
      'icon': Icons.directions_bus_filled_rounded,
      'image': WireframePngimage.eventFieldTrip,
      'description':
          'The Annual Educational Field Trip of Averroes International School Lalmatia offers students an enriching experiential learning journey outside the traditional classroom.\n\n'
          'Guided by our experienced faculty members and safety supervisors, students will explore interactive science galleries, celestial observatory exhibits, and biodiversity parks. The trip includes guided museum tours, group scientific observation tasks, fun learning quizzes, and fully catered halal lunch and refreshments provided under comprehensive school supervision.',
      'highlights': [
        '08:30 AM: Student Assembly & Departure in AC School Buses',
        '09:45 AM: Guided Tour of Science & Space Innovation Galleries',
        '12:00 PM: 3D Planetarium & Space Exploration Show',
        '01:15 PM: Congregational Dhuhr Prayer & Catered Lunch',
        '02:30 PM: Team Quiz & Science Discovery Workshop',
        '04:00 PM: Safe Return & Disembarkation at Lalmatia Campus',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _heroAnimCtrl.forward();
    // প্রতি ৩.৫ সেকেন্ডে events card গুলো নিজে থেকে পাশে স্লাইড করবে
    _eventsAutoScrollTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!_eventsPageController.hasClients || _upcomingEvents.length < 2) return;
      _eventsCurrentPage = (_eventsCurrentPage + 1) % _upcomingEvents.length;
      _eventsPageController.animateToPage(
        _eventsCurrentPage,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });

    // ── API guide ("HTTP errors and required app behavior") onujayi: 401
    // pele stored token clear kore login-e ferot pathate hobe। Eita manual
    // logout na — token e ar kaj korche na bole, seshoparjonto login page
    // chara r kono upay nei। ──
    ever(studentCtrl.isSessionExpired, (bool expired) async {
      if (!expired || !mounted) return;
      await WireframeSession.clearSession();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WireframeLogin()),
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _heroAnimCtrl.dispose();
    _pulseAnimCtrl.dispose();
    _eventsAutoScrollTimer?.cancel();
    _eventsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xffF3F5FB), // মডার্ন হালকা corporate ব্যাকগ্রাউন্ড (সাদার বদলে)
      drawer: const WireframeAppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header banner ("Hi Student") — modern corporate hero: layered
            // gradient + soft decorative shapes + glass icon buttons + a
            // subtle fade/slide/scale entrance animation. Attendance/Fees card
            // গুলো এখানে overlap করছে না; সেগুলো Upcoming Events এর পরে সরানো
            // হয়েছে, যাতে greeting এর ঠিক পরেই Upcoming Events চোখে পড়ে
            // (client requirement — অপরিবর্তিত)।
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: Container(
                width: width / 1,
                height: height / 3.35,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff0B1E4D),
                      WireframeColor.appcolor,
                      WireframeColor.lightappcolor,
                    ],
                    stops: [0.0, 0.55, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33345FB4),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // ── Decorative soft circles — corporate "depth" layer ──
                    Positioned(
                      right: -width / 6,
                      top: -width / 9,
                      child: Container(
                        width: width / 2.2,
                        height: width / 2.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(18),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -width / 7,
                      bottom: -width / 10,
                      child: Container(
                        width: width / 2.6,
                        height: width / 2.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(14),
                        ),
                      ),
                    ),
                    Positioned(
                      right: width / 4.5,
                      bottom: -width / 16,
                      child: Container(
                        width: width / 5,
                        height: width / 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(28), width: 1.4),
                        ),
                      ),
                    ),

                    // ── One-time diagonal "shine" sweep on load — small premium
                    // touch, plays once alongside the greeting fade/slide-in. ──
                    AnimatedBuilder(
                      animation: _heroAnimCtrl,
                      builder: (context, _) {
                        final t = _heroAnimCtrl.value;
                        return Positioned.fill(
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment(-1.6 + (3.2 * t), -1),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Container(
                                  width: width / 3,
                                  height: height,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withAlpha((28 * (1 - t)).round().clamp(0, 28)),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // ── Actual header content, fade+slide in on load ──
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 26, vertical: height / 45),
                      child: Column(
                        children: [
                          SizedBox(height: height / 80),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const NotificationPage())),
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: width / 100),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(50),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Obx(() {
                                    final unread = notifCtrl.unreadCount;
                                    final total = notifCtrl.notifications.length;
                                    final displayCount = unread > 0 ? unread : (total > 0 ? total : 0);
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(Icons.notifications_outlined,
                                            color: WireframeColor.white,
                                            size: height / 40),
                                        if (displayCount > 0)
                                          Positioned(
                                            right: -3,
                                            top: -3,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: displayCount > 9 ? 3.5 : 2,
                                                  vertical: 1),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xffF5F3FF), Color(0xffEDE9FE)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: const Color(0xffC4B5FD),
                                                  width: 0.9,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xff7C3AED).withAlpha(45),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1.5),
                                                  ),
                                                ],
                                              ),
                                              constraints: const BoxConstraints(
                                                  minWidth: 13.5, minHeight: 13.5),
                                              child: Center(
                                                child: Text(
                                                  displayCount > 99
                                                      ? "99+"
                                                      : "$displayCount",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Color(0xff5B21B6),
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w800,
                                                      height: 1.0,
                                                      letterSpacing: -0.2),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                              // ── 3-dot আইকন ──
                              InkWell(
                                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.more_vert,
                                      color: WireframeColor.white, size: height / 40),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / 90),
                          FadeTransition(
                            opacity: _heroFade,
                            child: SlideTransition(
                              position: _heroSlide,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back'.tr,
                                          style: sansproSemibold.copyWith(
                                            fontSize: 12.5,
                                            color: Colors.white.withAlpha(190),
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        SizedBox(height: height / 250),
                                        Obx(() => Text(
                                          studentCtrl.profile.value != null
                                              ? "Hi, ${studentCtrl.profile.value!.studentName.split(' ').first}"
                                              : "Hi Student".tr,
                                          style: sansproSemibold.copyWith(
                                            fontSize: 25,
                                            color: WireframeColor.white,
                                          ),
                                        )),
                                        SizedBox(height: height / 220),
                                        Obx(() => studentCtrl.profile.value != null
                                            ? Text(
                                          "Class ${studentCtrl.profile.value!.className}-${studentCtrl.profile.value!.section}  •  ID ${studentCtrl.profile.value!.studentId.isNotEmpty ? studentCtrl.profile.value!.studentId : studentCtrl.profile.value!.rollNo}",
                                          style: sansproRegular.copyWith(
                                            fontSize: 13,
                                            color: Colors.white.withAlpha(215),
                                          ),
                                        )
                                            : const SizedBox.shrink()),
                                        SizedBox(height: height / 110),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: Colors.white.withAlpha(235),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(25),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 46,
                                                vertical: height / 190),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.calendar_today_rounded,
                                                    size: 12, color: WireframeColor.appcolor),
                                                SizedBox(width: width / 130),
                                                Obx(() => Text(
                                                  _getCurrentAcademicSession(studentCtrl.profile.value?.academicYear ?? ""),
                                                  style: sansproSemibold.copyWith(
                                                    fontSize: 12,
                                                    color: WireframeColor.appcolor,
                                                  ),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: width / 40),
                                  ScaleTransition(
                                    scale: _avatarScale,
                                    child: InkWell(
                                      highlightColor: WireframeColor.transparent,
                                      splashColor: WireframeColor.transparent,
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) {
                                              return const WireframeProfile();
                                            }));
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        clipBehavior: Clip.none,
                                        children: [
                                          // soft pulsing glow ring — matching rectangular shape
                                          AnimatedBuilder(
                                            animation: _pulseAnimCtrl,
                                            builder: (context, _) => Transform.scale(
                                              scale: _pulseScale.value,
                                              child: Container(
                                                width: width / 4.8,
                                                height: width / 4.0,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(18),
                                                  color: Colors.white.withValues(alpha: _pulseOpacity.value),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: width / 5.1,
                                            height: width / 4.2,
                                            padding: const EdgeInsets.all(2.5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              gradient: const LinearGradient(
                                                colors: [Colors.white, Color(0xffBFD3FF)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(35),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(13.5),
                                              child: Obx(() {
                                                final photoUrl = studentCtrl.profile.value?.profilePhotoUrl;
                                                if (photoUrl != null && photoUrl.isNotEmpty) {
                                                  return Image.network(
                                                    photoUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder: (_, __, ___) => Image.asset(
                                                      WireframePngimage.dp,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                  );
                                                }
                                                return Image.asset(
                                                  WireframePngimage.dp,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: height / 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Upcoming Events — auto-sliding carousel ────────────────────────
            SizedBox(height: height / 65),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 26),
              child: Row(
                children: [
                  Text(
                    "Upcoming Events".tr,
                    style: sansproSemibold.copyWith(fontSize: 17, color: WireframeColor.black),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const WireframeEvents())),
                    child: Text(
                      "See all".tr,
                      style: sansproSemibold.copyWith(fontSize: 13, color: WireframeColor.appcolor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height / 90),
            SizedBox(
              height: height / 3.7,
              child: PageView.builder(
                controller: _eventsPageController,
                onPageChanged: (i) => setState(() => _eventsCurrentPage = i),
                itemCount: _upcomingEvents.length,
                itemBuilder: (context, index) {
                  final event = _upcomingEvents[index];
                  final eventColor = (event['colors'] as List<Color>)[0];
                  return AnimatedBuilder(
                    animation: _eventsPageController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (_eventsPageController.position.haveDimensions) {
                        final page = _eventsPageController.page ?? _eventsCurrentPage.toDouble();
                        scale = (1 - ((page - index).abs() * 0.08)).clamp(0.92, 1.0);
                      }
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 90),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WireframeEventDetails(
                              title: event['title'] as String,
                              date: event['date'] as String,
                              time: event['time'] as String,
                              location: event['location'] as String,
                              category: event['category'] as String,
                              image: event['image'] as String,
                              description: event['description'] as String,
                              highlights: event['highlights'] as List<String>,
                            ),
                          ),
                        ),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: eventColor.withAlpha(70),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                event['image'] as String,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: height / 6.2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        eventColor.withAlpha(0),
                                        eventColor.withAlpha(235),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width / 46,
                                top: width / 46,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(225),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(event['icon'] as IconData, color: eventColor, size: 16),
                                ),
                              ),
                              Positioned(
                                left: width / 32,
                                right: width / 32,
                                bottom: height / 90,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      event['title'] as String,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: sansproSemibold.copyWith(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: height / 250),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today_rounded,
                                            size: 11, color: Colors.white.withAlpha(230)),
                                        const SizedBox(width: 4),
                                        Text(
                                          event['date'] as String,
                                          style: sansproRegular.copyWith(
                                              fontSize: 11.5, color: Colors.white.withAlpha(230)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: height / 60),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_upcomingEvents.length, (i) {
                  final active = i == _eventsCurrentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? WireframeColor.appcolor : WireframeColor.bggray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // ── Attendance + Fees Due cards ──────────────────────────────
            // client requirement onujayi: ekhon ei card duto Upcoming Events
            // section er pore bosano hoyeche (age header er sathe overlap korchilo).
            SizedBox(height: height / 60),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 36),
              child: Row(
                children: [
                  InkWell(
                    highlightColor: WireframeColor.transparent,
                    splashColor: WireframeColor.transparent,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return const AttendanceCalendarPage();
                          }));
                    },
                    child: Container(
                      width: width / 2.35,
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 42, vertical: height / 70),
                      decoration: BoxDecoration(
                        color: WireframeColor.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xffFFE7C2), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(14),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xffFFF3E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.calendar_month_rounded,
                                    size: 16, color: Color(0xffFF9100)),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 17, color: WireframeColor.textgray),
                            ],
                          ),
                          SizedBox(height: height / 110),
                          Obx(() {
                            if (attCtrl.isLoading.value && notifCtrl.isSummaryLoading.value) {
                              return const SizedBox(
                                height: 30,
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2),
                                ),
                              );
                            }
                            final double? pct = attCtrl.attendanceList.isNotEmpty || attCtrl.hasAttendanceRecorded
                                ? attCtrl.attendancePercentage
                                : (attCtrl.summary.value?.attendancePercentage ?? notifCtrl.summary.value?.attendancePercentage);
                            return Text(
                              pct != null
                                  ? (pct % 1 == 0 ? "${pct.toInt()}%" : "${pct.toStringAsFixed(1)}%")
                                  : "—",
                              style: sansproSemibold.copyWith(
                                fontSize: 25,
                                color: WireframeColor.black,
                              ),
                            );
                          }),
                          SizedBox(height: height / 300),
                          Text(
                            "Attendance".tr,
                            style: sansproRegular.copyWith(
                              fontSize: 12.5,
                              color: WireframeColor.textgray,
                            ),
                          ),
                          SizedBox(height: height / 110),
                          // ── ছোট "calendar week strip" — বর্তমান সপ্তাহের
                          // দিন গুলো mini calendar আকারে দেখানো, আজকের দিনটা
                          // accent color দিয়ে highlight করা ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              final isToday = (DateTime.now().weekday - 1) == i;
                              return Container(
                                width: width / 20,
                                height: width / 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? const Color(0xffFF9100)
                                      : const Color(0xffFFF3E0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SMTWTFS'[i],
                                  style: sansproSemibold.copyWith(
                                    fontSize: 8,
                                    color: isToday
                                        ? WireframeColor.white
                                        : const Color(0xffFF9100),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Fees Due Card
                  InkWell(
                    highlightColor: WireframeColor.transparent,
                    splashColor: WireframeColor.transparent,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return const FeesOverviewPage();
                          }));
                    },
                    child: Container(
                      width: width / 2.35,
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 42, vertical: height / 70),
                      decoration: BoxDecoration(
                        color: WireframeColor.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xffF6D9FF), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(14),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xffFCE7FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded,
                                    size: 16, color: Color(0xffB026CC)),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 17, color: WireframeColor.textgray),
                            ],
                          ),
                          SizedBox(height: height / 110),
                          Obx(() {
                            if (feesCtrl.isLoading.value) {
                              return const SizedBox(
                                height: 30,
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2),
                                ),
                              );
                            }
                            return Text(
                              "${feesCtrl.currency.value == 'BDT' ? '৳' : '\$'}${feesCtrl.currentMonthDueAmount.toStringAsFixed(0)}",
                              style: sansproSemibold.copyWith(
                                fontSize: 25,
                                color: WireframeColor.black,
                              ),
                            );
                          }),
                          SizedBox(height: height / 300),
                          Text(
                            "Up to Current Month",
                            style: sansproRegular.copyWith(
                              fontSize: 12,
                              color: WireframeColor.textgray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: height / 110),
                          // ── attendance card এর সাথে height/rhythm মিলিয়ে
                          // রাখতে একই height-এর একটা subtle progress-style
                          // strip — due status এর একটা visual cue ──
                          Obx(() {
                            final due = feesCtrl.isLoading.value ? 0.0 : feesCtrl.currentMonthDueAmount;
                            final hasDue = due > 0;
                            return Container(
                              width: double.infinity,
                              height: width / 20,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: hasDue
                                    ? const Color(0xffFCE7FF)
                                    : const Color(0xffE3FCEF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hasDue ? "All Dues" : "All Clear",
                                style: sansproSemibold.copyWith(
                                  fontSize: 9,
                                  color: hasDue
                                      ? const Color(0xffB026CC)
                                      : const Color(0xff0F9D58),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Menu Grid — এখন "Services populaires" reference style অনুযায়ী
            // modern 4-column icon-tile grid: soft pastel rounded-square
            // background, icon মাঝখানে, label নিচে ছোট করে। একই ১২টা module,
            // একই ক্রম, একই icon/color/navigation — শুধু layout/look বদলানো
            // হয়েছে, কোনো নতুন feature/connection যোগ করা হয়নি।
            // ── Menu Grid — User Requested Order:
            // 1. Class Materials → 2. Class Routine → 3. Announcement → 4. Syllabus →
            // 5. Attendance → 6. School Fees → 7. Official Documents → 8. Live Now →
            // 9. Today Live Classes → 10. Bus Service → 11. Complain
            // (Homework & Classwork are temporarily hidden from dashboard)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width / 26, vertical: height / 65),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: height / 60,
                crossAxisSpacing: width / 50,
                childAspectRatio: 0.76,
                children: [
                  // 1. Assignment (Soft Sky Blue)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.assignment_rounded,
                    label: "Assignment".tr,
                    badgeBg: const Color(0xffE0F2FE),
                    iconColor: const Color(0xff0284C7),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TeachersMaterialsClassesPage())),
                  ),
                  // 2. Class Routine (Soft Warm Orange)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.calendar_month_rounded,
                    label: "Class_Routine".tr,
                    badgeBg: const Color(0xffFFEDD5),
                    iconColor: const Color(0xffEA580C),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const WireframeTimetable())),
                  ),
                  // 3. Notice (Soft Lavender Purple)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.campaign_rounded,
                    label: "Notice".tr,
                    badgeBg: const Color(0xffEDE9FE),
                    iconColor: const Color(0xff7C3AED),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TeachersMaterialsAnnouncementsPage())),
                  ),
                  // 4. Subjects & Syllabus (Hidden per directive)
                  // 5. Attendance (Soft Emerald Mint)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.fact_check_rounded,
                    label: "Attendance".tr,
                    badgeBg: const Color(0xffDCFCE7),
                    iconColor: const Color(0xff16A34A),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AttendanceCalendarPage())),
                  ),
                  // 6. School Fees (Soft Rose Crimson)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.payments_rounded,
                    label: "School_Fees".tr,
                    badgeBg: const Color(0xffFFE4E6),
                    iconColor: const Color(0xffE11D48),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FeesOverviewPage())),
                  ),
                  // 7. Official Documents (Soft Lilac Violet)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.description_rounded,
                    label: "Official_Documents".tr,
                    badgeBg: const Color(0xffF3E8FF),
                    iconColor: const Color(0xff9333EA),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TeachersMaterialsDocumentsPage())),
                  ),
                  // 8. Live Now (Soft Coral Red)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.podcasts_rounded,
                    label: "Live_Now".tr,
                    badgeBg: const Color(0xffFEE2E2),
                    iconColor: const Color(0xffEF4444),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LiveNowPage())),
                  ),
                  // 9. Today Live Classes (Soft Indigo Blue)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.today_rounded,
                    label: "Today_Live_Classes".tr,
                    badgeBg: const Color(0xffDBEAFE),
                    iconColor: const Color(0xff2563EB),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TodayLiveClassesPage())),
                  ),
                  // 10. Bus Service (Soft Aquamarine Teal)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.directions_bus_filled_rounded,
                    label: "Bus_Service".tr,
                    badgeBg: const Color(0xffCCFBF1),
                    iconColor: const Color(0xff0D9488),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const WireframeBus())),
                  ),
                  // 11. Feedback (Soft Rose Red)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.feedback_rounded,
                    label: "Feedback".tr,
                    badgeBg: const Color(0xffFFE4E6),
                    iconColor: const Color(0xffF43F5E),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ComplainPage())),
                  ),
                  // 12. Appointment (Executive Soft Cyan / Navy)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.event_available_rounded,
                    label: "Appointment".tr,
                    badgeBg: const Color(0xffE0F2FE),
                    iconColor: const Color(0xff0284C7),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AppointmentPage())),
                  ),
                  // 13. Result (Soft Royal Indigo)
                  _serviceTile(
                    width: width, height: height,
                    icon: '',
                    materialIcon: Icons.grade_rounded,
                    label: "Result".tr,
                    badgeBg: const Color(0xffEEF2FF),
                    iconColor: const Color(0xff4F46E5),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const WireframeResult())),
                  ),
                ],
              ),
            ),

            // ── Dashboard Footer — Clean Contact Numbers (side-by-side) & Copyright ──
            SizedBox(height: height / 46),
            _buildSchoolFooter(width: width, height: height),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ══════════════════════════════════════════════════════════════════════

  // ══════════════════════════════════════════════════════════════════════
  // MODERN CORPORATE DASHBOARD FOOTER
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildSchoolFooter({required double width, required double height}) {
    return Container(
      width: width,
      margin: EdgeInsets.fromLTRB(width / 26, 0, width / 26, height / 60),
      padding: EdgeInsets.symmetric(horizontal: width / 22, vertical: height / 50),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22345FB4),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Contact numbers side by side (2 numbers) ──
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _footerContactChip(
                icon: Icons.call_rounded,
                text: "+880 1954-123 123",
                trailingTag: "WhatsApp",
              ),
              _footerContactChip(
                icon: Icons.call_rounded,
                text: "+880 1949-000 555",
              ),
            ],
          ),
          SizedBox(height: height / 80),
          Divider(color: Colors.white.withAlpha(35), thickness: 1),
          SizedBox(height: height / 100),

          // ── Copyright ──
          Text(
            "Copyright © 2026 Averroes International School Lalmatia.",
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
              fontSize: 11,
              color: Colors.white.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerContactChip({
    required IconData icon,
    required String text,
    String? trailingTag,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withAlpha(220)),
        const SizedBox(width: 5),
        Text(
          text,
          style: sansproSemibold.copyWith(fontSize: 12, color: WireframeColor.white),
        ),
        if (trailingTag != null) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xff25D366).withAlpha(210),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trailingTag,
              style: sansproSemibold.copyWith(fontSize: 9, color: WireframeColor.white),
            ),
          ),
        ],
      ],
    );
  }

  // ── Service Tile — modern corporate rounded-square icon tile: soft shadow,
  // responsive sizing, perfectly proportioned text and zero overflow on all devices. ──
  Widget _serviceTile({
    required double width,
    required double height,
    required String icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    IconData? materialIcon,
    Color badgeBg = WireframeColor.lightgray,
  }) {
    final Color accent = iconColor ?? WireframeColor.appcolor;
    final double iconBoxSize = (width / 6.0).clamp(48.0, 64.0);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      highlightColor: WireframeColor.transparent,
      splashColor: WireframeColor.transparent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: iconBoxSize,
            width: iconBoxSize,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: accent.withAlpha(35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: materialIcon != null
                  ? Icon(materialIcon, size: iconBoxSize * 0.48, color: accent)
                  : Image.asset(icon,
                  height: iconBoxSize * 0.48,
                  fit: BoxFit.fitHeight,
                  color: accent),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sansproSemibold.copyWith(
                fontSize: 11,
                height: 1.15,
                color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

}