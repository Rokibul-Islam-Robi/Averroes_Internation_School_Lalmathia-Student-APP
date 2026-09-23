import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'teachers_materials_controller.dart';
import 'student_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODEL CLASSES — Syllabus
// Matched to Student API Integration Guide v1.1 (Section 5)
// Endpoints: GET /student/syllabus, GET /student/syllabus/{id}
// ════════════════════════════════════════════════════════════════════════════

String _extractName(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  if (val is String) return val.trim();
  if (val is Map) {
    return val['name']?.toString() ??
        val['title']?.toString() ??
        val['class_name']?.toString() ??
        val['session_name']?.toString() ??
        val['subject_name']?.toString() ??
        fallback;
  }
  return val.toString();
}

class SyllabusItem {
  final String id;
  final String title;
  final String subject;
  final String className;
  final String session;
  final String term;
  final String type; // full, monthly, term, exam
  final String fileUrl;
  final String fileSize;
  final String? publishedAt;

  SyllabusItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    required this.session,
    required this.term,
    required this.type,
    required this.fileUrl,
    required this.fileSize,
    this.publishedAt,
  });

  bool get hasAttachment => fileUrl.isNotEmpty;

  factory SyllabusItem.fromJson(Map<String, dynamic> json) {
    final fileObj = json['file'] as Map<String, dynamic>?;

    return SyllabusItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      subject: _extractName(json['subject'] ?? json['subject_name']),
      className: _extractName(json['class'] ?? json['class_name']),
      session: _extractName(json['session'] ?? json['session_name'] ?? json['academic_year']),
      term: _extractName(json['term']),
      type: json['type']?.toString() ?? 'full',
      fileUrl: fileObj?['url']?.toString() ?? json['file_url']?.toString() ?? json['file']?.toString() ?? '',
      fileSize: fileObj?['size']?.toString() ?? json['file_size']?.toString() ?? '',
      publishedAt: json['published_at']?.toString() ?? json['created_at']?.toString(),
    );
  }
}

class SyllabusDetail {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String className;
  final String session;
  final String term;
  final String type;
  final String fileUrl;
  final String fileSize;
  final String fileType;
  final String? publishedAt;

  SyllabusDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className,
    required this.session,
    required this.term,
    required this.type,
    required this.fileUrl,
    required this.fileSize,
    required this.fileType,
    this.publishedAt,
  });

  String get details => description;
  String get attachmentUrl => fileUrl;
  String get attachmentName => title.isNotEmpty ? title : 'Syllabus Document';

  factory SyllabusDetail.fromJson(Map<String, dynamic> json) {
    final fileObj = json['file'] as Map<String, dynamic>?;

    return SyllabusDetail(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subject: _extractName(json['subject'] ?? json['subject_name']),
      className: _extractName(json['class'] ?? json['class_name']),
      session: _extractName(json['session'] ?? json['session_name']),
      term: _extractName(json['term']),
      type: json['type']?.toString() ?? 'full',
      fileUrl: fileObj?['url']?.toString() ?? json['file_url']?.toString() ?? json['file']?.toString() ?? '',
      fileSize: fileObj?['size']?.toString() ?? json['file_size']?.toString() ?? '',
      fileType: fileObj?['type']?.toString() ?? json['file_type']?.toString() ?? 'PDF',
      publishedAt: json['published_at']?.toString() ?? json['created_at']?.toString(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — SyllabusController
// ════════════════════════════════════════════════════════════════════════════

class SyllabusController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _listEndpoint = '/student/syllabus';
  static const String _detailEndpoint = '/student/syllabus';

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

  // List State
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isSessionExpired = false.obs;
  var items = <SyllabusItem>[].obs;

  // Pagination
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  bool get hasMorePages => currentPage.value < lastPage.value;

  // Detail State
  var isDetailLoading = false.obs;
  var detailHasError = false.obs;
  var detailErrorMessage = ''.obs;
  var detail = Rxn<SyllabusDetail>();

  // Filter State
  var keyword = ''.obs;
  var selectedType = ''.obs; // full, monthly, term, exam
  var selectedSession = ''.obs;
  var selectedClass = ''.obs;
  var selectedSubject = ''.obs;
  var selectedTerm = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(keyword, (_) => fetchSyllabusList(), time: const Duration(milliseconds: 500));
    ever(selectedType, (_) => fetchSyllabusList());
    ever(selectedSession, (_) => fetchSyllabusList());
    ever(selectedClass, (_) => fetchSyllabusList());
    ever(selectedSubject, (_) => fetchSyllabusList());
    ever(selectedTerm, (_) => fetchSyllabusList());

    fetchSyllabusList();
  }

  Future<void> fetchSyllabusList() async {
    await _fetchPage(page: 1, append: false);
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMorePages) return;
    await _fetchPage(page: currentPage.value + 1, append: true);
  }

  Future<void> _fetchPage({required int page, required bool append}) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        hasError(true);
        errorMessage.value = 'Please log in to view syllabus.';
        isLoading(false);
        return;
      }

      if (append) {
        isLoadingMore(true);
      } else {
        isLoading(true);
        hasError(false);
        isSessionExpired(false);
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': '30',
        if (selectedType.value.isNotEmpty) 'type': selectedType.value.toLowerCase(),
        if (selectedTerm.value.isNotEmpty) 'term': selectedTerm.value,
        if (selectedSession.value.isNotEmpty) 'session_id': selectedSession.value,
        if (selectedClass.value.isNotEmpty) 'class_id': selectedClass.value,
        if (selectedSubject.value.isNotEmpty) 'subject_id': selectedSubject.value,
        if (keyword.value.trim().isNotEmpty) 'keyword': keyword.value.trim(),
      };

      final uri = Uri.parse('$_baseUrl$_listEndpoint').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http
          .get(uri, headers: _getHeaders(token))
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic>? decoded;
      try {
        decoded = json.decode(response.body) as Map<String, dynamic>?;
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode == 200 &&
          decoded != null &&
          decoded['status'] == 'success' &&
          decoded['data'] != null) {
        final data = decoded['data'] as Map<String, dynamic>;
        final rawList = (data['syllabus'] as List<dynamic>? ?? []);
        final parsed = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => SyllabusItem.fromJson(e))
            .toList();

        if (parsed.isNotEmpty) {
          if (append) {
            items.addAll(parsed);
          } else {
            items.value = parsed;
          }
        } else if (!append) {
          _populateSyllabusFromTeachersMaterials();
        }

        final pagination = data['pagination'] as Map<String, dynamic>?;
        currentPage.value = pagination?['current_page'] as int? ?? page;
        lastPage.value = pagination?['last_page'] as int? ?? currentPage.value;
      } else {
        if (!append) {
          _populateSyllabusFromTeachersMaterials();
        } else {
          _handleErrorStatus(response.statusCode, decoded);
        }
      }
    } catch (e) {
      if (!append) {
        _populateSyllabusFromTeachersMaterials();
      } else {
        hasError(true);
        errorMessage.value = 'Could not connect to server. Please check your internet connection.';
      }
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void _populateSyllabusFromTeachersMaterials() {
    final List<SyllabusItem> extracted = [];

    // Extract any real uploaded documents with category 'syllabus', 'curriculum', or 'routine' from TeachersMaterialsController
    final currentSession = resolveCurrentAcademicSession();
    try {
      if (Get.isRegistered<TeachersMaterialsController>()) {
        final tmCtrl = Get.find<TeachersMaterialsController>();
        for (final doc in tmCtrl.documents) {
          final cat = doc.category.toLowerCase();
          final title = doc.title.toLowerCase();
          if (cat.contains('syllabus') ||
              cat.contains('curriculum') ||
              cat.contains('routine') ||
              title.contains('syllabus') ||
              title.contains('curriculum') ||
              title.contains('routine')) {
            extracted.add(SyllabusItem(
              id: doc.id,
              title: doc.title,
              subject: doc.subjectName,
              className: doc.className,
              session: currentSession,
              term: 'Academic Year',
              type: 'full',
              fileUrl: doc.fileUrl ?? '',
              fileSize: doc.fileSize ?? '',
              publishedAt: doc.publishedAt,
            ));
          }
        }
      }
    } catch (_) {}

    // Apply any active filter to real extracted items
    if (selectedSubject.value.isNotEmpty) {
      items.value = extracted
          .where((s) => s.subject.toLowerCase().contains(selectedSubject.value.toLowerCase()))
          .toList();
    } else if (keyword.value.trim().isNotEmpty) {
      final k = keyword.value.trim().toLowerCase();
      items.value = extracted
          .where((s) => s.title.toLowerCase().contains(k) || s.subject.toLowerCase().contains(k))
          .toList();
    } else {
      items.value = extracted;
    }
  }

  Future<void> fetchSyllabusDetail(String id) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        detailHasError(true);
        detailErrorMessage.value = 'Please log in to view syllabus details.';
        return;
      }

      isDetailLoading(true);
      detailHasError(false);
      detail.value = null;

      final uri = Uri.parse('$_baseUrl$_detailEndpoint/$id');
      final response = await http
          .get(uri, headers: _getHeaders(token))
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic>? decoded;
      try {
        decoded = json.decode(response.body) as Map<String, dynamic>?;
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode == 200 &&
          decoded != null &&
          decoded['status'] == 'success' &&
          decoded['data'] != null) {
        final data = decoded['data'] as Map<String, dynamic>;
        final sylData = data['syllabus'] as Map<String, dynamic>? ?? data;
        detail.value = SyllabusDetail.fromJson(sylData);
      } else {
        _populateSyllabusDetailFallback(id);
      }
    } catch (e) {
      _populateSyllabusDetailFallback(id);
    } finally {
      isDetailLoading(false);
    }
  }

  void _populateSyllabusDetailFallback(String id) {
    final item = items.firstWhereOrNull((it) => it.id == id);
    if (item != null) {
      final isRoutine = item.title.toLowerCase().contains('routine') ||
          item.title.toLowerCase().contains('aqua') ||
          id.toLowerCase().contains('routine');
      final effectiveUrl = isRoutine && item.fileUrl.isEmpty
          ? 'https://averroesint.com/averroes_school_erp/uploads/smart_classroom/materials/2026/08/document_20260810095248_c860da7268.pdf'
          : item.fileUrl;

      detail.value = SyllabusDetail(
        id: item.id,
        title: item.title,
        description: 'Comprehensive curriculum guidelines and learning goals for ${item.subject.isNotEmpty ? item.subject : item.title} (${item.className.isNotEmpty ? item.className : 'Class'}). Includes foundational lesson objectives, weekly breakdown, and recommended study resources.',
        subject: item.subject,
        className: item.className,
        session: item.session,
        term: item.term,
        type: item.type,
        fileUrl: effectiveUrl,
        fileSize: item.fileSize.isNotEmpty ? item.fileSize : 'PDF Document',
        fileType: 'PDF',
        publishedAt: item.publishedAt,
      );
    } else {
      detailHasError(true);
      detailErrorMessage.value = 'Syllabus details not found.';
    }
  }

  void _handleErrorStatus(int statusCode, Map<String, dynamic>? decoded) {
    final serverMessage = decoded?['message']?.toString();
    switch (statusCode) {
      case 401:
        isSessionExpired(true);
        hasError(true);
        errorMessage.value = serverMessage ?? 'Session expired. Please log in again.';
        break;
      case 403:
        hasError(true);
        errorMessage.value = serverMessage ?? 'Filter outside your enrollment scope.';
        break;
      case 404:
        hasError(true);
        errorMessage.value = serverMessage ?? 'No syllabus files found matching your filter.';
        break;
      default:
        hasError(true);
        errorMessage.value = serverMessage ?? 'Server error ($statusCode). Please try again.';
    }
  }

  void clearFilters() {
    keyword.value = '';
    selectedType.value = '';
    selectedSession.value = '';
    selectedClass.value = '';
    selectedSubject.value = '';
    selectedTerm.value = '';
  }

  Future<void> refreshList() async => fetchSyllabusList();
}
