import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS: Complaint API Integration
// Matched to STUDENT_COMPLAINT_AND_RESULT_API.md
// Base URL: https://averroesint.com/averroes_school_erp/api
// Endpoints:
//  - GET  /student/complaint-departments
//  - GET  /student/complaint-employees
//  - POST /student/complaints
//  - GET  /student/complaints
//  - GET  /student/complaints/{id}
// ════════════════════════════════════════════════════════════════════════════

class ComplaintDepartment {
  final int id;
  final String name;

  ComplaintDepartment({
    required this.id,
    required this.name,
  });

  factory ComplaintDepartment.fromJson(Map<String, dynamic> json) {
    return ComplaintDepartment(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ComplaintEmployee {
  final int id;
  final String employeeUid;
  final String name;
  final String designation;
  final ComplaintDepartment? department;

  ComplaintEmployee({
    required this.id,
    required this.employeeUid,
    required this.name,
    required this.designation,
    this.department,
  });

  factory ComplaintEmployee.fromJson(Map<String, dynamic> json) {
    ComplaintDepartment? dept;
    if (json['department'] is Map<String, dynamic>) {
      dept = ComplaintDepartment.fromJson(json['department']);
    } else if (json['department_name'] != null || json['department_id'] != null) {
      dept = ComplaintDepartment(
        id: int.tryParse(json['department_id']?.toString() ?? '0') ?? 0,
        name: json['department_name']?.toString() ?? '',
      );
    }
    return ComplaintEmployee(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeUid: json['employee_uid']?.toString() ?? json['employee_id']?.toString() ?? json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? json['employee_name']?.toString() ?? json['full_name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? json['designation_name']?.toString() ?? json['title']?.toString() ?? '',
      department: dept,
    );
  }
}

class ComplaintTarget {
  final String type; // "department" or "employee"
  final int id;
  final String name;

  ComplaintTarget({
    required this.type,
    required this.id,
    required this.name,
  });

  factory ComplaintTarget.fromJson(Map<String, dynamic> json) {
    return ComplaintTarget(
      type: json['type']?.toString() ?? 'department',
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? json['employee_name']?.toString() ?? json['department_name']?.toString() ?? '',
    );
  }
}

class ComplaintAssignedTo {
  final int userId;
  final String name;

  ComplaintAssignedTo({
    required this.userId,
    required this.name,
  });

  factory ComplaintAssignedTo.fromJson(Map<String, dynamic> json) {
    return ComplaintAssignedTo(
      userId: int.tryParse(json['user_id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class ComplaintResponse {
  final String message;
  final String respondedAt;

  ComplaintResponse({
    required this.message,
    required this.respondedAt,
  });

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) {
    final msg = json['message']?.toString() ??
        json['reply']?.toString() ??
        json['admin_message']?.toString() ??
        json['response']?.toString() ??
        json['remarks']?.toString() ??
        json['note']?.toString() ??
        json['comment']?.toString() ??
        json['response_text']?.toString() ??
        json['feedback']?.toString() ??
        '';
    final time = json['responded_at']?.toString() ??
        json['created_at']?.toString() ??
        json['updated_at']?.toString() ??
        json['reply_at']?.toString() ??
        '';
    return ComplaintResponse(
      message: msg,
      respondedAt: time,
    );
  }
}

class ComplaintItem {
  final int id;
  final String complaintNo;
  final String againstType; // "department" or "employee"
  final ComplaintTarget? target;
  final String subject;
  final String details;
  final String priority; // "low", "normal", "high"
  final String priorityLabel; // "Low", "Normal", "High"
  final String status; // "submitted", "under_review", "action_taken", "resolved", "rejected", "closed"
  final String statusLabel;
  final ComplaintResponse? response;
  final ComplaintAssignedTo? assignedTo;
  final String submittedAt;
  final String? reviewedAt;
  final String? resolvedAt;
  final String? closedAt;
  final String? contactPhone;

  ComplaintItem({
    required this.id,
    required this.complaintNo,
    required this.againstType,
    this.target,
    required this.subject,
    required this.details,
    required this.priority,
    required this.priorityLabel,
    required this.status,
    required this.statusLabel,
    this.response,
    this.assignedTo,
    required this.submittedAt,
    this.reviewedAt,
    this.resolvedAt,
    this.closedAt,
    this.contactPhone,
  });

  factory ComplaintItem.fromJson(Map<String, dynamic> json) {
    ComplaintTarget? tgt;
    if (json['target'] is Map<String, dynamic>) {
      tgt = ComplaintTarget.fromJson(json['target']);
    } else if (json['department'] is Map<String, dynamic>) {
      tgt = ComplaintTarget.fromJson(json['department']);
    } else if (json['employee'] is Map<String, dynamic>) {
      tgt = ComplaintTarget.fromJson(json['employee']);
    } else if (json['department'] != null) {
      tgt = ComplaintTarget(type: 'department', id: 0, name: json['department'].toString());
    } else if (json['category'] != null) {
      tgt = ComplaintTarget(type: 'department', id: 0, name: json['category'].toString());
    }

    ComplaintResponse? resp;
    if (json['response'] is Map<String, dynamic>) {
      resp = ComplaintResponse.fromJson(json['response']);
    } else if (json['admin_response'] is Map<String, dynamic>) {
      resp = ComplaintResponse.fromJson(json['admin_response']);
    } else if (json['admin_reply'] is Map<String, dynamic>) {
      resp = ComplaintResponse.fromJson(json['admin_reply']);
    } else if (json['response'] is String && (json['response'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['response'] as String).trim(), respondedAt: '');
    } else if (json['admin_message'] is String && (json['admin_message'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['admin_message'] as String).trim(), respondedAt: '');
    } else if (json['admin_response'] is String && (json['admin_response'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['admin_response'] as String).trim(), respondedAt: '');
    } else if (json['admin_reply'] is String && (json['admin_reply'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['admin_reply'] as String).trim(), respondedAt: '');
    } else if (json['admin_note'] is String && (json['admin_note'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['admin_note'] as String).trim(), respondedAt: '');
    } else if (json['reply'] is String && (json['reply'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['reply'] as String).trim(), respondedAt: '');
    } else if (json['remarks'] is String && (json['remarks'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['remarks'] as String).trim(), respondedAt: '');
    } else if (json['resolution'] is String && (json['resolution'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['resolution'] as String).trim(), respondedAt: '');
    } else if (json['action_taken'] is String && (json['action_taken'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['action_taken'] as String).trim(), respondedAt: '');
    } else if (json['feedback'] is String && (json['feedback'] as String).trim().isNotEmpty) {
      resp = ComplaintResponse(message: (json['feedback'] as String).trim(), respondedAt: '');
    }

    ComplaintAssignedTo? assigned;
    if (json['assigned_to'] is Map<String, dynamic>) {
      assigned = ComplaintAssignedTo.fromJson(json['assigned_to']);
    }

    final rawPriority = json['priority']?.toString().toLowerCase().trim() ?? 'normal';
    String pLabel = json['priority_label']?.toString() ?? '';
    if (pLabel.isEmpty) {
      pLabel = rawPriority == 'high'
          ? 'Urgent'
          : (rawPriority == 'low' ? 'Low' : 'Normal');
    }

    final rawStatus = json['status']?.toString().toLowerCase().trim() ?? 'submitted';
    final normStatus = rawStatus.replaceAll('-', '_').replaceAll(' ', '_');

    String sLabel = json['status_label']?.toString() ?? '';
    if (sLabel.isEmpty) {
      switch (normStatus) {
        case 'under_review':
        case 'reviewing':
        case 'in_review':
          sLabel = 'Under Review';
          break;
        case 'action_taken':
        case 'in_progress':
        case 'processing':
          sLabel = 'Action Taken';
          break;
        case 'resolved':
        case 'completed':
        case 'solved':
          sLabel = 'Resolved';
          break;
        case 'rejected':
        case 'declined':
        case 'cancelled':
          sLabel = 'Rejected';
          break;
        case 'closed':
          sLabel = 'Closed';
          break;
        default:
          sLabel = 'Submitted';
      }
    }

    return ComplaintItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      complaintNo: json['complaint_no']?.toString() ?? json['ticket_no']?.toString() ?? 'CMP-${json['id'] ?? ''}',
      againstType: json['against_type']?.toString().toLowerCase().trim() ?? 'department',
      target: tgt,
      subject: json['subject']?.toString() ?? json['title']?.toString() ?? '',
      details: json['details']?.toString() ?? json['description']?.toString() ?? json['message']?.toString() ?? '',
      priority: rawPriority,
      priorityLabel: pLabel,
      status: normStatus,
      statusLabel: sLabel,
      response: resp,
      assignedTo: assigned,
      submittedAt: json['submitted_at']?.toString() ?? json['created_at']?.toString() ?? '',
      reviewedAt: json['reviewed_at']?.toString(),
      resolvedAt: json['resolved_at']?.toString(),
      closedAt: json['closed_at']?.toString(),
      contactPhone: json['contact_phone']?.toString() ?? json['phone']?.toString(),
    );
  }

  // Helper getters for backward-compatibility with UI
  String get ticketNo => complaintNo;
  String get category => target?.name ?? (againstType == 'employee' ? 'Staff / Teacher' : 'General');
  String get description => details;
  String get createdAt => submittedAt;
  String? get adminNote => response?.message;
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER: ComplainController
// ════════════════════════════════════════════════════════════════════════════

class ComplainController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';

  // Observable state
  final complaintsList = <ComplaintItem>[].obs;
  final departments = <ComplaintDepartment>[].obs;
  final employees = <ComplaintEmployee>[].obs;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isDeptLoading = false.obs;
  final isEmpLoading = false.obs;
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
    fetchComplaints();
    fetchDepartments();
    fetchEmployees();
  }

  // ── 1. Fetch Complaint Departments: GET /student/complaint-departments ──
  Future<void> fetchDepartments() async {
    try {
      isDeptLoading(true);
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return;

      final res = await http
          .get(Uri.parse('$_baseUrl/student/complaint-departments'), headers: _getHeaders(token))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && (decoded['status'] == 'success' || decoded['status'] == true || decoded['status'] == 200) && decoded['data'] != null) {
          final data = decoded['data'];
          List<dynamic>? list;
          if (data is Map<String, dynamic>) {
            list = data['departments'] as List<dynamic>? ?? data['data'] as List<dynamic>?;
          } else if (data is List) {
            list = data;
          }
          if (list != null) {
            departments.value = list
                .whereType<Map<String, dynamic>>()
                .map((e) => ComplaintDepartment.fromJson(e))
                .toList();
          }
        }
      }
    } catch (_) {
    } finally {
      isDeptLoading(false);
    }
  }

  // ── 2. Fetch Complaint Employees: GET /student/complaint-employees ──
  Future<void> fetchEmployees({int? departmentId, String? search}) async {
    try {
      isEmpLoading(true);
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return;

      final queryParams = <String, String>{
        'page': '1',
        'per_page': '100',
        if (departmentId != null && departmentId > 0) 'department_id': departmentId.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      };

      final uri = Uri.parse('$_baseUrl/student/complaint-employees').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && (decoded['status'] == 'success' || decoded['status'] == true || decoded['status'] == 200) && decoded['data'] != null) {
          final data = decoded['data'];
          List<dynamic>? list;
          if (data is Map<String, dynamic>) {
            list = data['employees'] as List<dynamic>? ?? data['data'] as List<dynamic>?;
          } else if (data is List) {
            list = data;
          }

          if (list != null) {
            employees.value = list
                .whereType<Map<String, dynamic>>()
                .map((e) => ComplaintEmployee.fromJson(e))
                .toList();
          }
        }
      }
    } catch (_) {
    } finally {
      isEmpLoading(false);
    }
  }

  // ── 3. Fetch Student's Complaints: GET /student/complaints ──
  Future<void> fetchComplaints({String? status}) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage.value = '';

      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        hasError(true);
        errorMessage.value = 'Please log in to view your complaints.';
        return;
      }

      final queryParams = <String, String>{
        'page': '1',
        'per_page': '100',
        if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') 'status': status,
      };

      final uri = Uri.parse('$_baseUrl/student/complaints').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && (decoded['status'] == 'success' || decoded['status'] == true || decoded['status'] == 200) && decoded['data'] != null) {
          final data = decoded['data'];
          List<dynamic>? list;
          if (data is Map<String, dynamic>) {
            list = data['complaints'] as List<dynamic>? ?? data['data'] as List<dynamic>?;
          } else if (data is List) {
            list = data;
          }

          if (list != null) {
            complaintsList.value = list
                .whereType<Map<String, dynamic>>()
                .map((e) => ComplaintItem.fromJson(e))
                .toList();
          }
        }
      } else if (res.statusCode == 401) {
        hasError(true);
        errorMessage.value = 'Session expired. Please log in again.';
      } else {
        hasError(true);
        errorMessage.value = 'Failed to load complaints (${res.statusCode}).';
      }
    } catch (e) {
      hasError(true);
      errorMessage.value = 'Server connection error. Please check your internet connection.';
    } finally {
      isLoading(false);
    }
  }

  // ── 4. Fetch Single Complaint Detail: GET /student/complaints/{id} ──
  Future<ComplaintItem?> fetchComplaintDetail(int id) async {
    if (id <= 0) return null;
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return null;

      final uri = Uri.parse('$_baseUrl/student/complaints/$id');
      final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'];
          ComplaintItem? item;
          if (data is Map<String, dynamic> && data['complaint'] != null) {
            item = ComplaintItem.fromJson(data['complaint']);
          } else if (data is Map<String, dynamic>) {
            item = ComplaintItem.fromJson(data);
          }

          if (item != null) {
            final idx = complaintsList.indexWhere((c) => c.id == id);
            if (idx != -1) {
              complaintsList[idx] = item;
            }
            return item;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ── 4. Submit Complaint: POST /student/complaints ──
  Future<ComplaintItem?> submitComplaint({
    required String againstType, // "department" or "employee"
    int? departmentId,
    int? employeeId,
    required String subject,
    required String details,
    String priority = 'normal', // "low", "normal", "high"
    String? contactPhone,
  }) async {
    try {
      isSubmitting(true);
      final token = await _ensureToken();

      if (token == null || token.isEmpty) {
        Get.snackbar('Authentication Error', 'Please log in again to submit your complaint.');
        return null;
      }

      final Map<String, dynamic> payload = {
        'against_type': againstType.toLowerCase().trim(),
        'subject': subject.trim(),
        'details': details.trim(),
        'priority': priority.toLowerCase().trim(),
      };

      if (againstType.toLowerCase().trim() == 'department' && departmentId != null && departmentId > 0) {
        payload['department_id'] = departmentId;
      } else if (againstType.toLowerCase().trim() == 'employee' && employeeId != null && employeeId > 0) {
        payload['employee_id'] = employeeId;
      }

      if (contactPhone != null && contactPhone.trim().isNotEmpty) {
        payload['contact_phone'] = contactPhone.trim();
        payload['phone'] = contactPhone.trim();
      }

      final uri = Uri.parse('$_baseUrl/student/complaints');
      final res = await http
          .post(uri, headers: _getHeaders(token), body: json.encode(payload))
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded != null && (decoded['status'] == 'success' || decoded['status'] == true)) {
          final data = decoded['data'];
          ComplaintItem created;
          if (data is Map<String, dynamic> && data['complaint'] != null) {
            created = ComplaintItem.fromJson(data['complaint']);
          } else if (data is Map<String, dynamic>) {
            created = ComplaintItem.fromJson(data);
          } else {
            created = ComplaintItem(
              id: DateTime.now().millisecondsSinceEpoch,
              complaintNo: 'CMP-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch % 100000}',
              againstType: againstType,
              subject: subject,
              details: details,
              priority: priority,
              priorityLabel: priority.capitalizeFirst ?? 'Normal',
              status: 'submitted',
              statusLabel: 'Submitted',
              submittedAt: DateTime.now().toString().substring(0, 19),
            );
          }

          // Insert into list at top
          complaintsList.insert(0, created);
          return created;
        }
      } else {
        final decoded = json.decode(res.body);
        final msg = decoded?['message']?.toString() ?? 'Submission failed (${res.statusCode})';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
      }
      return null;
    } catch (e) {
      Get.snackbar('Connection Error', 'Could not connect to server. Please check your internet connection.');
      return null;
    } finally {
      isSubmitting(false);
    }
  }
}
