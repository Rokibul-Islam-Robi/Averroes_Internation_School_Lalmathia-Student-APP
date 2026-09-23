import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS — Live Classes
// Matched to Student API Integration Guide v1.1 (Section 5)
// Endpoints: GET /student/live-classes/today, GET /student/live-classes/{id}
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

class LiveClassModel {
  final String id;
  final String title;
  final String subject;
  final String teacher;
  final String room;
  final String startTime;
  final String endTime;
  final String? date;
  final bool meetingReady;
  final bool joinAllowed;
  final String? joinUrl;
  final String? joinAvailableFrom;
  final String? joinAvailableUntil;
  final bool isCancelled;
  final String status;

  LiveClassModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    this.date,
    required this.meetingReady,
    required this.joinAllowed,
    this.joinUrl,
    this.joinAvailableFrom,
    this.joinAvailableUntil,
    this.isCancelled = false,
    required this.status,
  });

  factory LiveClassModel.fromJson(Map<String, dynamic> json) {
    final rawMeetingReady = json['meeting_ready'] == true || json['meeting_ready']?.toString() == '1';
    final rawJoinAllowed = json['join_allowed'] == true || json['join_allowed']?.toString() == '1';
    final rawCancelled = json['is_cancelled'] == true || json['is_cancelled']?.toString() == '1';

    return LiveClassModel(
      id: json['id']?.toString() ?? '',
      title: _extractName(json['title'] ?? json['topic'] ?? json['subject'], 'Live Class'),
      subject: _extractName(json['subject'] ?? json['subject_name']),
      teacher: _extractName(json['teacher'] ?? json['teacher_name'] ?? json['instructor']),
      room: _extractName(json['room'] ?? json['room_no']),
      startTime: json['start_time']?.toString() ?? json['start']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? json['end']?.toString() ?? '',
      date: json['date']?.toString(),
      meetingReady: rawMeetingReady,
      joinAllowed: rawJoinAllowed,
      joinUrl: json['join_url']?.toString(),
      joinAvailableFrom: json['join_available_from']?.toString(),
      joinAvailableUntil: json['join_available_until']?.toString(),
      isCancelled: rawCancelled,
      status: json['status']?.toString() ?? (rawJoinAllowed ? 'Live Now' : 'Scheduled'),
    );
  }

  String get timeFormatted {
    if (startTime.isEmpty && endTime.isEmpty) return '';
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      return '$startTime - $endTime';
    }
    return startTime.isNotEmpty ? startTime : endTime;
  }

  bool get isLiveNow => joinAllowed && (joinUrl != null && joinUrl!.isNotEmpty);
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — LiveClassController
// ════════════════════════════════════════════════════════════════════════════

class LiveClassController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _todayLiveClassesEndpoint = '/student/live-classes/today';
  static const String _singleLiveClassEndpoint = '/student/live-classes';

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

  var date = ''.obs;
  var timezone = ''.obs;
  var classes = <LiveClassModel>[].obs;
  var count = 0.obs;

  // Single class detail state
  var isDetailLoading = false.obs;
  var detailHasError = false.obs;
  var detailErrorMessage = ''.obs;
  Rx<LiveClassModel?> classDetail = Rx<LiveClassModel?>(null);

  LiveClassModel? get activeLiveClass {
    try {
      return classes.firstWhere((c) => c.isLiveNow);
    } catch (_) {
      return classes.isNotEmpty ? classes.first : null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTodayLiveClasses();
  }

  // ── GET /student/live-classes/today ──
  Future<void> fetchTodayLiveClasses() async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        hasError(true);
        errorMessage.value = 'Please log in to view live classes.';
        isLoading(false);
        return;
      }

      isLoading(true);
      hasError(false);
      isSessionExpired(false);

      final uri = Uri.parse('$_baseUrl$_todayLiveClassesEndpoint');
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
        List rawList = [];

        if (rawData is List) {
          rawList = rawData;
        } else if (rawData is Map<String, dynamic>) {
          date.value = rawData['date']?.toString() ?? '';
          timezone.value = rawData['timezone']?.toString() ?? '';
          count.value = int.tryParse(rawData['count']?.toString() ?? '') ?? 0;
          rawList = (rawData['classes'] as List<dynamic>?) ??
              (rawData['live_classes'] as List<dynamic>?) ??
              (rawData['items'] as List<dynamic>?) ??
              (rawData['data'] as List<dynamic>?) ??
              [];
        }

        classes.value = rawList
            .whereType<Map<String, dynamic>>()
            .map((e) => LiveClassModel.fromJson(e))
            .where((c) => !c.isCancelled)
            .toList();
        count.value = classes.length;
      } else {
        _handleErrorStatus(response.statusCode, decoded);
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isLoading(false);
    }
  }

  // ── GET /student/live-classes/{id} ──
  Future<void> fetchLiveClassDetail(String liveClassId) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        detailHasError(true);
        detailErrorMessage.value = 'Please log in to view class details.';
        return;
      }

      isDetailLoading(true);
      detailHasError(false);
      classDetail.value = null;

      final uri = Uri.parse('$_baseUrl$_singleLiveClassEndpoint/$liveClassId');
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
        final classData = data['live_class'] as Map<String, dynamic>? ?? data;
        classDetail.value = LiveClassModel.fromJson(classData);
      } else if (response.statusCode == 404) {
        detailHasError(true);
        detailErrorMessage.value = 'This live class is not accessible or not found.';
      } else {
        detailHasError(true);
        detailErrorMessage.value = decoded?['message']?.toString() ?? 'Failed to load class info.';
      }
    } catch (e) {
      detailHasError(true);
      detailErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      isDetailLoading(false);
    }
  }

  Future<bool> joinClass(LiveClassModel liveClass) async {
    final url = liveClass.joinUrl;
    if (url == null || url.isEmpty || !liveClass.joinAllowed) {
      Get.snackbar(
        'Join Not Allowed',
        'Meeting URL is only available from 15 minutes before class start until 10 minutes after class end.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        Get.snackbar('Error', 'Could not open meeting URL.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to launch meeting link.', snackPosition: SnackPosition.BOTTOM);
      return false;
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
        errorMessage.value = serverMessage ?? 'Account does not have live class access.';
        break;
      case 404:
        hasError(true);
        errorMessage.value = serverMessage ?? 'No live classes scheduled for today.';
        break;
      default:
        hasError(true);
        errorMessage.value = serverMessage ?? 'Server error ($statusCode). Please try again.';
    }
  }

  Future<void> refreshLiveClasses() async => fetchTodayLiveClasses();
}
