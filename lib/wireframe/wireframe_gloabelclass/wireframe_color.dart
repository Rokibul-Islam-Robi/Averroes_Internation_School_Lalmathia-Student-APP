import 'package:flutter/material.dart';

class WireframeColor {
  WireframeColor._(); // প্রাইভেট কনস্ট্রাক্টর, যাতে কেউ এই ক্লাসের অবজেক্ট তৈরি করতে না পারে

  // ── Base & System Colors ──────────────────────────────────────────────────
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  static const Color appgray = Color(0xff777777);
  static const Color textgray = Color(0xffA5A5A5);
  static const Color appcolor = Color(0xff345FB4);
  static const Color lightappcolor = Color(0xff6789CA);
  static const Color bggray = Color(0xffE1E3E8);
  static const Color lightgray = Color(0xffF5F6FC);
  static const Color red = Color(0xffE92020);
  static const Color green = Color(0xff0BAC00);
  static const Color lightgreen = Color(0x1A6AC259);
  static const Color lightwhite = Color(0x26FFFFFF);
  static const Color lightblack = Color(0xff424242);

  // ── Menu tile "icon badge" duotone palette ──────────────────────────────
  // প্রতিটা মডিউলের একটা নিজের রঙ থাকে (school subject-folder এর মতো রঙ-কোডিং),
  // যাতে dashboard আরো colorful আর সহজে চেনা যায়। প্রতিটার একটা হালকা
  // background আর একটা গাঢ় icon রঙ — দুইটা একসাথে "duotone badge" বানায়।
  static const Color quizBadgeBg = Color(0xffFFEDD5);
  static const Color quizBadgeIcon = Color(0xffF97316);

  static const Color assignmentBadgeBg = Color(0xffDBEAFE);
  static const Color assignmentBadgeIcon = Color(0xff2563EB);

  static const Color holidayBadgeBg = Color(0xffFCE7F3);
  static const Color holidayBadgeIcon = Color(0xffDB2777);

  static const Color timetableBadgeBg = Color(0xffD1FAE5);
  static const Color timetableBadgeIcon = Color(0xff059669);

  static const Color resultBadgeBg = Color(0xffE0E7FF);
  static const Color resultBadgeIcon = Color(0xff4F46E5);

  static const Color datesheetBadgeBg = Color(0xffFEF3C7);
  static const Color datesheetBadgeIcon = Color(0xffD97706);

  static const Color doubtsBadgeBg = Color(0xffFEE2E2);
  static const Color doubtsBadgeIcon = Color(0xffDC2626);

  static const Color galleryBadgeBg = Color(0xffF3E8FF);
  static const Color galleryBadgeIcon = Color(0xff9333EA);

  static const Color leaveBadgeBg = Color(0xffFFE4E6);
  static const Color leaveBadgeIcon = Color(0xffE11D48);

  static const Color passwordBadgeBg = Color(0xffE0F2FE);
  static const Color passwordBadgeIcon = Color(0xff0284C7);

  static const Color eventBadgeBg = Color(0xffFEF9C3);
  static const Color eventBadgeIcon = Color(0xffCA8A04);

  static const Color logoutBadgeBg = Color(0xffF1F5F9);
  static const Color logoutBadgeIcon = Color(0xff64748B);

  static const Color busBadgeBg = Color(0xffCFFAFE);
  static const Color busBadgeIcon = Color(0xff0891B2);

  static const Color layoutBadgeBg = Color(0xffEDE9FE);
  static const Color layoutBadgeIcon = Color(0xff7C3AED);

  static const Color subjectsBadgeBg = Color(0xffCCFBF1);
  static const Color subjectsBadgeIcon = Color(0xff0D9488);

  static const Color liveClassBadgeBg = Color(0xffE0E7FF);
  static const Color liveClassBadgeIcon = Color(0xff4F46E5);

  static const Color smartClassRoomBadgeBg = Color(0xffE0E7FF);
  static const Color smartClassRoomBadgeIcon = Color(0xff4338CA);

  static const Color teachersMaterialsBadgeBg = Color(0xffCCFBF1);
  static const Color teachersMaterialsBadgeIcon = Color(0xff0D9488);

  // ── Notification type colors (used as icon badge inside the list) ──────
  static const Color notifHomeworkBg = Color(0xffDBEAFE);
  static const Color notifHomeworkIcon = Color(0xff2563EB);

  static const Color notifExamBg = Color(0xffE0E7FF);
  static const Color notifExamIcon = Color(0xff4F46E5);

  static const Color notifFeeBg = Color(0xffFFE4E6);
  static const Color notifFeeIcon = Color(0xffE11D48);

  static const Color notifHolidayBg = Color(0xffFCE7F3);
  static const Color notifHolidayIcon = Color(0xffDB2777);

  static const Color notifGeneralBg = Color(0xffF1F5F9);
  static const Color notifGeneralIcon = Color(0xff64748B);
}