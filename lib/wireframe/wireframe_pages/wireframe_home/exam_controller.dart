import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// TASK I — Examination
// ════════════════════════════════════════════════════════════════════════════

String _extractName(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  if (val is String) return val.trim();
  if (val is Map) {
    return val['name']?.toString() ??
        val['title']?.toString() ??
        val['class_name']?.toString() ??
        val['section_name']?.toString() ??
        val['subject_name']?.toString() ??
        val['session_name']?.toString() ??
        fallback;
  }
  return val.toString();
}

class ExamItem {
  final String examId;
  final String name;
  final String type;
  final String session;
  final String status;

  ExamItem({
    required this.examId,
    required this.name,
    required this.type,
    required this.session,
    required this.status,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      examId: json['exam_id']?.toString() ?? json['id']?.toString() ?? '',
      name: _extractName(json['exam_name'] ?? json['name'] ?? json['exam']),
      type: json['exam_type']?.toString() ?? json['type']?.toString() ?? '',
      session: _extractName(json['session'] ?? json['session_name']),
      status: json['status']?.toString() ?? '',
    );
  }
}

class RoutineItem {
  final String subject;
  final String date;
  final String day;
  final String startTime;
  final String endTime;
  final String venue;

  RoutineItem({
    required this.subject,
    required this.date,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.venue,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      subject: _extractName(json['subject'] ?? json['subject_name']),
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      venue: _extractName(json['venue'] ?? json['room']),
    );
  }
}

class SubjectMark {
  final String subject;
  final String fullMarks;
  final String obtainedMarks;
  final String highestMarks;
  final String grade;
  final String point;

  SubjectMark({
    required this.subject,
    required this.fullMarks,
    required this.obtainedMarks,
    required this.highestMarks,
    required this.grade,
    required this.point,
  });

  String get status => grade.isNotEmpty ? grade : (obtainedMarks.isNotEmpty ? 'Passed' : 'Pending');
  String get marksObtained => obtainedMarks;

  factory SubjectMark.fromJson(Map<String, dynamic> json) {
    return SubjectMark(
      subject: _extractName(json['subject'] ?? json['subject_name']),
      fullMarks: json['full_marks']?.toString() ?? json['total_marks']?.toString() ?? '',
      obtainedMarks: json['obtained_marks']?.toString() ?? json['marks_obtained']?.toString() ?? '',
      highestMarks: json['highest_marks']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      point: json['point']?.toString() ?? '',
    );
  }
}

class ExamResultData {
  final String examName;
  final List<SubjectMark> subjects;
  final String totalObtained;
  final String totalFull;
  final String gpa;
  final String overallResult;

  ExamResultData({
    required this.examName,
    required this.subjects,
    required this.totalObtained,
    required this.totalFull,
    required this.gpa,
    required this.overallResult,
  });

  factory ExamResultData.fromJson(Map<String, dynamic> json) {
    return ExamResultData(
      examName: _extractName(json['exam_name'] ?? json['name'] ?? json['exam']),
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => SubjectMark.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalObtained: json['total_obtained']?.toString() ?? '',
      totalFull: json['total_full']?.toString() ?? '',
      gpa: json['gpa']?.toString() ?? '',
      overallResult: json['result']?.toString() ?? '',
    );
  }
}

class PromotionStatus {
  final bool isPromoted;
  final String promotedToClass;
  final String promotedToSection;
  final String session;
  final String remarks;

  PromotionStatus({
    required this.isPromoted,
    required this.promotedToClass,
    required this.promotedToSection,
    required this.session,
    required this.remarks,
  });

  factory PromotionStatus.fromJson(Map<String, dynamic> json) {
    return PromotionStatus(
      isPromoted: json['is_promoted'] == true || json['is_promoted'] == 1 || json['is_promoted']?.toString() == '1',
      promotedToClass: _extractName(json['promoted_to_class'] ?? json['promoted_class']),
      promotedToSection: _extractName(json['promoted_to_section'] ?? json['promoted_section']),
      session: _extractName(json['session'] ?? json['session_name']),
      remarks: json['remarks']?.toString() ?? '',
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════

class ExamController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Future<String?> _ensureToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    _authToken = await WireframeSession.getToken();
    return _authToken;
  }

  Map<String, String> _getHeaders(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  // 1. Exam list
  var isExamListLoading = true.obs;
  var examListHasError = false.obs;
  var examListErrorMessage = ''.obs;
  var examList = <ExamItem>[].obs;
  var selectedExamId = ''.obs;

  List<ExamItem> get exams => examList;

  // 2. Exam routine
  var isRoutineLoading = false.obs;
  var routineHasError = false.obs;
  var routineErrorMessage = ''.obs;
  var routineList = <RoutineItem>[].obs;

  List<RoutineItem> get routine => routineList;

  // 3. Admit card
  var isDownloadingAdmit = false.obs;
  var admitCardPath = ''.obs;
  var admitErrorMessage = ''.obs;

  // 4. Exam results
  var isResultLoading = false.obs;
  var resultHasError = false.obs;
  var resultErrorMessage = ''.obs;
  var examResult = Rxn<ExamResultData>();

  // 5. Promotion status
  var isPromotionLoading = false.obs;
  var promotionHasError = false.obs;
  var promotionErrorMessage = ''.obs;
  var promotionStatus = Rxn<PromotionStatus>();

  Rxn<PromotionStatus> get promotion => promotionStatus;

  @override
  void onInit() {
    super.onInit();
    fetchExamList();
  }

  Future<void> fetchExamList() async {
    try {
      final token = await _ensureToken();
      isExamListLoading(true);
      examListHasError(false);
      examListErrorMessage.value = '';

      final uri = Uri.parse('$_baseUrl/student/exams');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List list = decoded['data'];
          examList.value = list.map((e) => ExamItem.fromJson(e)).toList();

          if (examList.isNotEmpty && selectedExamId.value.isEmpty) {
            selectExam(examList.first.examId);
          }
        } else {
          examListHasError(true);
          examListErrorMessage.value = decoded['message']?.toString() ?? 'Failed to load exams.';
        }
      } else {
        examListHasError(true);
        examListErrorMessage.value = 'Failed to load exams (${res.statusCode}).';
      }
    } catch (e) {
      examListHasError(true);
      examListErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isExamListLoading(false);
    }
  }

  void selectExam(String examId) {
    selectedExamId.value = examId;
    fetchRoutine(examId);
    fetchResult(examId);
  }

  Future<void> fetchRoutine(String examId, [String? examName]) async {
    try {
      final token = await _ensureToken();
      isRoutineLoading(true);
      routineHasError(false);
      routineErrorMessage.value = '';

      final uri = Uri.parse('$_baseUrl/student/exam/routine?exam_id=$examId');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final List list = decoded['data'];
          routineList.value = list.map((e) => RoutineItem.fromJson(e)).toList();
        } else {
          routineHasError(true);
          routineErrorMessage.value = decoded['message']?.toString() ?? 'No routine found for this exam.';
        }
      } else {
        routineHasError(true);
        routineErrorMessage.value = 'Failed to load routine (${res.statusCode}).';
      }
    } catch (e) {
      routineHasError(true);
      routineErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isRoutineLoading(false);
    }
  }

  Future<String?> downloadAdmitCard(String examId) async {
    try {
      final token = await _ensureToken();
      isDownloadingAdmit(true);
      admitErrorMessage.value = '';

      final uri = Uri.parse('$_baseUrl/student/exam/admit-card?exam_id=$examId');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/admit_card_$examId.pdf');
        await file.writeAsBytes(res.bodyBytes);
        admitCardPath.value = file.path;
        return file.path;
      } else {
        admitErrorMessage.value = 'Failed to download admit card (${res.statusCode}).';
        return null;
      }
    } catch (e) {
      admitErrorMessage.value = 'Download failed. Please check your connection.';
      return null;
    } finally {
      isDownloadingAdmit(false);
    }
  }

  Future<void> fetchResult(String examId) async {
    try {
      final token = await _ensureToken();
      isResultLoading(true);
      resultHasError(false);
      resultErrorMessage.value = '';

      final uri = Uri.parse('$_baseUrl/student/exam/result?exam_id=$examId');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          examResult.value = ExamResultData.fromJson(decoded['data']);
        } else {
          resultHasError(true);
          resultErrorMessage.value = decoded['message']?.toString() ?? 'Result not published yet.';
        }
      } else {
        resultHasError(true);
        resultErrorMessage.value = 'Failed to load result (${res.statusCode}).';
      }
    } catch (e) {
      resultHasError(true);
      resultErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isResultLoading(false);
    }
  }

  Future<void> fetchPromotion() async => fetchPromotionStatus();

  Future<void> fetchPromotionStatus() async {
    try {
      final token = await _ensureToken();
      isPromotionLoading(true);
      promotionHasError(false);
      promotionErrorMessage.value = '';

      final uri = Uri.parse('$_baseUrl/student/promotion-status');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          promotionStatus.value = PromotionStatus.fromJson(decoded['data']);
        } else {
          promotionHasError(true);
          promotionErrorMessage.value = decoded['message']?.toString() ?? 'Promotion status unavailable.';
        }
      } else {
        promotionHasError(true);
        promotionErrorMessage.value = 'Failed to load promotion status (${res.statusCode}).';
      }
    } catch (e) {
      promotionHasError(true);
      promotionErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isPromotionLoading(false);
    }
  }
}
