import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'complain_controller.dart';
import 'notification_model.dart';
import 'teachers_materials_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════════════════════
//
// নোট: Notification-এর নিজের model (NotificationModel) আলাদা ফাইলে আছে
// (notification_model.dart) — এটা প্রজেক্টে আগে থেকেই বানানো ছিল, তাই
// controller-টা সেটার সাথেই মিলিয়ে লেখা হয়েছে। এখানে শুধু Dashboard
// Summary-এর model রাখা হয়েছে, কারণ এটার জন্য আলাদা কোনো ফাইল ছিল না।

// ── Dashboard Summary — home screen-এর জন্য একটাই combined API call ────────
// Attendance %, pending assignment count, upcoming exam, next holiday —
// সব একসাথে আনা হয়, যাতে app চালু হওয়ার সময় আলাদা আলাদা call না করতে হয়।
// (Fees Due-এর নিজের আলাদা FeesController আগে থেকেই আছে এবং সেটা বেশি
// বিস্তারিত — তাই dashboard card-এ এখনো FeesController-ই ব্যবহার হবে।)
class DashboardSummary {
  final double attendancePercentage;
  final int pendingAssignmentsCount;
  final String upcomingExamName;
  final String upcomingExamDate;
  final String nextHolidayName;
  final String nextHolidayDate;

  DashboardSummary({
    required this.attendancePercentage,
    required this.pendingAssignmentsCount,
    required this.upcomingExamName,
    required this.upcomingExamDate,
    required this.nextHolidayName,
    required this.nextHolidayDate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      attendancePercentage:
      double.tryParse(json['attendance_percentage'].toString()) ?? 0.0,
      pendingAssignmentsCount:
      int.tryParse(json['pending_assignments_count'].toString()) ?? 0,
      upcomingExamName: json['upcoming_exam_name']?.toString() ?? '',
      upcomingExamDate: json['upcoming_exam_date']?.toString() ?? '',
      nextHolidayName: json['next_holiday_name']?.toString() ?? '',
      nextHolidayDate: json['next_holiday_date']?.toString() ?? '',
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
//
// ⚠️ এই module-এ পুশ নোটিফিকেশন (Firebase/FCM) নেই — শুধু in-app notification
// list আর dashboard summary আছে, যেমনটা ঠিক করা হয়েছিল।
class NotificationController extends GetxController {
  static const String _baseUrl =
      'https://averroesint.com/averroes_school_erp/api';
  static const String _summaryEndpoint = '/dashboard/summary';
  static const String _notificationsEndpoint = '/notifications';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;

  Future<String?> _ensureToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    _authToken = await WireframeSession.getToken();
    return _authToken;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _ensureToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── Dashboard Summary state ─────────────────────────────────────────────
  var isSummaryLoading = true.obs;
  var summaryHasError = false.obs;
  Rx<DashboardSummary?> summary = Rx<DashboardSummary?>(null);

  // ── Notifications list state ────────────────────────────────────────────
  // নাম গুলো notification_page.dart-এর সাথে exact মিলিয়ে রাখা হয়েছে:
  // isLoading (isNotificationsLoading না), notifications (List<NotificationModel>)
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var notifications = <NotificationModel>[].obs;

  // ── Unread count — bell আইকনের পাশে ছোট red badge দেখানোর জন্য ──────────
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
    fetchNotifications();
  }

  // ────────────────────────────────────────────────────────────────────────
  // DASHBOARD SUMMARY
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchDashboardSummary() async {
    try {
      isSummaryLoading(true);
      summaryHasError(false);

      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl$_summaryEndpoint');
      final response =
      await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          summary.value = DashboardSummary.fromJson(decoded['data']);
        } else {
          summaryHasError(true);
        }
      } else {
        summaryHasError(true);
      }
    } catch (e) {
      summaryHasError(true);
    } finally {
      isSummaryLoading(false);
    }
  }

  Future<void> refreshDashboardSummary() async => fetchDashboardSummary();

  // ────────────────────────────────────────────────────────────────────────
  // NOTIFICATIONS LIST (Synced with Real ERP Announcements, Complaints & Dues)
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      hasError(false);

      final headers = await _getHeaders();
      final List<NotificationModel> combinedList = [];
      final Set<String> seenIds = {};

      // 1. Fetch Real ERP Announcements & Notices
      final endpoints = [
        '/student/teacher-materials/announcements',
        '/student/announcements',
        _notificationsEndpoint,
        '/academic/notices',
      ];

      for (final ep in endpoints) {
        try {
          final uri = Uri.parse('$_baseUrl$ep');
          final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final decoded = json.decode(response.body);
            if (decoded != null && decoded['data'] != null) {
              final dynamic rawData = decoded['data'];
              List rows = [];
              if (rawData is List) {
                rows = rawData;
              } else if (rawData is Map<String, dynamic>) {
                rows = (rawData['announcements'] as List<dynamic>?) ??
                    (rawData['items'] as List<dynamic>?) ??
                    (rawData['notifications'] as List<dynamic>?) ??
                    (rawData['notices'] as List<dynamic>?) ??
                    (rawData['data'] as List<dynamic>?) ??
                    [];
              }

              for (final r in rows) {
                if (r is Map<String, dynamic>) {
                  final notif = NotificationModel.fromJson(r);
                  if (notif.id.isNotEmpty && !seenIds.contains(notif.id)) {
                    seenIds.add(notif.id);
                    combinedList.add(notif);
                  }
                }
              }
              if (combinedList.isNotEmpty) break;
            }
          }
        } catch (_) {}
      }

      // If empty from direct call, try to sync from active TeachersMaterialsController
      if (combinedList.isEmpty && Get.isRegistered<TeachersMaterialsController>()) {
        final tmCtrl = Get.find<TeachersMaterialsController>();
        for (final a in tmCtrl.announcements) {
          if (!seenIds.contains(a.id)) {
            seenIds.add(a.id);
            combinedList.add(NotificationModel(
              id: a.id,
              title: a.title,
              message: a.message,
              type: a.isImportant ? 'holiday' : 'general',
              time: a.publishedAt ?? 'Recent',
              fileUrl: a.fileUrl,
              fileSize: a.fileSize,
              fileType: a.fileType,
              className: a.className,
              sectionName: a.sectionName,
              teacherName: a.teacherName,
              isRead: false,
            ));
          }
        }
      }

      // 2. Fetch Real Complaints & Administration Replies from ERP API
      try {
        final cmpUri = Uri.parse('$_baseUrl/student/complaints?page=1&per_page=100');
        final cmpRes = await http.get(cmpUri, headers: headers).timeout(const Duration(seconds: 10));
        if (cmpRes.statusCode == 200) {
          final decoded = json.decode(cmpRes.body);
          if (decoded != null && decoded['data'] != null) {
            final dynamic rawData = decoded['data'];
            List rows = [];
            if (rawData is List) {
              rows = rawData;
            } else if (rawData is Map<String, dynamic>) {
              rows = (rawData['complaints'] as List<dynamic>?) ?? (rawData['data'] as List<dynamic>?) ?? [];
            }

            for (final r in rows) {
              if (r is Map<String, dynamic>) {
                final item = ComplaintItem.fromJson(r);
                // If administration reply is present
                if (item.adminNote != null && item.adminNote!.trim().isNotEmpty) {
                  final replyId = 'cmp_reply_${item.id}';
                  if (!seenIds.contains(replyId)) {
                    seenIds.add(replyId);
                    combinedList.add(NotificationModel(
                      id: replyId,
                      title: 'Administration Reply: ${item.subject}',
                      message: item.adminNote!,
                      type: 'complain',
                      time: item.response?.respondedAt.isNotEmpty == true
                          ? item.response!.respondedAt
                          : item.submittedAt,
                      className: null,
                      sectionName: null,
                      teacherName: item.assignedTo?.name,
                      isRead: false,
                    ));
                  }
                }
                // If complaint has an active status update
                final st = item.status.toLowerCase();
                if (st == 'under_review' || st == 'action_taken' || st == 'resolved' || st == 'rejected') {
                  final statusId = 'cmp_status_${item.id}_$st';
                  if (!seenIds.contains(statusId)) {
                    seenIds.add(statusId);
                    combinedList.add(NotificationModel(
                      id: statusId,
                      title: 'Complaint ${item.statusLabel}: ${item.ticketNo}',
                      message: 'Your complaint regarding "${item.subject}" is currently ${item.statusLabel}.',
                      type: 'complain',
                      time: item.resolvedAt ?? item.reviewedAt ?? item.submittedAt,
                      isRead: false,
                    ));
                  }
                }
              }
            }
          }
        }
      } catch (_) {}

      // 3. Fetch Real Fees Due / Payment alerts from ERP API
      try {
        final feeUri = Uri.parse('$_baseUrl/student/fees-dues');
        final feeRes = await http.get(feeUri, headers: headers).timeout(const Duration(seconds: 10));
        if (feeRes.statusCode == 200) {
          final decoded = json.decode(feeRes.body);
          if (decoded != null && decoded['data'] != null) {
            final dynamic rawData = decoded['data'];
            List invoices = [];
            if (rawData is Map<String, dynamic>) {
              invoices = (rawData['invoices'] as List<dynamic>?) ??
                  (rawData['pending_invoices'] as List<dynamic>?) ??
                  (rawData['dues'] as List<dynamic>?) ??
                  [];
            } else if (rawData is List) {
              invoices = rawData;
            }

            for (final inv in invoices) {
              if (inv is Map<String, dynamic>) {
                final status = (inv['status'] ?? '').toString().toLowerCase();
                if (status != 'paid') {
                  final invId = inv['id']?.toString() ?? inv['invoice_number']?.toString() ?? '';
                  final feeNotifId = 'fee_due_$invId';
                  if (invId.isNotEmpty && !seenIds.contains(feeNotifId)) {
                    seenIds.add(feeNotifId);
                    final title = inv['fee_head_name'] ?? inv['title'] ?? inv['name'] ?? 'Tuition Fee';
                    final invNo = inv['invoice_number'] ?? inv['invoice_no'] ?? invId;
                    final dueAmt = inv['due_amount'] ?? inv['total_amount'] ?? inv['amount'] ?? '';
                    final dueDate = inv['due_date']?.toString() ?? '';
                    final month = inv['billing_month']?.toString() ?? inv['month']?.toString() ?? '';

                    combinedList.add(NotificationModel(
                      id: feeNotifId,
                      title: 'Fee Payment Due: $title',
                      message: 'Invoice #$invNo ${month.isNotEmpty ? "($month)" : ""} of BDT $dueAmt is due${dueDate.isNotEmpty ? " on $dueDate" : ""}.',
                      type: 'fee',
                      time: dueDate.isNotEmpty ? dueDate : (inv['issue_date']?.toString() ?? 'Recent'),
                      isRead: false,
                    ));
                  }
                }
              }
            }
          }
        }
      } catch (_) {}

      // 4. Fetch Real Appointment updates from ERP API
      try {
        final apptUri = Uri.parse('$_baseUrl/student/appointments?page=1&per_page=50');
        final apptRes = await http.get(apptUri, headers: headers).timeout(const Duration(seconds: 10));
        if (apptRes.statusCode == 200) {
          final decoded = json.decode(apptRes.body);
          if (decoded != null && decoded['data'] != null) {
            final dynamic rawData = decoded['data'];
            List appts = [];
            if (rawData is Map<String, dynamic>) {
              appts = (rawData['appointments'] as List<dynamic>?) ??
                  (rawData['items'] as List<dynamic>?) ??
                  (rawData['data'] as List<dynamic>?) ??
                  [];
            } else if (rawData is List) {
              appts = rawData;
            }

            for (final a in appts) {
              if (a is Map<String, dynamic>) {
                final aId = a['id']?.toString() ?? '';
                final apptNo = a['appointment_no']?.toString() ?? 'APT-$aId';
                final status = (a['status'] ?? '').toString().toLowerCase();
                final statusLabel = a['status_label']?.toString() ?? status;
                final teacherResp = a['teacher_response']?.toString() ?? a['admin_note']?.toString();
                final bool hasUpdate = a['has_update'] == true || a['has_update'] == 1;

                if (status == 'scheduled' || status == 'declined' || status == 'completed' || hasUpdate) {
                  final notifId = 'appt_${aId}_$status';
                  if (!seenIds.contains(notifId)) {
                    seenIds.add(notifId);
                    String msg = 'Your appointment ($apptNo) is currently $statusLabel.';
                    if (teacherResp != null && teacherResp.trim().isNotEmpty) {
                      msg = '$msg Response: "$teacherResp"';
                    }
                    combinedList.add(NotificationModel(
                      id: notifId,
                      title: 'Appointment $statusLabel: $apptNo',
                      message: msg,
                      type: 'appointment',
                      time: a['updated_at']?.toString() ?? a['scheduled_at']?.toString() ?? a['requested_at']?.toString() ?? 'Recent',
                      isRead: !hasUpdate,
                    ));
                  }
                }
              }
            }
          }
        }
      } catch (_) {}

      // Sort by time descending if possible
      combinedList.sort((a, b) => b.time.compareTo(a.time));

      notifications.value = combinedList;
    } catch (e) {
      debugPrint("Notifications fetch error: $e");
    } finally {
      isLoading(false);
    }
  }

  @override
  Future<void> refresh() async {
    await fetchNotifications();
    await fetchDashboardSummary();
  }

  // ── নির্দিষ্ট একটা notification read হিসেবে mark করা ────────────────────
  // optimistic update: আগে local list-এ সাথে সাথে read দেখিয়ে দেওয়া হয়,
  // backend call ব্যাকগ্রাউন্ডে হয় — UI instant মনে হবে।
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || notifications[index].isRead) return;

    notifications[index].isRead = true;
    notifications.refresh();

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl$_notificationsEndpoint/$notificationId/read');
      await http.put(uri, headers: headers).timeout(const Duration(seconds: 10));
    } catch (e) {
      // network ব্যর্থ হলেও local UI read-ই থাকবে; পরের fetchNotifications()
      // এ backend-এর real status আবার sync হয়ে যাবে।
    }
  }

  // ── সব notification একসাথে read করার জন্য ("Mark all read" বাটনের জন্য) ──
  Future<void> markAllAsRead() async {
    for (final n in notifications.where((n) => !n.isRead).toList()) {
      await markAsRead(n.id);
    }
  }
}
