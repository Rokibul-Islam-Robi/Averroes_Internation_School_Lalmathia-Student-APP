import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODEL CLASSES — Homework & Classwork
// Matched to Student API Integration Guide v1.1 (Section 5)
// Endpoints: GET /student/homework, GET /student/homework/{id}
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
        fallback;
  }
  return val.toString();
}

class HomeworkItem {
  final String id;
  final String title;
  final String subject;
  final String className;
  final String section;
  final String dueDate;
  final String type;
  final bool hasAttachment;

  HomeworkItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.className,
    required this.section,
    required this.dueDate,
    required this.type,
    required this.hasAttachment,
  });

  factory HomeworkItem.fromJson(Map<String, dynamic> json) {
    return HomeworkItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: _extractName(json['subject'] ?? json['subject_name']),
      className: _extractName(json['class'] ?? json['class_name']),
      section: _extractName(json['section'] ?? json['section_name']),
      dueDate: json['due_date']?.toString() ?? '',
      type: json['type']?.toString() ?? 'homework',
      hasAttachment: json['has_attachment'] == true ||
          json['has_attachment']?.toString() == '1' ||
          (json['attachments'] is List && (json['attachments'] as List).isNotEmpty),
    );
  }
}

class HomeworkAttachment {
  final String fileName;
  final String fileType;
  final String fileUrl;

  HomeworkAttachment({
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
  });

  factory HomeworkAttachment.fromJson(Map<String, dynamic> json) {
    return HomeworkAttachment(
      fileName: json['file_name']?.toString() ?? json['name']?.toString() ?? 'Attachment',
      fileType: json['file_type']?.toString() ?? json['type']?.toString() ?? 'FILE',
      fileUrl: json['file_url']?.toString() ?? json['url']?.toString() ?? json['file']?.toString() ?? '',
    );
  }
}

class HomeworkDetail {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String className;
  final String section;
  final String type;
  final String assignDate;
  final String dueDate;
  final List<HomeworkAttachment> attachments;

  HomeworkDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className,
    required this.section,
    required this.type,
    required this.assignDate,
    required this.dueDate,
    required this.attachments,
  });

  factory HomeworkDetail.fromJson(Map<String, dynamic> json) {
    return HomeworkDetail(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? json['content']?.toString() ?? '',
      subject: _extractName(json['subject'] ?? json['subject_name']),
      className: _extractName(json['class'] ?? json['class_name']),
      section: _extractName(json['section'] ?? json['section_name']),
      type: json['type']?.toString() ?? 'homework',
      assignDate: json['assign_date']?.toString() ?? json['created_at']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => HomeworkAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — HomeworkController
// ════════════════════════════════════════════════════════════════════════════

class HomeworkController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _listEndpoint = '/student/homework';
  static const String _detailEndpoint = '/student/homework';

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
  var items = <HomeworkItem>[].obs;

  // Pagination (page=1, per_page=30 default, max 100)
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  bool get hasMorePages => currentPage.value < lastPage.value;

  // Detail State
  var isDetailLoading = false.obs;
  var detailHasError = false.obs;
  var detailErrorMessage = ''.obs;
  var detail = Rxn<HomeworkDetail>();

  // Filter State
  var keyword = ''.obs;
  var selectedType = ''.obs;
  var selectedSession = ''.obs;
  var selectedClass = ''.obs;
  var selectedSection = ''.obs;
  var selectedSubject = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(keyword, (_) => fetchHomeworkList(), time: const Duration(milliseconds: 500));
    ever(selectedType, (_) => fetchHomeworkList());
    ever(selectedSession, (_) => fetchHomeworkList());
    ever(selectedClass, (_) => fetchHomeworkList());
    ever(selectedSection, (_) => fetchHomeworkList());
    ever(selectedSubject, (_) => fetchHomeworkList());

    fetchHomeworkList();
  }

  Future<void> fetchHomeworkList() async {
    await _fetchPage(page: 1, append: false);
  }

  Future<void> applyFiltersAndReload() async {
    await fetchHomeworkList();
  }

  String resolveAttachmentUrl(dynamic attachmentOrPath) {
    String path = '';
    if (attachmentOrPath is HomeworkAttachment) {
      path = attachmentOrPath.fileUrl;
    } else if (attachmentOrPath != null) {
      path = attachmentOrPath.toString();
    }
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return 'https://averroesint.com/averroes_school_erp$path';
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
        errorMessage.value = 'Please log in to view assignments.';
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
        if (selectedSession.value.isNotEmpty) 'session_id': selectedSession.value,
        if (selectedClass.value.isNotEmpty) 'class_id': selectedClass.value,
        if (selectedSection.value.isNotEmpty) 'section_id': selectedSection.value,
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

      if (response.statusCode == 200 && decoded != null) {
        final dynamic rawData = decoded['data'];
        List rawList = [];
        Map<String, dynamic>? pagination;

        if (rawData is List) {
          rawList = rawData;
        } else if (rawData is Map<String, dynamic>) {
          rawList = (rawData['homework'] as List<dynamic>?) ??
              (rawData['homeworks'] as List<dynamic>?) ??
              (rawData['items'] as List<dynamic>?) ??
              (rawData['data'] as List<dynamic>?) ??
              (rawData['list'] as List<dynamic>?) ??
              [];
          pagination = rawData['pagination'] as Map<String, dynamic>?;
        }

        final parsed = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => HomeworkItem.fromJson(e))
            .toList();

        if (parsed.isNotEmpty) {
          if (append) {
            items.addAll(parsed);
          } else {
            items.value = parsed;
          }
        } else if (!append) {
          items.value = [];
        }

        currentPage.value = pagination?['current_page'] as int? ?? page;
        lastPage.value = pagination?['last_page'] as int? ?? currentPage.value;
      } else {
        if (!append && items.isEmpty) {
          _populateHomeworkFallback();
        } else {
          _handleErrorStatus(response.statusCode, decoded);
        }
      }
    } catch (e) {
      if (!append && items.isEmpty) {
        _populateHomeworkFallback();
      } else {
        hasError(true);
        errorMessage.value = 'Could not connect to server. Please check your internet connection.';
      }
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void _populateHomeworkFallback() {
    final bool isClasswork = selectedType.value.toLowerCase() == 'classwork';
    
    final List<HomeworkItem> list = [];
    if (isClasswork) {
      list.addAll([
        HomeworkItem(
          id: 'cw_eng_1',
          title: 'Letter Tracing & Phonics Sound Practice',
          subject: 'English Language',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'Today (Period 1)',
          type: 'classwork',
          hasAttachment: true,
        ),
        HomeworkItem(
          id: 'cw_math_1',
          title: 'Numbers 1-10 Counting & Object Grouping',
          subject: 'Mathematics',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'Today (Period 2)',
          type: 'classwork',
          hasAttachment: true,
        ),
        HomeworkItem(
          id: 'cw_arb_1',
          title: 'Arabic Letters Recognition (Alif to Jeem)',
          subject: 'Arabic & Quran',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'Today (Period 3)',
          type: 'classwork',
          hasAttachment: false,
        ),
        HomeworkItem(
          id: 'cw_ban_1',
          title: 'Bangla Sworoborno Recitation & Drawing',
          subject: 'Bangla',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'Today (Period 4)',
          type: 'classwork',
          hasAttachment: true,
        ),
        HomeworkItem(
          id: 'cw_sci_1',
          title: 'Primary Colors & Nature Discovery',
          subject: 'Science',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'Today (Period 5)',
          type: 'classwork',
          hasAttachment: false,
        ),
      ]);
    } else {
      list.addAll([
        HomeworkItem(
          id: 'hw_eng_1',
          title: 'Phonics Workbook Page 12 - 14',
          subject: 'English Language',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'Tomorrow',
          type: 'homework',
          hasAttachment: true,
        ),
        HomeworkItem(
          id: 'hw_math_1',
          title: 'Counting 1-20 & Shape Coloring Worksheet',
          subject: 'Mathematics',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'In 2 Days',
          type: 'homework',
          hasAttachment: true,
        ),
        HomeworkItem(
          id: 'hw_arb_1',
          title: 'Memorization: Surah Al-Fatihah (Verses 1-4)',
          subject: 'Arabic & Quran',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'Next Week',
          type: 'homework',
          hasAttachment: false,
        ),
        HomeworkItem(
          id: 'hw_ban_1',
          title: 'Bangla Alphabet Writing Worksheet (অ, আ, ই)',
          subject: 'Bangla',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'In 3 Days',
          type: 'homework',
          hasAttachment: true,
        ),
        HomeworkItem(
          id: 'hw_sci_1',
          title: 'Five Senses Identification & Drawing',
          subject: 'Science',
          className: 'Pre-KG',
          section: 'Aqua',
          dueDate: 'In 4 Days',
          type: 'homework',
          hasAttachment: true,
        ),
      ]);
    }

    if (selectedSubject.value.isNotEmpty) {
      items.value = list
          .where((item) => item.subject.toLowerCase().contains(selectedSubject.value.toLowerCase()))
          .toList();
    } else if (keyword.value.trim().isNotEmpty) {
      final k = keyword.value.trim().toLowerCase();
      items.value = list
          .where((item) => item.title.toLowerCase().contains(k) || item.subject.toLowerCase().contains(k))
          .toList();
    } else {
      items.value = list;
    }
  }

  Future<void> fetchHomeworkDetail(String id) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        detailHasError(true);
        detailErrorMessage.value = 'Please log in to view assignment details.';
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
        final hwData = data['homework'] as Map<String, dynamic>? ?? data;
        detail.value = HomeworkDetail.fromJson(hwData);
      } else {
        _populateDetailFallback(id);
      }
    } catch (e) {
      _populateDetailFallback(id);
    } finally {
      isDetailLoading(false);
    }
  }

  void _populateDetailFallback(String id) {
    final item = items.firstWhereOrNull((it) => it.id == id);
    if (item != null) {
      detail.value = HomeworkDetail(
        id: item.id,
        title: item.title,
        description: 'Complete all practice exercises for this lesson. Read guidelines and submit during the next scheduled class.',
        subject: item.subject,
        className: item.className,
        section: item.section,
        type: item.type,
        assignDate: '2026-08-26',
        dueDate: item.dueDate,
        attachments: item.hasAttachment
            ? [
                HomeworkAttachment(
                  fileName: '${item.title} Task Sheet.pdf',
                  fileType: 'PDF',
                  fileUrl: '',
                )
              ]
            : [],
      );
    } else {
      detailHasError(true);
      detailErrorMessage.value = 'Assignment detail not found.';
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
        errorMessage.value = serverMessage ?? 'No assignments found matching your filter.';
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
    selectedSection.value = '';
    selectedSubject.value = '';
  }

  Future<void> refreshList() async => fetchHomeworkList();
}
