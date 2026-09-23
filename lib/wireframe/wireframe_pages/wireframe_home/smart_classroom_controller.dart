import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS — Smart Classroom
// Matched to Student API Integration Guide v1.1 (Section 5)
// Endpoint: GET /student/smart-classroom
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
        val['teacher_name']?.toString() ??
        fallback;
  }
  return val.toString();
}

class SmartClassroomItem {
  final String id;
  final String title;
  final String description;
  final String subjectName;
  final String subjectCode;
  final String teacherName;
  final String room;
  final String status; // Active, Upcoming, Completed
  final String startTime;
  final String endTime;
  final String? joinUrl;
  final String? externalUrl;
  final String? fileUrl;
  final String? publishedAt;

  SmartClassroomItem({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectName,
    required this.subjectCode,
    required this.teacherName,
    required this.room,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.joinUrl,
    this.externalUrl,
    this.fileUrl,
    this.publishedAt,
  });

  factory SmartClassroomItem.fromJson(Map<String, dynamic> json) {
    final subjectObj = json['subject'] as Map<String, dynamic>?;
    final fileObj = json['file'] as Map<String, dynamic>?;

    return SmartClassroomItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Smart Class',
      description: json['description']?.toString() ?? '',
      subjectName: _extractName(json['subject'] ?? json['subject_name']),
      subjectCode: subjectObj?['code']?.toString() ?? json['subject_code']?.toString() ?? json['code']?.toString() ?? '',
      teacherName: _extractName(json['teacher'] ?? json['teacher_name']),
      room: _extractName(json['room'] ?? json['room_no']),
      status: json['status']?.toString() ?? 'Active',
      startTime: json['start_time']?.toString() ?? json['start']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? json['end']?.toString() ?? '',
      joinUrl: json['join_url']?.toString() ?? json['meeting_url']?.toString(),
      externalUrl: json['external_url']?.toString() ?? json['link']?.toString(),
      fileUrl: fileObj?['url']?.toString() ?? json['file_url']?.toString(),
      publishedAt: json['published_at']?.toString() ?? json['created_at']?.toString(),
    );
  }

  String get timeFormatted {
    if (startTime.isEmpty && endTime.isEmpty) return '';
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      return '$startTime - $endTime';
    }
    return startTime.isNotEmpty ? startTime : endTime;
  }

  String? get openableUrl => joinUrl ?? externalUrl ?? fileUrl;
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — SmartClassroomController
// ════════════════════════════════════════════════════════════════════════════

class SmartClassroomController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _smartClassroomEndpoint = '/student/smart-classroom';

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
  var isLoadingMore = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isSessionExpired = false.obs;

  var materials = <SmartClassroomItem>[].obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  bool get hasMorePages => currentPage.value < lastPage.value;

  var selectedSubjectId = ''.obs;
  var selectedTeacherId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSmartClassroom();
  }

  Future<void> fetchSmartClassroom() async {
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
        errorMessage.value = 'Please log in to view smart classroom.';
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
        if (selectedSubjectId.value.isNotEmpty) 'subject_id': selectedSubjectId.value,
        if (selectedTeacherId.value.isNotEmpty) 'teacher_id': selectedTeacherId.value,
      };

      final uri = Uri.parse('$_baseUrl$_smartClassroomEndpoint').replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _getHeaders(token))
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic>? decoded;
      try {
        decoded = json.decode(response.body) as Map<String, dynamic>?;
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode == 200 && decoded != null && decoded['data'] != null) {
        final dynamic rawData = decoded['data'];
        List rawMaterials = [];
        Map<String, dynamic>? pagination;

        if (rawData is List) {
          rawMaterials = rawData;
        } else if (rawData is Map<String, dynamic>) {
          rawMaterials = (rawData['materials'] as List<dynamic>?) ??
              (rawData['items'] as List<dynamic>?) ??
              (rawData['data'] as List<dynamic>?) ??
              (rawData['content'] as List<dynamic>?) ??
              [];
          pagination = rawData['pagination'] as Map<String, dynamic>?;
        }

        final list = rawMaterials
            .whereType<Map<String, dynamic>>()
            .map((e) => SmartClassroomItem.fromJson(e))
            .toList();

        if (append) {
          materials.addAll(list);
        } else {
          materials.value = list;
        }

        currentPage.value = pagination?['current_page'] as int? ?? page;
        lastPage.value = pagination?['last_page'] as int? ?? currentPage.value;
      } else {
        _handleErrorStatus(response.statusCode, decoded);
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  Future<void> openClassroomUrl(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('Error', 'No link available for this classroom.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open meeting/file link.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to launch URL.', snackPosition: SnackPosition.BOTTOM);
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
        errorMessage.value = serverMessage ?? 'Account does not have smart classroom access.';
        break;
      case 404:
        hasError(true);
        errorMessage.value = serverMessage ?? 'No smart classroom materials found.';
        break;
      default:
        hasError(true);
        errorMessage.value = serverMessage ?? 'Server error ($statusCode). Please try again.';
    }
  }

  Future<void> refreshSmartClassroom() async => fetchSmartClassroom();
}
