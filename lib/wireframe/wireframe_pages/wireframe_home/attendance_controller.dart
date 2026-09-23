import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// STUDENT ATTENDANCE API INTEGRATION
// Matched to Student_Attendance_API_Current_Month.md
// Endpoint: GET /api/student/attendance
// Live URL: https://averroesint.com/averroes_school_erp/api/student/attendance
// ════════════════════════════════════════════════════════════════════════════

enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
  notRecorded,
  holiday, // Legacy alias
  none,    // Legacy alias
}

class AttendanceStudent {
  final int? studentId;
  final String studentUid;
  final String studentName;
  final String rollNo;
  final String sessionName;
  final bool isCurrentSession;
  final String className;
  final String sectionName;

  AttendanceStudent({
    this.studentId,
    required this.studentUid,
    required this.studentName,
    required this.rollNo,
    required this.sessionName,
    this.isCurrentSession = true,
    required this.className,
    required this.sectionName,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    final sessionObj = json['session'] as Map<String, dynamic>?;
    final classObj = json['class'] as Map<String, dynamic>?;
    final sectionObj = json['section'] as Map<String, dynamic>?;

    return AttendanceStudent(
      studentId: json['student_id'] is int
          ? json['student_id']
          : int.tryParse(json['student_id']?.toString() ?? ''),
      studentUid: json['student_uid']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      sessionName: sessionObj?['name']?.toString() ?? json['session_name']?.toString() ?? '',
      isCurrentSession: sessionObj?['is_current'] == true || sessionObj?['is_current']?.toString() == '1',
      className: classObj?['name']?.toString() ?? json['class_name']?.toString() ?? '',
      sectionName: sectionObj?['name']?.toString() ?? json['section_name']?.toString() ?? '',
    );
  }
}

class AttendanceMonth {
  final String value; // "2026-08"
  final String label; // "August 2026"
  final String from;  // "2026-08-01"
  final String to;    // "2026-08-31"
  final String timezone; // "Asia/Dhaka"

  AttendanceMonth({
    required this.value,
    required this.label,
    required this.from,
    required this.to,
    required this.timezone,
  });

  factory AttendanceMonth.fromJson(Map<String, dynamic> json) {
    return AttendanceMonth(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'Asia/Dhaka',
    );
  }
}

class AttendanceSummary {
  final int calendarDaysToDate;
  final int recordedDays;
  final int present;
  final int absent;
  final int late;
  final int leave;
  final int notRecorded;
  final int devicePunchDays;
  final double? attendancePercentage;

  AttendanceSummary({
    required this.calendarDaysToDate,
    required this.recordedDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.notRecorded,
    required this.devicePunchDays,
    this.attendancePercentage,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    double? pct;
    if (json['attendance_percentage'] != null) {
      pct = double.tryParse(json['attendance_percentage'].toString());
    }
    return AttendanceSummary(
      calendarDaysToDate: int.tryParse(json['calendar_days_to_date']?.toString() ?? '0') ?? 0,
      recordedDays: int.tryParse(json['recorded_days']?.toString() ?? '0') ?? 0,
      present: int.tryParse(json['present']?.toString() ?? '0') ?? 0,
      absent: int.tryParse(json['absent']?.toString() ?? '0') ?? 0,
      late: int.tryParse(json['late']?.toString() ?? '0') ?? 0,
      leave: int.tryParse(json['leave']?.toString() ?? '0') ?? 0,
      notRecorded: int.tryParse(json['not_recorded']?.toString() ?? '0') ?? 0,
      devicePunchDays: int.tryParse(json['device_punch_days']?.toString() ?? '0') ?? 0,
      attendancePercentage: pct,
    );
  }
}

class DailyAttendanceRecord {
  final String date; // "YYYY-MM-DD"
  final String day;  // "Monday"
  final String status; // "P", "A", "L", "H", "N"
  final String statusLabel; // "Present", "Absent", "Late", "Leave", "Not recorded"
  final bool isRecorded;
  final bool isToday;
  final String source; // "formal", "device", "formal_and_device", "none"
  final String? checkIn; // "07:42:18"
  final String? checkOut; // "13:21:09"
  final int totalPunches;
  final String? remarks;

  DailyAttendanceRecord({
    required this.date,
    required this.day,
    required this.status,
    required this.statusLabel,
    this.isRecorded = false,
    this.isToday = false,
    this.source = 'none',
    this.checkIn,
    this.checkOut,
    this.totalPunches = 0,
    this.remarks,
  });

  bool get isFutureDate {
    final dt = DateTime.tryParse(date);
    if (dt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    return target.isAfter(today);
  }

  bool get isFriday {
    if (day.toLowerCase().trim() == 'friday') return true;
    final dt = DateTime.tryParse(date);
    if (dt != null && dt.weekday == DateTime.friday) return true;
    return false;
  }

  bool get isPunchPresent {
    return status.toUpperCase() == 'P' || status.toUpperCase() == 'L' || totalPunches > 0;
  }

  AttendanceStatus get statusEnum {
    // If biometric punch or marked present/late, always count as present/late
    if (isPunchPresent) {
      if (status.toUpperCase() == 'L') return AttendanceStatus.late;
      return AttendanceStatus.present;
    }
    // Friday is weekly Off Day - never count as absent
    if (isFriday) {
      return AttendanceStatus.holiday;
    }
    // Future unarrived date is upcoming
    if (isFutureDate) {
      return AttendanceStatus.none;
    }
    switch (status.toUpperCase()) {
      case 'H':
        return AttendanceStatus.leave;
      case 'A':
        return AttendanceStatus.absent;
      case 'N':
      default:
        // Regular unrecorded / pending day with 0 punches is Not Recorded - never counted as Absent
        return AttendanceStatus.notRecorded;
    }
  }

  String get effectiveStatusLabel {
    switch (statusEnum) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.leave:
        return 'Leave';
      case AttendanceStatus.holiday:
        return 'Off Day';
      case AttendanceStatus.notRecorded:
        return 'Not Recorded';
      case AttendanceStatus.none:
        return 'Upcoming';
    }
  }

  String get formattedCheckIn {
    if (checkIn == null || checkIn!.trim().isEmpty) return '—';
    return _formatTime12Hour(checkIn!);
  }

  String get formattedCheckOut {
    if (checkOut == null || checkOut!.trim().isEmpty) return '—';
    return _formatTime12Hour(checkOut!);
  }

  static String _formatTime12Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (_) {}
    return time24;
  }

  factory DailyAttendanceRecord.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString() ?? 'N';
    final dateStr = json['date']?.toString() ?? '';
    final dayStr = json['day']?.toString() ?? '';

    bool isFri = dayStr.toLowerCase().trim() == 'friday';
    if (!isFri && dateStr.isNotEmpty) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null && dt.weekday == DateTime.friday) {
        isFri = true;
      }
    }

    final totalP = int.tryParse(json['total_punches']?.toString() ?? '0') ?? 0;
    final bool hasPunches = totalP > 0 || rawStatus.toUpperCase() == 'P' || rawStatus.toUpperCase() == 'L';

    String label = json['status_label']?.toString() ?? '';
    if (label.isEmpty || (isFri && !hasPunches)) {
      if (isFri && !hasPunches) {
        label = 'Off Day';
      } else {
        switch (rawStatus.toUpperCase()) {
          case 'P':
            label = 'Present';
            break;
          case 'A':
            label = 'Absent';
            break;
          case 'L':
            label = 'Late';
            break;
          case 'H':
            label = 'Leave';
            break;
          case 'N':
          default:
            label = 'Not Recorded';
            break;
        }
      }
    } else if (label.toLowerCase() == 'not recorded' && rawStatus.toUpperCase() == 'N') {
      label = 'Not Recorded';
    }

    return DailyAttendanceRecord(
      date: dateStr,
      day: dayStr,
      status: (isFri && !hasPunches) ? 'H' : rawStatus,
      statusLabel: label,
      isRecorded: json['is_recorded'] == true || json['is_recorded']?.toString() == '1',
      isToday: json['is_today'] == true || json['is_today']?.toString() == '1',
      source: json['source']?.toString() ?? 'none',
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      totalPunches: totalP,
      remarks: json['remarks']?.toString(),
    );
  }
}

// Backward-compatible wrapper for legacy callers
class DayAttendance {
  final DateTime date;
  final AttendanceStatus status;
  final String note;
  final String? checkIn;
  final String? checkOut;
  final int totalPunches;

  DayAttendance({
    required this.date,
    required this.status,
    this.note = '',
    this.checkIn,
    this.checkOut,
    this.totalPunches = 0,
  });

  factory DayAttendance.fromDailyRecord(DailyAttendanceRecord record) {
    return DayAttendance(
      date: DateTime.tryParse(record.date) ?? DateTime.now(),
      status: record.statusEnum,
      note: record.remarks ?? '',
      checkIn: record.checkIn,
      checkOut: record.checkOut,
      totalPunches: record.totalPunches,
    );
  }

  factory DayAttendance.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date']?.toString() ?? '';
    final statusStr = json['status']?.toString().toUpperCase() ?? '';
    final dt = DateTime.tryParse(dateStr) ?? DateTime.now();
    final bool isFri = dt.weekday == DateTime.friday;

    AttendanceStatus st;
    if (statusStr == 'P' || statusStr == 'PRESENT') {
      st = AttendanceStatus.present;
    } else if (statusStr == 'L' || statusStr == 'LATE') {
      st = AttendanceStatus.late;
    } else if (statusStr == 'H' || statusStr == 'LEAVE') {
      st = AttendanceStatus.leave;
    } else if (statusStr == 'HOLIDAY' || statusStr == 'FESTIVAL' || isFri) {
      st = AttendanceStatus.holiday;
    } else if (statusStr == 'A' || statusStr == 'ABSENT') {
      st = isFri ? AttendanceStatus.holiday : AttendanceStatus.absent;
    } else {
      st = isFri ? AttendanceStatus.holiday : AttendanceStatus.notRecorded;
    }

    return DayAttendance(
      date: dt,
      status: st,
      note: json['remarks']?.toString() ?? json['note']?.toString() ?? '',
      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),
      totalPunches: int.tryParse(json['total_punches']?.toString() ?? '0') ?? 0,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// REPOSITORY
// ════════════════════════════════════════════════════════════════════════════

class AttendanceRepository {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _attendanceEndpoint = '/student/attendance';

  final http.Client _client;
  AttendanceRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  // Primary call: GET /student/attendance (supports optional ?month=YYYY-MM or ?from=YYYY-MM-DD&to=YYYY-MM-DD)
  Future<http.Response> getAttendance({String? month, String? from, String? to, String? token}) async {
    final Map<String, String> qParams = {};
    if (month != null && month.isNotEmpty) {
      qParams['month'] = month;
    }
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      qParams['from'] = from;
      qParams['to'] = to;
    }
    final uri = Uri.parse('$_baseUrl$_attendanceEndpoint').replace(
      queryParameters: qParams.isNotEmpty ? qParams : null,
    );
    return await _client
        .get(uri, headers: _buildHeaders(token))
        .timeout(const Duration(seconds: 15));
  }

  // Range report fallback / endpoint
  Future<http.Response> getRangeAttendance({
    required String from,
    required String to,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/student/attendance/range').replace(
      queryParameters: {'from': from, 'to': to},
    );
    return await _client
        .get(uri, headers: _buildHeaders(token))
        .timeout(const Duration(seconds: 12));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════

class AttendanceController extends GetxController {
  final AttendanceRepository _repository = AttendanceRepository();
  String? _authToken;

  void setAuthToken(String token) => _authToken = token;

  Future<String?> _ensureToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    _authToken = await WireframeSession.getToken();
    return _authToken;
  }

  // Observable state
  final isLoading = true.obs;
  final isCalendarLoading = true.obs; // Legacy alias
  final hasError = false.obs;
  final calendarHasError = false.obs; // Legacy alias
  final errorMessage = ''.obs;
  final calendarErrorMessage = ''.obs; // Legacy alias

  final student = Rx<AttendanceStudent?>(null);
  final currentMonth = Rx<AttendanceMonth?>(null);
  final summary = Rx<AttendanceSummary?>(null);
  final attendanceList = <DailyAttendanceRecord>[].obs;
  final attendanceMap = <String, DailyAttendanceRecord>{}.obs;

  // Calendar & Month Navigation state
  final calendarData = <String, DayAttendance>{}.obs;
  final focusedMonth = DateTime.now().obs;

  // Range report state
  final isRangeLoading = false.obs;
  final rangeHasError = false.obs;
  final rangeErrorMessage = ''.obs;
  final rangeData = <DayAttendance>[].obs;
  final rangeFrom = ''.obs;
  final rangeTo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentMonthAttendance();
  }

  String _formatKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  // Month Navigation helpers
  bool get isCurrentMonthSelected {
    final now = DateTime.now();
    final f = focusedMonth.value;
    return f.year == now.year && f.month == now.month;
  }

  bool get canGoToNextMonth {
    final now = DateTime.now();
    final f = focusedMonth.value;
    return (f.year < now.year) || (f.year == now.year && f.month < now.month);
  }

  List<DateTime> get availableAcademicMonths {
    final now = DateTime.now();
    final List<DateTime> list = [];
    for (int i = 0; i < 12; i++) {
      list.add(DateTime(now.year, now.month - i, 1));
    }
    return list;
  }

  void previousMonth() {
    final f = focusedMonth.value;
    final prev = DateTime(f.year, f.month - 1, 1);
    fetchMonthAttendance(prev);
  }

  void nextMonth() {
    if (!canGoToNextMonth) return;
    final f = focusedMonth.value;
    final next = DateTime(f.year, f.month + 1, 1);
    fetchMonthAttendance(next);
  }

  void selectMonth(DateTime monthDate) {
    fetchMonthAttendance(monthDate);
  }

  // ── Main API method: GET /api/student/attendance ──
  Future<void> fetchCurrentMonthAttendance() async {
    await fetchMonthAttendance(DateTime.now());
  }

  Future<void> fetchMonthAttendance([DateTime? monthDate]) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        hasError.value = true;
        calendarHasError.value = true;
        errorMessage.value = 'Please log in to view attendance.';
        calendarErrorMessage.value = 'Please log in to view attendance.';
        isLoading.value = false;
        isCalendarLoading.value = false;
        return;
      }

      final DateTime targetDate = monthDate ?? focusedMonth.value;
      focusedMonth.value = targetDate;

      final now = DateTime.now();
      final bool isCurrent = (targetDate.year == now.year && targetDate.month == now.month);

      isLoading.value = true;
      isCalendarLoading.value = true;
      hasError.value = false;
      calendarHasError.value = false;
      errorMessage.value = '';
      calendarErrorMessage.value = '';

      final String monthStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';
      final int lastDay = DateTime(targetDate.year, targetDate.month + 1, 0).day;
      final String fromStr = '$monthStr-01';
      final String toStr = '$monthStr-${lastDay.toString().padLeft(2, '0')}';

      // Primary call with month/range parameters
      http.Response res = isCurrent
          ? await _repository.getAttendance(token: token)
          : await _repository.getAttendance(month: monthStr, from: fromStr, to: toStr, token: token);

      // Fallback to range endpoint if 404 or month query not supported directly
      if (!isCurrent && (res.statusCode == 404 || res.statusCode == 400)) {
        res = await _repository.getRangeAttendance(from: fromStr, to: toStr, token: token);
      }

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;

          if (data['student'] is Map<String, dynamic>) {
            student.value = AttendanceStudent.fromJson(data['student']);
          }

          if (data['month'] is Map<String, dynamic>) {
            currentMonth.value = AttendanceMonth.fromJson(data['month']);
          } else {
            final monthName = _getMonthName(targetDate.month);
            currentMonth.value = AttendanceMonth(
              value: monthStr,
              label: '$monthName ${targetDate.year}',
              from: fromStr,
              to: toStr,
              timezone: 'Asia/Dhaka',
            );
          }

          if (data['summary'] is Map<String, dynamic>) {
            summary.value = AttendanceSummary.fromJson(data['summary']);
          } else {
            summary.value = null;
          }

          if (data['attendance'] is List) {
            final list = (data['attendance'] as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => DailyAttendanceRecord.fromJson(e))
                .toList();

            attendanceList.value = list;

            final recordMap = <String, DailyAttendanceRecord>{};
            final calMap = <String, DayAttendance>{};
            for (final rec in list) {
              recordMap[rec.date] = rec;
              calMap[rec.date] = DayAttendance.fromDailyRecord(rec);
            }
            attendanceMap.value = recordMap;
            calendarData.value = calMap;
          } else {
            attendanceList.clear();
            attendanceMap.clear();
            calendarData.clear();
          }
        }
      } else if (res.statusCode == 401) {
        hasError.value = true;
        calendarHasError.value = true;
        errorMessage.value = 'Session expired. Please log in again.';
        calendarErrorMessage.value = 'Session expired. Please log in again.';
      } else if (res.statusCode == 403) {
        hasError.value = true;
        calendarHasError.value = true;
        errorMessage.value = 'Student account is inactive.';
        calendarErrorMessage.value = 'Student account is inactive.';
      } else if (res.statusCode == 409) {
        hasError.value = true;
        calendarHasError.value = true;
        errorMessage.value = 'The student has no enrollment.';
        calendarErrorMessage.value = 'The student has no enrollment.';
      } else {
        hasError.value = true;
        calendarHasError.value = true;
        errorMessage.value = 'Failed to load attendance (${res.statusCode}).';
        calendarErrorMessage.value = 'Failed to load attendance (${res.statusCode}).';
      }
    } catch (e) {
      hasError.value = true;
      calendarHasError.value = true;
      errorMessage.value = 'Server connection error. Please check your internet connection.';
      calendarErrorMessage.value = 'Server connection error. Please check your internet connection.';
    } finally {
      isLoading.value = false;
      isCalendarLoading.value = false;
    }
  }

  Future<void> refreshAttendance() async {
    await fetchMonthAttendance(focusedMonth.value);
  }

  // Day lookups
  DailyAttendanceRecord? getRecordForDate(String dateStr) {
    return attendanceMap[dateStr];
  }

  DailyAttendanceRecord? getRecordForDay(DateTime day) {
    return attendanceMap[_formatKey(day)];
  }

  AttendanceStatus statusForDay(DateTime day) {
    final rec = getRecordForDay(day);
    if (rec != null) return rec.statusEnum;
    if (day.weekday == DateTime.friday) return AttendanceStatus.holiday;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(day.year, day.month, day.day);
    if (targetDate.isAfter(todayDate)) {
      return AttendanceStatus.none; // Future unarrived day
    }
    return calendarData[_formatKey(day)]?.status ?? AttendanceStatus.notRecorded;
  }

  String noteForDay(DateTime day) {
    final rec = getRecordForDay(day);
    if (rec != null && rec.remarks != null && rec.remarks!.isNotEmpty) {
      return rec.remarks!;
    }
    return calendarData[_formatKey(day)]?.note ?? '';
  }

  int countByStatus(dynamic daysOrStatus, [AttendanceStatus? status]) {
    if (daysOrStatus is AttendanceStatus) {
      return attendanceList.where((d) => d.statusEnum == daysOrStatus).length;
    }
    if (daysOrStatus is Iterable<DayAttendance> && status != null) {
      return daysOrStatus.where((d) => d.status == status).length;
    }
    if (status != null) {
      return attendanceList.where((d) => d.statusEnum == status).length;
    }
    return 0;
  }

  // Total calendar days in the focused month
  int get totalDaysInMonth {
    final f = focusedMonth.value;
    return DateTime(f.year, f.month + 1, 0).day;
  }

  // Total working days in the focused month (excluding Fridays)
  int get totalWorkingDaysInMonth {
    final f = focusedMonth.value;
    final daysInMonth = DateTime(f.year, f.month + 1, 0).day;
    int working = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final dt = DateTime(f.year, f.month, d);
      if (dt.weekday != DateTime.friday) {
        working++;
      }
    }
    return working > 0 ? working : daysInMonth;
  }

  // Summary counts calculated dynamically from real attendance list
  int get presentCount => attendanceList.isNotEmpty
      ? attendanceList.where((d) => d.statusEnum == AttendanceStatus.present).length
      : (summary.value?.present ?? 0);

  int get lateCount => attendanceList.isNotEmpty
      ? attendanceList.where((d) => d.statusEnum == AttendanceStatus.late).length
      : (summary.value?.late ?? 0);

  int get absentCount => attendanceList.isNotEmpty
      ? attendanceList.where((d) => d.statusEnum == AttendanceStatus.absent).length
      : (summary.value?.absent ?? 0);

  int get leaveCount => attendanceList.isNotEmpty
      ? attendanceList.where((d) => d.statusEnum == AttendanceStatus.leave).length
      : (summary.value?.leave ?? 0);

  int get offDayCount => attendanceList.isNotEmpty
      ? attendanceList.where((d) => d.statusEnum == AttendanceStatus.holiday).length
      : 0;

  int get notRecordedCount => attendanceList.isNotEmpty
      ? attendanceList.where((d) => d.statusEnum == AttendanceStatus.notRecorded).length
      : (summary.value?.notRecorded ?? 0);

  int get devicePunchDays => summary.value?.devicePunchDays ?? attendanceList.where((d) => d.totalPunches > 0).length;

  int get recordedDays => attendanceList.isNotEmpty
      ? attendanceList.where((d) => d.isRecorded).length
      : (summary.value?.recordedDays ?? (presentCount + lateCount + absentCount + leaveCount));

  // Filtered list of actual class days for Daily Punch Logs (excluding Fridays and Off Days)
  List<DailyAttendanceRecord> get classAttendanceList {
    return attendanceList.where((rec) {
      final dt = DateTime.tryParse(rec.date);
      final bool isFri = rec.isFriday || (dt != null && dt.weekday == DateTime.friday);
      final bool isPresent = (rec.status.toUpperCase() == 'P' ||
          rec.status.toUpperCase() == 'L' ||
          rec.statusEnum == AttendanceStatus.present ||
          rec.statusEnum == AttendanceStatus.late ||
          rec.totalPunches > 0);

      // Exclude Friday and Off days / Holidays
      final bool isOffDay = (isFri ||
              rec.statusEnum == AttendanceStatus.holiday ||
              rec.statusLabel.toLowerCase().contains('off day') ||
              rec.statusLabel.toLowerCase().contains('holiday')) &&
          !isPresent;
      if (isFri || isOffDay) return false;

      // Exclude unrecorded Saturday weekends with 0 punches
      if (dt != null &&
          dt.weekday == DateTime.saturday &&
          !isPresent &&
          !rec.isRecorded &&
          (rec.status.toUpperCase() == 'N' || rec.statusEnum == AttendanceStatus.notRecorded)) {
        return false;
      }

      // Exclude unrecorded future days
      if (rec.isFutureDate &&
          !rec.isRecorded &&
          rec.totalPunches == 0 &&
          (rec.status.toUpperCase() == 'N' ||
              rec.statusEnum == AttendanceStatus.none ||
              rec.statusEnum == AttendanceStatus.notRecorded)) {
        return false;
      }

      // Exclude unrecorded non-class days
      if (!rec.isRecorded &&
          rec.totalPunches == 0 &&
          rec.status.toUpperCase() == 'N' &&
          rec.statusEnum == AttendanceStatus.notRecorded) {
        return false;
      }

      return true;
    }).toList();
  }

  // Total evaluated class/working days conducted in the system so far
  int get totalEvaluatedClassDays {
    final int sum = presentCount + lateCount + absentCount;
    if (sum > 0) return sum;
    if (summary.value != null && summary.value!.recordedDays > 0) {
      return summary.value!.recordedDays;
    }
    return 0;
  }

  int get attendedDays => presentCount + lateCount;

  bool get hasAttendanceRecorded => (presentCount + lateCount + absentCount) > 0;

  // Evaluated Class Ratio Formula:
  // Attendance % = ((Present Days + Late Days) / Total Evaluated Class Days (Present + Late + Absent)) * 100
  // e.g. 3 classes evaluated, 3 present, 0 absent -> (3 / 3) * 100 = 100%
  // e.g. 4 classes evaluated, 3 present, 1 absent -> (3 / 4) * 100 = 75%
  // e.g. 22 classes evaluated, 18 present, 4 absent -> (18 / 22) * 100 = 81.8%
  // e.g. 20 classes evaluated, 20 present -> (20 / 20) * 100 = 100%
  // e.g. 20 classes evaluated, 10 present, 10 absent -> (10 / 20) * 100 = 50%
  // If no classes evaluated yet -> 0.0%
  double get attendancePercentage {
    final int totalEvaluated = totalEvaluatedClassDays;
    final int attended = attendedDays;
    if (totalEvaluated > 0 && attended > 0) {
      final double pct = (attended / totalEvaluated) * 100.0;
      return pct.clamp(0.0, 100.0);
    }
    return 0.0;
  }

  // Range report methods
  Future<void> fetchRangeAttendance({required String from, required String to}) async {
    try {
      final token = await _ensureToken();
      isRangeLoading.value = true;
      rangeHasError.value = false;
      rangeErrorMessage.value = '';
      rangeFrom.value = from;
      rangeTo.value = to;

      final res = await _repository.getRangeAttendance(from: from, to: to, token: token);
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final dynamic dataField = decoded['data'];
          final List list = dataField is List
              ? dataField
              : (dataField is Map && dataField['report'] is List
                  ? dataField['report']
                  : (dataField is Map && dataField['logs'] is List
                      ? dataField['logs']
                      : []));
          rangeData.value = list
              .whereType<Map<String, dynamic>>()
              .map((e) => DayAttendance.fromJson(e))
              .toList();
        } else {
          rangeData.value = [];
        }
      } else if (res.statusCode == 404) {
        rangeData.value = [];
      } else {
        rangeHasError.value = true;
        rangeErrorMessage.value = 'Failed to load report (${res.statusCode}).';
      }
    } catch (e) {
      rangeHasError.value = true;
      rangeErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isRangeLoading.value = false;
    }
  }

  void fetchRangeReport() {
    if (rangeFrom.value.isNotEmpty && rangeTo.value.isNotEmpty) {
      fetchRangeAttendance(from: rangeFrom.value, to: rangeTo.value);
    }
  }
}