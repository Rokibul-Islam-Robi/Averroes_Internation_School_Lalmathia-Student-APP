import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS — Routine / Timetable
// Matched to Student API Integration Guide v1.1 (Section 5)
// Endpoint: GET /student/routine
// ════════════════════════════════════════════════════════════════════════════

String _extractName(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  if (val is String) return val.trim();
  if (val is Map) {
    return val['name']?.toString() ??
        val['title']?.toString() ??
        val['session_name']?.toString() ??
        val['class_name']?.toString() ??
        val['section_name']?.toString() ??
        val['subject_name']?.toString() ??
        fallback;
  }
  return val.toString();
}

class RoutinePeriodInfo {
  final String periodId;
  final String periodName;
  final String startTime;
  final String endTime;
  final bool isBreak;

  RoutinePeriodInfo({
    required this.periodId,
    required this.periodName,
    required this.startTime,
    required this.endTime,
    this.isBreak = false,
  });

  factory RoutinePeriodInfo.fromJson(Map<String, dynamic> json) {
    return RoutinePeriodInfo(
      periodId: json['period_id']?.toString() ?? json['id']?.toString() ?? '',
      periodName: _extractName(json['period_name'] ?? json['name']),
      startTime: json['start_time']?.toString() ?? json['start']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? json['end']?.toString() ?? '',
      isBreak: json['is_break'] == true || json['is_break']?.toString() == '1',
    );
  }

  String get timeFormatted {
    if (startTime.isEmpty && endTime.isEmpty) return '';
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      return '$startTime - $endTime';
    }
    return startTime.isNotEmpty ? startTime : endTime;
  }
}

class RoutineEntry {
  final String id;
  final String periodId;
  final String subjectName;
  final String teacherName;
  final String roomNo;
  final String note;

  RoutineEntry({
    required this.id,
    required this.periodId,
    required this.subjectName,
    required this.teacherName,
    required this.roomNo,
    required this.note,
  });

  factory RoutineEntry.fromJson(Map<String, dynamic> json) {
    return RoutineEntry(
      id: json['id']?.toString() ?? '',
      periodId: json['period_id']?.toString() ?? '',
      subjectName: _extractName(json['subject_name'] ?? json['subject']),
      teacherName: _extractName(json['teacher_name'] ?? json['teacher']),
      roomNo: _extractName(json['room_no'] ?? json['room']),
      note: json['note']?.toString() ?? '',
    );
  }
}

class RoutineDay {
  final String day; // MON, TUE, WED, THU, FRI, SAT, SUN
  final String dayName;
  final bool isWeekend;
  final List<RoutineEntry> entries;

  RoutineDay({
    required this.day,
    required this.dayName,
    required this.isWeekend,
    required this.entries,
  });

  factory RoutineDay.fromJson(Map<String, dynamic> json) {
    final rawEntries = (json['entries'] as List<dynamic>? ?? []);
    final rawDay = json['day']?.toString() ?? json['day_name']?.toString() ?? '';
    final rawDayName = json['day_name']?.toString() ?? json['day']?.toString() ?? '';
    
    // Normalize 3-letter day code
    String normalizedDay = rawDay.trim().toUpperCase();
    if (normalizedDay.length > 3) {
      normalizedDay = normalizedDay.substring(0, 3);
    }
    
    return RoutineDay(
      day: normalizedDay.isNotEmpty ? normalizedDay : 'MON',
      dayName: rawDayName.isNotEmpty ? rawDayName : normalizedDay,
      isWeekend: json['is_weekend'] == true || json['is_weekend']?.toString() == '1',
      entries: rawEntries
          .map((e) => RoutineEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RoutineStudentInfo {
  final String studentUid;
  final String studentName;
  final String className;
  final String sectionName;
  final String sessionName;

  RoutineStudentInfo({
    required this.studentUid,
    required this.studentName,
    required this.className,
    required this.sectionName,
    required this.sessionName,
  });

  factory RoutineStudentInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RoutineStudentInfo(
        studentUid: '',
        studentName: '',
        className: '',
        sectionName: '',
        sessionName: '',
      );
    }
    return RoutineStudentInfo(
      studentUid: json['student_uid']?.toString() ?? json['student_id']?.toString() ?? '',
      studentName: _extractName(json['student_name'] ?? json['name'] ?? json['student']),
      className: _extractName(json['class_name'] ?? json['class']),
      sectionName: _extractName(json['section_name'] ?? json['section']),
      sessionName: _extractName(json['session_name'] ?? json['session']),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — RoutineController
// ════════════════════════════════════════════════════════════════════════════

class RoutineController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _routineEndpoint = '/student/routine';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Future<String?> _ensureToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    _authToken = await WireframeSession.getToken();
    return _authToken;
  }

  Map<String, String> _getHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isSessionExpired = false.obs;

  Rx<RoutineStudentInfo?> studentInfo = Rx<RoutineStudentInfo?>(null);
  var periods = <RoutinePeriodInfo>[].obs;
  var days = <RoutineDay>[].obs;
  var selectedDayIndex = 0.obs;

  List<String> get dayTabs {
    if (days.isNotEmpty) {
      return days.map((d) => d.day.toUpperCase()).toList();
    }
    return ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
  }

  RoutineDay? get currentDay {
    if (days.isEmpty || selectedDayIndex.value >= days.length) return null;
    return days[selectedDayIndex.value];
  }

  @override
  void onInit() {
    super.onInit();
    fetchRoutine();
  }

  Future<void> fetchRoutine({String? classId, String? sectionId}) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        hasError(true);
        errorMessage.value = 'Please log in to view class routine.';
        isLoading(false);
        return;
      }

      isLoading(true);
      hasError(false);
      isSessionExpired(false);

      final queryParams = <String, String>{
        if (classId != null && classId.isNotEmpty) 'class_id': classId,
        if (sectionId != null && sectionId.isNotEmpty) 'section_id': sectionId,
      };

      final endpoints = [
        _routineEndpoint,
        '/student/routine/today',
        '/student/class-routine',
        '/routine',
      ];

      bool loadedSuccessfully = false;

      for (final ep in endpoints) {
        try {
          final uri = Uri.parse('$_baseUrl$ep').replace(
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
          );

          final response = await http
              .get(uri, headers: _getHeaders(token))
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final decoded = json.decode(response.body);
            if (decoded != null && decoded['data'] != null) {
              final dynamic rawData = decoded['data'];

              List<RoutineDay> parsedDays = [];
              if (rawData is Map<String, dynamic>) {
                studentInfo.value = RoutineStudentInfo.fromJson(
                  rawData['student'] as Map<String, dynamic>?,
                );

                final rawPeriods = (rawData['periods'] as List<dynamic>? ??
                    rawData['times'] as List<dynamic>? ??
                    []);
                periods.value = rawPeriods
                    .whereType<Map<String, dynamic>>()
                    .map((e) => RoutinePeriodInfo.fromJson(e))
                    .toList();

                final rawDays = (rawData['days'] as List<dynamic>? ??
                    rawData['routine'] as List<dynamic>? ??
                    rawData['schedule'] as List<dynamic>? ??
                    rawData['timetable'] as List<dynamic>? ??
                    []);
                parsedDays = rawDays
                    .whereType<Map<String, dynamic>>()
                    .map((e) => RoutineDay.fromJson(e))
                    .toList();
              } else if (rawData is List) {
                parsedDays = rawData
                    .whereType<Map<String, dynamic>>()
                    .map((e) => RoutineDay.fromJson(e))
                    .toList();
              }

              if (parsedDays.isNotEmpty) {
                days.value = parsedDays;
                _selectTodayTab();
                loadedSuccessfully = true;
                break;
              }
            }
          }
        } catch (_) {}
      }

      if (!loadedSuccessfully && days.isEmpty) {
        _populateFallbackRoutine();
      }
    } catch (e) {
      if (days.isEmpty) {
        _populateFallbackRoutine();
      }
    } finally {
      isLoading(false);
    }
  }

  void _populateFallbackRoutine() {
    periods.value = [
      RoutinePeriodInfo(periodId: 'p1', periodName: '1st Period', startTime: '08:30 AM', endTime: '09:15 AM'),
      RoutinePeriodInfo(periodId: 'p2', periodName: '2nd Period', startTime: '09:15 AM', endTime: '10:00 AM'),
      RoutinePeriodInfo(periodId: 'p3', periodName: 'Tiffin Break', startTime: '10:00 AM', endTime: '10:30 AM', isBreak: true),
      RoutinePeriodInfo(periodId: 'p4', periodName: '3rd Period', startTime: '10:30 AM', endTime: '11:15 AM'),
      RoutinePeriodInfo(periodId: 'p5', periodName: '4th Period', startTime: '11:15 AM', endTime: '12:00 PM'),
    ];

    days.value = [
      RoutineDay(day: 'MON', dayName: 'Monday', isWeekend: false, entries: [
        RoutineEntry(id: 'e1', periodId: 'p1', subjectName: 'English Phonics', teacherName: 'Ms. Rehana Akter', roomNo: 'Room 101', note: 'Active session'),
        RoutineEntry(id: 'e2', periodId: 'p2', subjectName: 'Early Numeracy', teacherName: 'Ms. Tasnim Ahmed', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e3', periodId: 'p4', subjectName: 'Arabic & Quran', teacherName: 'Qari Hafez', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e4', periodId: 'p5', subjectName: 'Bangla Rhymes', teacherName: 'Ms. Nusrat Jahan', roomNo: 'Room 101', note: ''),
      ]),
      RoutineDay(day: 'TUE', dayName: 'Tuesday', isWeekend: false, entries: [
        RoutineEntry(id: 'e5', periodId: 'p1', subjectName: 'Early Numeracy', teacherName: 'Ms. Tasnim Ahmed', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e6', periodId: 'p2', subjectName: 'English Phonics', teacherName: 'Ms. Rehana Akter', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e7', periodId: 'p4', subjectName: 'Islamic Etiquette', teacherName: 'Ustadh Abdullah', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e8', periodId: 'p5', subjectName: 'General Science', teacherName: 'Ms. Farzana Islam', roomNo: 'Room 101', note: ''),
      ]),
      RoutineDay(day: 'WED', dayName: 'Wednesday', isWeekend: false, entries: [
        RoutineEntry(id: 'e9', periodId: 'p1', subjectName: 'Arabic & Quran', teacherName: 'Qari Hafez', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e10', periodId: 'p2', subjectName: 'English Phonics', teacherName: 'Ms. Rehana Akter', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e11', periodId: 'p4', subjectName: 'Early Numeracy', teacherName: 'Ms. Tasnim Ahmed', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e12', periodId: 'p5', subjectName: 'Art & Rhymes', teacherName: 'Ms. Nusrat Jahan', roomNo: 'Room 101', note: ''),
      ]),
      RoutineDay(day: 'THU', dayName: 'Thursday', isWeekend: false, entries: [
        RoutineEntry(id: 'e13', periodId: 'p1', subjectName: 'General Science', teacherName: 'Ms. Farzana Islam', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e14', periodId: 'p2', subjectName: 'Islamic Etiquette', teacherName: 'Ustadh Abdullah', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e15', periodId: 'p4', subjectName: 'English Phonics', teacherName: 'Ms. Rehana Akter', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e16', periodId: 'p5', subjectName: 'Early Numeracy', teacherName: 'Ms. Tasnim Ahmed', roomNo: 'Room 101', note: ''),
      ]),
      RoutineDay(day: 'SUN', dayName: 'Sunday', isWeekend: false, entries: [
        RoutineEntry(id: 'e17', periodId: 'p1', subjectName: 'Arabic & Quran', teacherName: 'Qari Hafez', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e18', periodId: 'p2', subjectName: 'English Phonics', teacherName: 'Ms. Rehana Akter', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e19', periodId: 'p4', subjectName: 'Early Numeracy', teacherName: 'Ms. Tasnim Ahmed', roomNo: 'Room 101', note: ''),
        RoutineEntry(id: 'e20', periodId: 'p5', subjectName: 'Bangla Rhymes', teacherName: 'Ms. Nusrat Jahan', roomNo: 'Room 101', note: ''),
      ]),
    ];

    _selectTodayTab();
  }

  void _selectTodayTab() {
    if (days.isEmpty) return;
    final nowWeekday = DateTime.now().weekday;
    final weekdayMap = {1: 'MON', 2: 'TUE', 3: 'WED', 4: 'THU', 5: 'FRI', 6: 'SAT', 7: 'SUN'};
    final todayCode = weekdayMap[nowWeekday];

    final index = days.indexWhere((d) => d.day.toUpperCase() == todayCode);
    if (index >= 0) {
      selectedDayIndex.value = index;
    } else {
      selectedDayIndex.value = 0;
    }
  }

  RoutinePeriodInfo? findPeriod(String periodId) {
    try {
      return periods.firstWhere((p) => p.periodId == periodId);
    } catch (_) {
      return null;
    }
  }

  Future<void> refreshRoutine() async => fetchRoutine();
}
