import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS — Published Results API Integration
// Matched to STUDENT_COMPLAINT_AND_RESULT_API.md
// Base URL: https://averroesint.com/averroes_school_erp/api
// Endpoints:
//  - GET /student/results?page=1&per_page=30
//  - GET /student/results/{examId}
// ════════════════════════════════════════════════════════════════════════════

class ExamInfo {
  final int id;
  final String name;
  final String year;
  final String startDate;
  final String endDate;
  final bool isPublished;

  ExamInfo({
    required this.id,
    required this.name,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.isPublished,
  });

  factory ExamInfo.fromJson(Map<String, dynamic> json) {
    return ExamInfo(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Exam',
      year: json['year']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      isPublished: json['is_published'] == true || json['is_published'] == 1 || json['is_published'] == '1',
    );
  }
}

class AcademicContext {
  final int? sessionId;
  final String sessionName;
  final int? classId;
  final String className;
  final int? sectionId;
  final String sectionName;
  final String rollNo;

  AcademicContext({
    this.sessionId,
    required this.sessionName,
    this.classId,
    required this.className,
    this.sectionId,
    required this.sectionName,
    required this.rollNo,
  });

  factory AcademicContext.fromJson(Map<String, dynamic> json) {
    String sName = '';
    int? sId;
    if (json['session'] is Map) {
      sName = json['session']['name']?.toString() ?? '';
      sId = int.tryParse(json['session']['id']?.toString() ?? '');
    } else if (json['session'] != null) {
      sName = json['session'].toString();
    }

    String cName = '';
    int? cId;
    if (json['class'] is Map) {
      cName = json['class']['name']?.toString() ?? '';
      cId = int.tryParse(json['class']['id']?.toString() ?? '');
    } else if (json['class_name'] != null) {
      cName = json['class_name'].toString();
    } else if (json['class'] != null) {
      cName = json['class'].toString();
    }

    String secName = '';
    int? secId;
    if (json['section'] is Map) {
      secName = json['section']['name']?.toString() ?? '';
      secId = int.tryParse(json['section']['id']?.toString() ?? '');
    } else if (json['section_name'] != null) {
      secName = json['section_name'].toString();
    } else if (json['section'] != null) {
      secName = json['section'].toString();
    }

    return AcademicContext(
      sessionId: sId,
      sessionName: sName,
      classId: cId,
      className: cName,
      sectionId: secId,
      sectionName: secName,
      rollNo: json['roll_no']?.toString() ?? '',
    );
  }
}

class ResultSummary {
  final int subjectsCount;
  final int subjectsWithMarks;
  final double fullMarks;
  final double obtainedMarks;
  final double percentage;
  final String overallGrade;
  final double gradePoint;
  final String remarks;
  final int? positionInSection;
  final int absentSubjects;
  final int failedSubjects;
  final bool hasFailedSubject;
  final String source; // "published_summary" or "calculated"

  ResultSummary({
    required this.subjectsCount,
    required this.subjectsWithMarks,
    required this.fullMarks,
    required this.obtainedMarks,
    required this.percentage,
    required this.overallGrade,
    required this.gradePoint,
    required this.remarks,
    this.positionInSection,
    required this.absentSubjects,
    required this.failedSubjects,
    required this.hasFailedSubject,
    required this.source,
  });

  factory ResultSummary.fromJson(Map<String, dynamic> json) {
    return ResultSummary(
      subjectsCount: int.tryParse(json['subjects_count']?.toString() ?? '0') ?? 0,
      subjectsWithMarks: int.tryParse(json['subjects_with_marks']?.toString() ?? '0') ?? 0,
      fullMarks: double.tryParse(json['full_marks']?.toString() ?? '0') ?? 0.0,
      obtainedMarks: double.tryParse(json['obtained_marks']?.toString() ?? '0') ?? 0.0,
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
      overallGrade: json['overall_grade']?.toString() ?? json['grade']?.toString() ?? '—',
      gradePoint: double.tryParse(json['grade_point']?.toString() ?? json['gpa']?.toString() ?? '0') ?? 0.0,
      remarks: json['remarks']?.toString() ?? '',
      positionInSection: int.tryParse(json['position_in_section']?.toString() ?? json['position']?.toString() ?? ''),
      absentSubjects: int.tryParse(json['absent_subjects']?.toString() ?? '0') ?? 0,
      failedSubjects: int.tryParse(json['failed_subjects']?.toString() ?? '0') ?? 0,
      hasFailedSubject: json['has_failed_subject'] == true || json['has_failed_subject'] == 1,
      source: json['source']?.toString() ?? 'calculated',
    );
  }
}

class ResultAttendance {
  final int presentDays;
  final int workingDays;
  final double percentage;

  ResultAttendance({
    required this.presentDays,
    required this.workingDays,
    required this.percentage,
  });

  factory ResultAttendance.fromJson(Map<String, dynamic> json) {
    return ResultAttendance(
      presentDays: int.tryParse(json['present_days']?.toString() ?? json['present']?.toString() ?? '0') ?? 0,
      workingDays: int.tryParse(json['working_days']?.toString() ?? json['total_days']?.toString() ?? '0') ?? 0,
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
    );
  }

  int get absentDays => (workingDays - presentDays) > 0 ? (workingDays - presentDays) : 0;
  int get leaveDays => 0;
}

class SubjectMarkDetail {
  final int id;
  final String code;
  final String name;
  final double fullMarks;
  final double passMarks;
  final bool marksEntered;
  final bool isAbsent;
  final double? homework;
  final double? classTest;
  final double? exam;
  final double? total;
  final double? highestInSection;
  final String? grade;
  final bool? passed;

  SubjectMarkDetail({
    required this.id,
    required this.code,
    required this.name,
    required this.fullMarks,
    required this.passMarks,
    required this.marksEntered,
    required this.isAbsent,
    this.homework,
    this.classTest,
    this.exam,
    this.total,
    this.highestInSection,
    this.grade,
    this.passed,
  });

  factory SubjectMarkDetail.fromJson(Map<String, dynamic> json) {
    return SubjectMarkDetail(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['subject_name']?.toString() ?? 'Subject',
      fullMarks: double.tryParse(json['full_marks']?.toString() ?? '100') ?? 100.0,
      passMarks: double.tryParse(json['pass_marks']?.toString() ?? '40') ?? 40.0,
      marksEntered: json['marks_entered'] != false,
      isAbsent: json['is_absent'] == true || json['is_absent'] == 1,
      homework: json['homework'] != null ? double.tryParse(json['homework'].toString()) : null,
      classTest: json['class_test'] != null ? double.tryParse(json['class_test'].toString()) : null,
      exam: json['exam'] != null ? double.tryParse(json['exam'].toString()) : null,
      total: json['total'] != null ? double.tryParse(json['total'].toString()) : (json['obtained_marks'] != null ? double.tryParse(json['obtained_marks'].toString()) : null),
      highestInSection: json['highest_in_section'] != null ? double.tryParse(json['highest_in_section'].toString()) : null,
      grade: json['grade']?.toString(),
      passed: json['passed'] == true || json['passed'] == 1,
    );
  }
}

class PublishedResultItem {
  final ExamInfo exam;
  final AcademicContext? academicContext;
  final ResultSummary? summary;
  final ResultAttendance? attendance;
  final List<SubjectMarkDetail> subjects;

  PublishedResultItem({
    required this.exam,
    this.academicContext,
    this.summary,
    this.attendance,
    this.subjects = const [],
  });

  factory PublishedResultItem.fromJson(Map<String, dynamic> json) {
    ExamInfo examInfo;
    if (json['exam'] is Map<String, dynamic>) {
      examInfo = ExamInfo.fromJson(json['exam']);
    } else {
      examInfo = ExamInfo(
        id: int.tryParse(json['id']?.toString() ?? json['exam_id']?.toString() ?? '0') ?? 0,
        name: json['exam_name']?.toString() ?? json['name']?.toString() ?? 'Exam',
        year: json['year']?.toString() ?? '',
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString() ?? '',
        isPublished: true,
      );
    }

    AcademicContext? ac;
    if (json['academic_context'] is Map<String, dynamic>) {
      ac = AcademicContext.fromJson(json['academic_context']);
    }

    ResultSummary? sum;
    if (json['summary'] is Map<String, dynamic>) {
      sum = ResultSummary.fromJson(json['summary']);
    }

    ResultAttendance? att;
    if (json['attendance'] is Map<String, dynamic>) {
      att = ResultAttendance.fromJson(json['attendance']);
    }

    List<SubjectMarkDetail> subjs = [];
    if (json['subjects'] is List) {
      subjs = (json['subjects'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => SubjectMarkDetail.fromJson(e))
          .toList();
    }

    return PublishedResultItem(
      exam: examInfo,
      academicContext: ac,
      summary: sum,
      attendance: att,
      subjects: subjs,
    );
  }

  // Backward compatibility getters
  String get examId => exam.id.toString();
  String get examName => exam.name;
  String get session => academicContext?.sessionName ?? '';
  String get resultStatus => exam.isPublished ? 'Published' : 'Pending';
  String get gpa => summary?.gradePoint.toStringAsFixed(2) ?? '—';
  String get result => summary != null ? (summary!.hasFailedSubject ? 'Failed' : 'Passed') : '—';
}

// ════════════════════════════════════════════════════════════════════════════
// REPOSITORY
// ════════════════════════════════════════════════════════════════════════════

class ReportCardRepository {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';

  final http.Client _client;
  ReportCardRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  // 1. GET /student/results
  Future<http.Response> getPublishedResults({int? sessionId, int page = 1, int perPage = 30, String? token}) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (sessionId != null) 'session_id': sessionId.toString(),
    };
    final uri = Uri.parse('$_baseUrl/student/results').replace(queryParameters: queryParams);
    return await _client.get(uri, headers: _buildHeaders(token)).timeout(const Duration(seconds: 15));
  }

  // 2. GET /student/results/{examId}
  Future<http.Response> getResultDetail({required int examId, String? token}) async {
    final uri = Uri.parse('$_baseUrl/student/results/$examId');
    return await _client.get(uri, headers: _buildHeaders(token)).timeout(const Duration(seconds: 15));
  }

  Future<File?> downloadPdf({
    required String pdfUrl,
    required String saveName,
    String? token,
  }) async {
    try {
      final uri = Uri.parse(pdfUrl);
      final res = await _client.get(uri, headers: _buildHeaders(token)).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, saveName));
        await file.writeAsBytes(res.bodyBytes);
        return file;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER: ReportCardController / ResultController
// ════════════════════════════════════════════════════════════════════════════

class ReportCardController extends GetxController {
  final ReportCardRepository _repository = ReportCardRepository();
  String? _authToken;

  void setAuthToken(String token) => _authToken = token;

  Future<String?> _ensureToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    _authToken = await WireframeSession.getToken();
    return _authToken;
  }

  // Published results list
  final publishedResults = <PublishedResultItem>[].obs;
  final isExamListLoading = true.obs;
  final examListHasError = false.obs;
  final examListErrorMessage = ''.obs;
  final selectedExamId = 0.obs;

  // Selected result detail with subjects breakdown
  final selectedResultDetail = Rxn<PublishedResultItem>();
  final isDetailLoading = false.obs;
  final detailHasError = false.obs;
  final detailErrorMessage = ''.obs;

  final isDownloadingPdf = false.obs;
  final downloadedPdfPath = ''.obs;

  // Attendance summary compatibility
  final isAttendanceLoading = false.obs;
  final attendanceHasError = false.obs;
  final attendanceErrorMessage = ''.obs;
  final attendance = Rxn<ResultAttendance>();

  Future<void> fetchAttendanceSummary() async {
    // Legacy stub — attendance is delivered with results
  }

  // Backward compatibility aliases
  List<PublishedResultItem> get exams => publishedResults;
  RxBool get isReportLoading => isDetailLoading;
  RxBool get reportHasError => detailHasError;
  RxString get reportErrorMessage => detailErrorMessage;

  @override
  void onInit() {
    super.onInit();
    fetchPublishedResults();
  }

  // ── 1. Fetch Published Results: GET /student/results ──
  Future<void> fetchPublishedResults({int? sessionId}) async {
    try {
      isExamListLoading(true);
      examListHasError(false);
      examListErrorMessage.value = '';

      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        examListHasError(true);
        examListErrorMessage.value = 'Please log in to view exam results.';
        return;
      }

      final res = await _repository.getPublishedResults(sessionId: sessionId, token: token);
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'];
          List<dynamic>? list;
          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic> && data['results'] is List) {
            list = data['results'] as List;
          }

          if (list != null) {
            publishedResults.value = list
                .whereType<Map<String, dynamic>>()
                .map((e) => PublishedResultItem.fromJson(e))
                .toList();

            if (publishedResults.isNotEmpty) {
              final firstExamId = publishedResults.first.exam.id;
              selectExam(firstExamId);
            }
          }
        } else {
          examListHasError(true);
          examListErrorMessage.value = decoded?['message']?.toString() ?? 'No published results found.';
        }
      } else if (res.statusCode == 401) {
        examListHasError(true);
        examListErrorMessage.value = 'Session expired. Please log in again.';
      } else {
        examListHasError(true);
        examListErrorMessage.value = 'Failed to load exam results (${res.statusCode}).';
      }
    } catch (e) {
      examListHasError(true);
      examListErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isExamListLoading(false);
    }
  }

  // ── 2. Select Exam & Fetch Details: GET /student/results/{examId} ──
  void selectExam(int examId) {
    selectedExamId.value = examId;
    downloadedPdfPath.value = '';

    // First check if already in publishedResults
    final match = publishedResults.firstWhereOrNull((item) => item.exam.id == examId);
    if (match != null && match.subjects.isNotEmpty) {
      selectedResultDetail.value = match;
    } else {
      if (match != null) {
        selectedResultDetail.value = match;
      }
      fetchResultDetail(examId);
    }
  }

  // Fetch detailed subject breakdown
  Future<void> fetchResultDetail(int examId) async {
    try {
      isDetailLoading(true);
      detailHasError(false);
      detailErrorMessage.value = '';

      final token = await _ensureToken();
      if (token == null || token.isEmpty) return;

      final res = await _repository.getResultDetail(examId: examId, token: token);
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;
          final detailed = PublishedResultItem.fromJson(data);
          selectedResultDetail.value = detailed;

          // Update in main list as well
          final idx = publishedResults.indexWhere((item) => item.exam.id == examId);
          if (idx >= 0) {
            publishedResults[idx] = detailed;
          }
        }
      }
    } catch (_) {
    } finally {
      isDetailLoading(false);
    }
  }

  // Backward compatibility alias for UI
  Future<void> fetchExamList() async => await fetchPublishedResults();
  Future<void> fetchReportCard(String examId) async {
    final int id = int.tryParse(examId) ?? 0;
    if (id > 0) selectExam(id);
  }
}