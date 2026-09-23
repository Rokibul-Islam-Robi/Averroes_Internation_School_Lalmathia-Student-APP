import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'wireframe_home/attendance_page.dart';
import 'wireframe_home/exam_page.dart';
import 'wireframe_home/fees_overview_page.dart';
import 'wireframe_home/homework_list_page.dart';
import 'wireframe_home/notification_page.dart';
import 'wireframe_home/syllabus_page.dart';
import 'wireframe_home/wireframe_assignment.dart';
import 'wireframe_home/wireframe_bus.dart';
import 'wireframe_home/wireframe_changepassword.dart';
import 'wireframe_home/wireframe_events.dart';
import 'wireframe_home/wireframe_holiday.dart';
import 'wireframe_home/wireframe_profile.dart';
import 'wireframe_home/wireframe_result.dart';
import 'wireframe_home/wireframe_subjects.dart';
import 'wireframe_home/wireframe_support.dart';
import 'wireframe_home/wireframe_timetable.dart';

class DeepLinkHandler {
  static final _appLinks = AppLinks();
  static bool _initialized = false;

  static Future<void> init(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await Future.delayed(const Duration(milliseconds: 800));
        _navigate(initialUri);
      }
    } catch (_) {}

    _appLinks.uriLinkStream.listen(
          (uri) => _navigate(uri),
      onError: (_) {},
    );
  }

  static void _navigate(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return;
    final route = segments.last;
    final page = _pageForRoute(route);
    if (page == null) return;
    Get.to(() => page, transition: Transition.rightToLeft);
  }

  static Widget? _pageForRoute(String route) {
    switch (route.toLowerCase()) {
      case 'fees':
      case 'payment':
      case 'dues':
        return const FeesOverviewPage();
      case 'attendance':
        return const AttendanceCalendarPage();
      case 'homework':
        return const HomeworkListPage(lockedType: 'Homework');
      case 'classwork':
        return const HomeworkListPage(lockedType: 'Classwork');
      case 'syllabus':
        return const SyllabusListPage();
      case 'exams':
      case 'examination':
        return const ExamListPage();
      case 'reportcard':
      case 'report-card':
      case 'report':
      case 'result':
        return const WireframeResult();
      case 'bus':
      case 'transport':
        return const WireframeBus();
      case 'notifications':
      case 'notification':
        return const NotificationPage();
      case 'profile':
        return const WireframeProfile();
      case 'holiday':
        return const WireframeHoliday();
      case 'timetable':
      case 'time-table':
        return const WireframeTimetable();
      case 'assignment':
        return const WireframeAssignment();
      case 'subjects':
        return const WireframeSubjects();
      case 'events':
        return const WireframeEvents();
      case 'support':
      case 'help':
        return const WireframeSupport();
      case 'change-password':
      case 'changepassword':
        return const WireframeChangePassword();
      default:
        return null;
    }
  }
}
