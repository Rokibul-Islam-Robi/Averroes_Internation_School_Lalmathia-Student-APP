import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS: Appointment Module
// Integration based on Averroes International School ERP Student Appointment API
// Endpoints:
//  - GET  /api/student/appointment-recipients
//  - POST /api/student/appointments
//  - GET  /api/student/appointments
//  - GET  /api/student/appointments/{id}
//  - POST /api/student/appointments/{id}/cancel
//  - POST /api/student/appointments/{id}/read
// ════════════════════════════════════════════════════════════════════════════

class AppointmentRecipient {
  final int employeeId;
  final String employeeUid;
  final String name;
  final String designation;
  final String department;
  final String? officeHours;
  final String? avatarUrl;

  AppointmentRecipient({
    required this.employeeId,
    required this.employeeUid,
    required this.name,
    required this.designation,
    required this.department,
    this.officeHours,
    this.avatarUrl,
  });

  factory AppointmentRecipient.fromJson(Map<String, dynamic> json) {
    String dept = '';
    if (json['department'] is Map<String, dynamic>) {
      dept = json['department']['name']?.toString() ?? '';
    } else if (json['department'] != null) {
      dept = json['department'].toString();
    }

    final empId = int.tryParse(json['employee_id']?.toString() ??
            json['id']?.toString() ??
            json['user_id']?.toString() ??
            '0') ??
        0;
    final dName = json['designation']?.toString() ??
        json['designation_name']?.toString() ??
        json['position']?.toString() ??
        json['role']?.toString() ??
        json['title']?.toString() ??
        json['designation_title']?.toString() ??
        'Faculty Member';
    final nName = json['name']?.toString() ??
        json['official_name']?.toString() ??
        json['teacher_name']?.toString() ??
        json['employee_name']?.toString() ??
        json['full_name']?.toString() ??
        'School Official';

    return AppointmentRecipient(
      employeeId: empId,
      employeeUid: json['employee_uid']?.toString() ?? json['uid']?.toString() ?? '',
      name: nName,
      designation: dName,
      department: dept.isNotEmpty ? dept : 'Academic',
      officeHours: json['office_hours']?.toString() ?? json['available_hours']?.toString(),
      avatarUrl: json['avatar_url']?.toString() ?? json['image']?.toString(),
    );
  }

  bool get isVicePrincipal {
    final d = designation.toLowerCase().trim();
    final n = name.toLowerCase().trim();
    return d.contains('vice') ||
        n.contains('vice') ||
        d.contains('vp') ||
        d.contains('v.p') ||
        d.contains('assistant head');
  }

  bool get isPrincipal {
    if (isVicePrincipal) return false;
    final d = designation.toLowerCase().trim();
    final n = name.toLowerCase().trim();
    return d.contains('principal') ||
        n.contains('principal') ||
        d.contains('head of school') ||
        d.contains('headmistress') ||
        d.contains('headmaster') ||
        d.contains('executive principal') ||
        d.contains('senior principal') ||
        d.contains('acting principal');
  }

  bool get isPrincipalOrVice => isPrincipal || isVicePrincipal;

  bool get isLeadership {
    final d = designation.toLowerCase().trim();
    return isPrincipalOrVice ||
        d.contains('head') ||
        d.contains('director') ||
        d.contains('coordinator') ||
        d.contains('incharge') ||
        d.contains('in-charge') ||
        d.contains('dean');
  }

  bool get isTeacher => !isLeadership;

  int get priorityScore {
    if (isPrincipal) return 1;
    if (isVicePrincipal) return 2;
    if (isLeadership) return 3;
    return 4;
  }
}

class AppointmentPurpose {
  final String value;
  final String label;

  AppointmentPurpose({required this.value, required this.label});

  factory AppointmentPurpose.fromJson(Map<String, dynamic> json) {
    return AppointmentPurpose(
      value: json['value']?.toString() ?? json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}

class AppointmentSchedule {
  final String? date;
  final String? startTime;
  final String? endTime;
  final String meetingMode; // in_person, phone, online
  final String meetingModeLabel; // In Person, Phone Call, Online Meeting
  final String? venue;
  final String? meetingLink;

  AppointmentSchedule({
    this.date,
    this.startTime,
    this.endTime,
    this.meetingMode = 'in_person',
    this.meetingModeLabel = 'In Person',
    this.venue,
    this.meetingLink,
  });

  factory AppointmentSchedule.fromJson(Map<String, dynamic> json) {
    return AppointmentSchedule(
      date: json['date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      meetingMode: json['meeting_mode']?.toString() ?? 'in_person',
      meetingModeLabel: json['meeting_mode_label']?.toString() ?? 'In Person',
      venue: json['venue']?.toString(),
      meetingLink: json['meeting_link']?.toString(),
    );
  }
}

class AppointmentAttendee {
  final String name;
  final String relationship;
  final String phone;

  AppointmentAttendee({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  factory AppointmentAttendee.fromJson(Map<String, dynamic> json) {
    return AppointmentAttendee(
      name: json['name']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? json['relation']?.toString() ?? 'Guardian',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class AppointmentItem {
  final int id;
  final String appointmentNo;
  final AppointmentRecipient recipient;
  final String purpose;
  final String purposeLabel;
  final String subject;
  final String details;
  final String preferredDate;
  final String? preferredStartTime;
  final String? preferredEndTime;
  final AppointmentAttendee attendee;
  final String status; // requested, scheduled, completed, declined, cancelled
  final String statusLabel;
  final AppointmentSchedule? schedule;
  final String? teacherResponse;
  final String? cancellationReason;
  bool hasUpdate;
  final String requestedAt;
  final String? scheduledAt;
  final String? completedAt;
  final String? declinedAt;
  final String? cancelledAt;
  final String? updatedAt;

  AppointmentItem({
    required this.id,
    required this.appointmentNo,
    required this.recipient,
    required this.purpose,
    required this.purposeLabel,
    required this.subject,
    required this.details,
    required this.preferredDate,
    this.preferredStartTime,
    this.preferredEndTime,
    required this.attendee,
    required this.status,
    required this.statusLabel,
    this.schedule,
    this.teacherResponse,
    this.cancellationReason,
    this.hasUpdate = false,
    required this.requestedAt,
    this.scheduledAt,
    this.completedAt,
    this.declinedAt,
    this.cancelledAt,
    this.updatedAt,
  });

  factory AppointmentItem.fromJson(Map<String, dynamic> json) {
    // Recipient parsing
    AppointmentRecipient parsedRecipient;
    if (json['recipient'] is Map<String, dynamic>) {
      parsedRecipient = AppointmentRecipient.fromJson(json['recipient']);
    } else {
      parsedRecipient = AppointmentRecipient(
        employeeId: int.tryParse(json['recipient_employee_id']?.toString() ?? json['employee_id']?.toString() ?? '0') ?? 0,
        employeeUid: '',
        name: json['authority_name']?.toString() ?? json['official_name']?.toString() ?? 'School Official',
        designation: json['official_designation']?.toString() ?? json['authority_role']?.toString() ?? 'Staff Member',
        department: json['campus']?.toString() ?? 'Academic',
      );
    }

    // Preferred date & time parsing
    String prefDate = '';
    String? prefStart;
    String? prefEnd;
    if (json['preferred'] is Map<String, dynamic>) {
      prefDate = json['preferred']['date']?.toString() ?? '';
      prefStart = json['preferred']['start_time']?.toString();
      prefEnd = json['preferred']['end_time']?.toString();
    } else {
      prefDate = json['preferred_date']?.toString() ?? json['date']?.toString() ?? '';
      prefStart = json['preferred_start_time']?.toString() ?? json['preferred_time_slot']?.toString();
      prefEnd = json['preferred_end_time']?.toString();
    }

    // Attendee parsing
    AppointmentAttendee parsedAttendee;
    if (json['attendee'] is Map<String, dynamic>) {
      parsedAttendee = AppointmentAttendee.fromJson(json['attendee']);
    } else {
      parsedAttendee = AppointmentAttendee(
        name: json['attendee_name']?.toString() ?? json['guardian_name']?.toString() ?? '',
        relationship: json['attendee_relation']?.toString() ?? json['guardian_relation']?.toString() ?? 'Guardian',
        phone: json['attendee_phone']?.toString() ?? json['guardian_phone']?.toString() ?? '',
      );
    }

    // Schedule parsing
    AppointmentSchedule? parsedSchedule;
    if (json['schedule'] is Map<String, dynamic>) {
      parsedSchedule = AppointmentSchedule.fromJson(json['schedule']);
    } else if (json['confirmed_date'] != null || json['scheduled_date'] != null) {
      parsedSchedule = AppointmentSchedule(
        date: json['confirmed_date']?.toString() ?? json['scheduled_date']?.toString(),
        startTime: json['confirmed_time']?.toString() ?? json['scheduled_time']?.toString(),
        endTime: null,
        meetingMode: json['meeting_mode']?.toString() ?? 'in_person',
        meetingModeLabel: json['meeting_mode_label']?.toString() ?? 'In Person',
        venue: json['venue']?.toString(),
        meetingLink: json['meeting_link']?.toString(),
      );
    }

    final rawStatus = json['status']?.toString().toLowerCase().trim() ?? 'requested';
    final normStatus = rawStatus.replaceAll('-', '_').replaceAll(' ', '_');

    String sLabel = json['status_label']?.toString() ?? '';
    if (sLabel.isEmpty) {
      switch (normStatus) {
        case 'scheduled':
        case 'confirmed':
        case 'approved':
          sLabel = 'Scheduled';
          break;
        case 'completed':
          sLabel = 'Completed';
          break;
        case 'declined':
        case 'rejected':
          sLabel = 'Declined';
          break;
        case 'cancelled':
        case 'canceled':
          sLabel = 'Cancelled';
          break;
        case 'requested':
        case 'pending':
        default:
          sLabel = 'Requested';
          break;
      }
    }

    return AppointmentItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      appointmentNo: json['appointment_no']?.toString() ??
          (json['id'] != null ? 'APT-${json['id']}' : 'APT-NEW'),
      recipient: parsedRecipient,
      purpose: json['purpose']?.toString() ?? '',
      purposeLabel: json['purpose_label']?.toString() ??
          (json['purpose']?.toString().isNotEmpty == true ? json['purpose'].toString() : 'Academic Discussion'),
      subject: json['subject']?.toString() ?? '',
      details: json['details']?.toString() ??
          json['reason']?.toString() ??
          json['description']?.toString() ??
          '',
      preferredDate: prefDate,
      preferredStartTime: prefStart,
      preferredEndTime: prefEnd,
      attendee: parsedAttendee,
      status: normStatus,
      statusLabel: sLabel,
      schedule: parsedSchedule,
      teacherResponse: json['teacher_response']?.toString() ??
          json['admin_note']?.toString() ??
          json['admin_response']?.toString() ??
          json['reply']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString() ?? json['cancel_reason']?.toString(),
      hasUpdate: json['has_update'] == true || json['has_update'] == 1,
      requestedAt: json['requested_at']?.toString() ?? json['created_at']?.toString() ?? '',
      scheduledAt: json['scheduled_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      declinedAt: json['declined_at']?.toString(),
      cancelledAt: json['cancelled_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isRequested => status == 'requested' || status == 'pending' || status == 'submitted';
  bool get isScheduled => status == 'scheduled' || status == 'confirmed' || status == 'approved';
  bool get isCompleted => status == 'completed' || status == 'finished';
  bool get isDeclined => status == 'declined' || status == 'rejected';
  bool get isCancelled => status == 'cancelled' || status == 'canceled';
  bool get canCancel => isRequested || isScheduled;
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER: AppointmentController
// ════════════════════════════════════════════════════════════════════════════

class AppointmentController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';

  // Observable state
  final appointmentsList = <AppointmentItem>[].obs;
  final recipientsList = <AppointmentRecipient>[].obs;
  final purposesList = <AppointmentPurpose>[].obs;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isRecipientsLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

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

  @override
  void onInit() {
    super.onInit();
    _initDefaultPurposes();
    fetchRecipients();
    fetchAppointments();
  }

  // ── Default purpose fallback presets ──
  void _initDefaultPurposes() {
    purposesList.value = [
      AppointmentPurpose(value: 'academic', label: 'Academic Discussion'),
      AppointmentPurpose(value: 'student_welfare', label: 'Student Welfare'),
      AppointmentPurpose(value: 'attendance', label: 'Attendance Consultation'),
      AppointmentPurpose(value: 'discipline', label: 'Discipline & Pastoral Care'),
      AppointmentPurpose(value: 'administrative', label: 'Administrative Matter'),
      AppointmentPurpose(value: 'other', label: 'Other'),
    ];
  }

  // ── 1. Fetch Eligible Appointment Recipients: GET /student/appointment-recipients ──
  Future<void> fetchRecipients() async {
    try {
      isRecipientsLoading(true);
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return;

      final uri = Uri.parse('$_baseUrl/student/appointment-recipients');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && decoded['data'] != null) {
          final dynamic data = decoded['data'];

          // A. Parse Recipients
          List<dynamic>? rawRecipients;
          if (data is Map<String, dynamic>) {
            rawRecipients = data['recipients'] as List<dynamic>? ??
                data['employees'] as List<dynamic>? ??
                data['officials'] as List<dynamic>? ??
                data['data'] as List<dynamic>?;
          } else if (data is List) {
            rawRecipients = data;
          }

          if (rawRecipients != null) {
            final parsed = rawRecipients
                .whereType<Map<String, dynamic>>()
                .map((e) => AppointmentRecipient.fromJson(e))
                // Exclude any Chairman / Vice Chairman as per school directives
                .where((r) =>
                    !r.designation.toLowerCase().contains('chairman') &&
                    !r.name.toLowerCase().contains('chairman'))
                .toList();

            if (parsed.isNotEmpty) {
              // Ensure Principal & Vice Principal appear FIRST, then Leadership, then Teachers
              parsed.sort((a, b) {
                if (a.priorityScore != b.priorityScore) {
                  return a.priorityScore.compareTo(b.priorityScore);
                }
                return a.name.compareTo(b.name);
              });
              recipientsList.value = parsed;
            }
          }

          // B. Parse Purposes if provided by API
          if (data is Map<String, dynamic> && data['purposes'] != null) {
            final rawPurposes = data['purposes'] as List<dynamic>?;
            if (rawPurposes != null && rawPurposes.isNotEmpty) {
              final parsedPurposes = rawPurposes
                  .whereType<Map<String, dynamic>>()
                  .map((e) => AppointmentPurpose.fromJson(e))
                  .where((p) => p.value.isNotEmpty && p.label.isNotEmpty)
                  .toList();

              if (parsedPurposes.isNotEmpty) {
                purposesList.value = parsedPurposes;
              }
            }
          }
        }
      }
    } catch (_) {
    } finally {
      isRecipientsLoading(false);
    }
  }

  // ── 2. Fetch Student's Real Appointments: GET /student/appointments ──
  Future<void> fetchAppointments({String? status, bool showLoading = true}) async {
    try {
      if (showLoading) isLoading(true);
      hasError(false);
      errorMessage.value = '';

      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        isLoading(false);
        return;
      }

      var uri = Uri.parse('$_baseUrl/student/appointments');
      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        uri = uri.replace(queryParameters: {'status': status.toLowerCase(), 'page': '1', 'per_page': '50'});
      } else {
        uri = uri.replace(queryParameters: {'page': '1', 'per_page': '50'});
      }

      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 14));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && (decoded['status'] == 'success' || decoded['status'] == true || decoded['status'] == 200 || decoded['data'] != null)) {
          final dynamic data = decoded['data'];
          List<dynamic>? list;

          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic>) {
            list = data['appointments'] as List<dynamic>? ??
                data['items'] as List<dynamic>? ??
                data['data'] as List<dynamic>?;
          }

          if (list != null) {
            appointmentsList.value = list
                .whereType<Map<String, dynamic>>()
                .map((e) => AppointmentItem.fromJson(e))
                .toList();
          } else {
            appointmentsList.value = [];
          }
        } else {
          appointmentsList.value = [];
        }
      } else if (res.statusCode == 401) {
        appointmentsList.value = [];
        hasError(true);
        errorMessage.value = 'Session expired. Please sign in again.';
      } else {
        appointmentsList.value = [];
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = 'Failed to load appointments from server. Please pull down to refresh.';
    } finally {
      isLoading(false);
    }
  }

  // ── 3. Fetch Single Appointment Detail: GET /student/appointments/{id} ──
  Future<AppointmentItem?> fetchAppointmentDetail(int id) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return null;

      final uri = Uri.parse('$_baseUrl/student/appointments/$id');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && decoded['data'] != null) {
          final dynamic data = decoded['data'];
          Map<String, dynamic>? itemMap;
          if (data is Map<String, dynamic>) {
            if (data.containsKey('appointment') && data['appointment'] is Map<String, dynamic>) {
              itemMap = data['appointment'];
            } else {
              itemMap = data;
            }
          }
          if (itemMap != null) {
            final parsed = AppointmentItem.fromJson(itemMap);
            final idx = appointmentsList.indexWhere((a) => a.id == id);
            if (idx != -1) {
              appointmentsList[idx] = parsed;
            }
            return parsed;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ── 4. Submit New Appointment: POST /student/appointments ──
  Future<Map<String, dynamic>> submitAppointment({
    required int recipientEmployeeId,
    required String purpose,
    required String subject,
    required String details,
    required String preferredDate, // YYYY-MM-DD
    String? preferredStartTime, // HH:MM
    String? preferredEndTime, // HH:MM
    required String attendeeName,
    required String attendeeRelation,
    required String attendeePhone,
  }) async {
    try {
      isSubmitting(true);
      final token = await _ensureToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication required. Please log in to submit appointment.',
        };
      }

      final payload = {
        'recipient_employee_id': recipientEmployeeId,
        'purpose': purpose,
        'subject': subject.trim(),
        'details': details.trim(),
        'preferred_date': preferredDate.trim(),
        if (preferredStartTime != null && preferredStartTime.trim().isNotEmpty)
          'preferred_start_time': preferredStartTime.trim(),
        if (preferredEndTime != null && preferredEndTime.trim().isNotEmpty)
          'preferred_end_time': preferredEndTime.trim(),
        'attendee_name': attendeeName.trim(),
        'attendee_relation': attendeeRelation.trim(),
        'attendee_phone': attendeePhone.trim(),
      };

      final uri = Uri.parse('$_baseUrl/student/appointments');
      final res = await http
          .post(
            uri,
            headers: _getHeaders(token),
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 16));

      final decoded = json.decode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        AppointmentItem? created;
        if (decoded != null && decoded['data'] is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data.containsKey('appointment') && data['appointment'] is Map<String, dynamic>) {
            created = AppointmentItem.fromJson(data['appointment']);
          } else {
            created = AppointmentItem.fromJson(data);
          }
        }

        if (created != null) {
          appointmentsList.insert(0, created);
        } else {
          // Refresh list from server
          fetchAppointments(showLoading: false);
        }

        return {
          'success': true,
          'message': decoded?['message'] ?? 'Appointment request submitted successfully.',
          'item': created,
        };
      } else {
        String errorMsg = 'Failed to submit appointment.';
        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] != null) {
            errorMsg = decoded['message'].toString();
          } else if (decoded['error'] != null) {
            errorMsg = decoded['error'].toString();
          } else if (decoded['errors'] != null) {
            final errs = decoded['errors'];
            if (errs is Map) {
              errorMsg = errs.values.map((v) => v is List ? v.join(', ') : v.toString()).join('\n');
            } else {
              errorMsg = errs.toString();
            }
          }
        }
        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network connection error. Please check your internet and try again.',
      };
    } finally {
      isSubmitting(false);
    }
  }

  // ── 5. Cancel Appointment: POST /student/appointments/{id}/cancel ──
  Future<Map<String, dynamic>> cancelAppointment(int id, {String? reason}) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Authentication required.'};
      }

      final uri = Uri.parse('$_baseUrl/student/appointments/$id/cancel');
      final res = await http
          .post(
            uri,
            headers: _getHeaders(token),
            body: json.encode({'reason': reason ?? 'Cancelled by parent/guardian'}),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = json.decode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final index = appointmentsList.indexWhere((a) => a.id == id);
        if (index != -1) {
          final existing = appointmentsList[index];
          appointmentsList[index] = AppointmentItem(
            id: existing.id,
            appointmentNo: existing.appointmentNo,
            recipient: existing.recipient,
            purpose: existing.purpose,
            purposeLabel: existing.purposeLabel,
            subject: existing.subject,
            details: existing.details,
            preferredDate: existing.preferredDate,
            preferredStartTime: existing.preferredStartTime,
            preferredEndTime: existing.preferredEndTime,
            attendee: existing.attendee,
            status: 'cancelled',
            statusLabel: 'Cancelled',
            schedule: existing.schedule,
            teacherResponse: existing.teacherResponse,
            cancellationReason: reason ?? 'Cancelled by parent/guardian',
            hasUpdate: false,
            requestedAt: existing.requestedAt,
            scheduledAt: existing.scheduledAt,
            completedAt: existing.completedAt,
            declinedAt: existing.declinedAt,
            cancelledAt: _formatDateNow(),
            updatedAt: _formatDateNow(),
          );
        }
        return {
          'success': true,
          'message': decoded?['message'] ?? 'Appointment request cancelled successfully.',
        };
      } else {
        String errorMsg = 'Unable to cancel appointment.';
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          errorMsg = decoded['message'].toString();
        }
        return {'success': false, 'message': errorMsg};
      }
    } catch (_) {
      return {'success': false, 'message': 'Network error while cancelling appointment.'};
    }
  }

  // ── 6. Mark Update as Read: POST /student/appointments/{id}/read ──
  Future<void> markAsRead(int id) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return;

      final uri = Uri.parse('$_baseUrl/student/appointments/$id/read');
      final res = await http.post(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final index = appointmentsList.indexWhere((a) => a.id == id);
        if (index != -1) {
          appointmentsList[index].hasUpdate = false;
          appointmentsList.refresh();
        }
      }
    } catch (_) {}
  }

  // ── 7. Mark All Appointment Updates as Read ──
  Future<void> markAllAsRead() async {
    for (final item in appointmentsList) {
      if (item.hasUpdate) {
        markAsRead(item.id);
      }
    }
    for (final item in appointmentsList) {
      item.hasUpdate = false;
    }
    appointmentsList.refresh();
  }

  String _formatDateNow() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
  }
}
