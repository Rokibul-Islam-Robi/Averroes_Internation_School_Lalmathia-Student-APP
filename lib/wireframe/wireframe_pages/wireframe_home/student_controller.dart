import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODEL — Student Profile
// Matched to Student Profile API v1.0 (23 Aug 2026)
// Endpoints: GET /student/profile, POST /student/profile/photo
// ════════════════════════════════════════════════════════════════════════════

String _extractName(dynamic val, [String fallback = '']) {
  if (val == null) return fallback;
  if (val is String) return val.trim();
  if (val is Map) {
    return val['name']?.toString() ??
        val['title']?.toString() ??
        val['class_name']?.toString() ??
        val['section_name']?.toString() ??
        val['session_name']?.toString() ??
        fallback;
  }
  return val.toString();
}

class StudentGuardian {
  final String relation;
  final String name;
  final String phone;
  final String? email;
  final String? occupation;
  final bool isPrimary;

  StudentGuardian({
    required this.relation,
    required this.name,
    required this.phone,
    this.email,
    this.occupation,
    required this.isPrimary,
  });

  factory StudentGuardian.fromJson(Map<String, dynamic> json) {
    return StudentGuardian(
      relation: json['relation']?.toString() ?? '',
      name: _extractName(json['name'] ?? json['guardian_name']),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      occupation: json['occupation']?.toString(),
      isPrimary: json['is_primary'] == true || json['is_primary']?.toString() == '1',
    );
  }
}

class StudentProfile {
  // Identity
  final String studentName;
  final String studentId;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String nationality;
  final String religion;
  final String status;
  final String joiningDate;
  final String profilePhotoUrl;

  // Account / contact
  final String accountUsername;
  final String accountEmail;
  final String accountPhone;
  final String contactNumber;

  // Address
  final String presentAddress;
  final String permanentAddress;

  // Enrollment
  final String className;
  final String section;
  final String rollNo;
  final String academicYear;

  // Branch
  final String branchName;
  final String branchAddress;

  // Transport
  final String transportFacility;
  final String transportLocation;

  // Guardians
  final List<StudentGuardian> guardians;

  StudentProfile({
    required this.studentName,
    required this.studentId,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.nationality,
    required this.religion,
    required this.status,
    required this.joiningDate,
    required this.profilePhotoUrl,
    required this.accountUsername,
    required this.accountEmail,
    required this.accountPhone,
    required this.contactNumber,
    required this.presentAddress,
    required this.permanentAddress,
    required this.className,
    required this.section,
    required this.rollNo,
    required this.academicYear,
    required this.branchName,
    required this.branchAddress,
    required this.transportFacility,
    required this.transportLocation,
    required this.guardians,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>? ?? {};
    final contact = json['contact'] as Map<String, dynamic>? ?? {};
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final enrollment = json['enrollment'] as Map<String, dynamic>? ?? {};
    final branch = json['branch'] as Map<String, dynamic>? ?? {};
    final transport = json['transport'] as Map<String, dynamic>? ?? {};
    final rawGuardians = (json['guardians'] as List<dynamic>? ?? []);

    return StudentProfile(
      studentName: _extractName(json['student_name'] ?? json['name'] ?? json['student']),
      studentId: json['student_uid']?.toString() ?? json['student_id']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      nationality: json['nationality']?.toString() ?? '',
      religion: json['religion']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      joiningDate: json['joining_date']?.toString() ?? '',
      profilePhotoUrl: json['photo_url']?.toString() ?? json['profile_photo_url']?.toString() ?? '',
      accountUsername: account['username']?.toString() ?? '',
      accountEmail: account['email']?.toString() ?? '',
      accountPhone: account['phone']?.toString() ?? '',
      contactNumber: contact['sms_number']?.toString() ?? contact['phone']?.toString() ?? account['phone']?.toString() ?? '',
      presentAddress: address['present_address']?.toString() ?? '',
      permanentAddress: address['permanent_address']?.toString() ?? '',
      className: _extractName(enrollment['class'] ?? enrollment['class_name'] ?? json['class'] ?? json['class_name']),
      section: _extractName(enrollment['section'] ?? enrollment['section_name'] ?? json['section'] ?? json['section_name']),
      rollNo: enrollment['roll_no']?.toString() ?? json['roll_no']?.toString() ?? '',
      academicYear: _extractName(enrollment['session'] ?? enrollment['session_name'] ?? json['session'] ?? json['session_name'] ?? json['academic_year']),
      branchName: _extractName(branch['name'] ?? branch['branch_name'] ?? json['branch']),
      branchAddress: branch['address']?.toString() ?? '',
      transportFacility: transport['facility']?.toString() ?? transport['status']?.toString() ?? '',
      transportLocation: transport['location']?.toString() ?? transport['pickup_point']?.toString() ?? '',
      guardians: rawGuardians.map((g) => StudentGuardian.fromJson(g as Map<String, dynamic>)).toList(),
    );
  }

  StudentProfile copyWith({
    String? profilePhotoUrl,
    String? contactNumber,
  }) {
    return StudentProfile(
      studentName: studentName,
      studentId: studentId,
      dateOfBirth: dateOfBirth,
      gender: gender,
      bloodGroup: bloodGroup,
      nationality: nationality,
      religion: religion,
      status: status,
      joiningDate: joiningDate,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      accountUsername: accountUsername,
      accountEmail: accountEmail,
      accountPhone: accountPhone,
      contactNumber: contactNumber ?? this.contactNumber,
      presentAddress: presentAddress,
      permanentAddress: permanentAddress,
      className: className,
      section: section,
      rollNo: rollNo,
      academicYear: academicYear,
      branchName: branchName,
      branchAddress: branchAddress,
      transportFacility: transportFacility,
      transportLocation: transportLocation,
      guardians: guardians,
    );
  }

  String get currentAcademicSession {
    final now = DateTime.now();
    final currentYear = now.year;
    final fallbackSession = "$currentYear-${currentYear + 1}";
    final trimmed = academicYear.trim();
    if (trimmed.isEmpty) return fallbackSession;
    if (trimmed.contains('$currentYear') && trimmed.contains('${currentYear + 1}')) {
      return trimmed;
    }
    return fallbackSession;
  }
}

String resolveCurrentAcademicSession([String? rawSession]) {
  final now = DateTime.now();
  final currentYear = now.year;
  final fallbackSession = "$currentYear-${currentYear + 1}";

  if (rawSession != null && rawSession.trim().isNotEmpty) {
    final s = rawSession.trim();
    if (s.contains('$currentYear') && s.contains('${currentYear + 1}')) {
      return s;
    }
  }

  if (Get.isRegistered<StudentController>()) {
    final p = Get.find<StudentController>().profile.value;
    if (p != null && p.academicYear.isNotEmpty) {
      final ay = p.academicYear.trim();
      if (ay.contains('$currentYear') && ay.contains('${currentYear + 1}')) {
        return ay;
      }
    }
  }

  return fallbackSession; // "2026-2027"
}

String normalizeSectionWithSession(String sectionName, [String? fallbackSession]) {
  final session = resolveCurrentAcademicSession(fallbackSession);
  final trimmed = sectionName.trim();
  if (trimmed.isEmpty) return session;

  final updated = trimmed
      .replaceAll('2025-2026', session)
      .replaceAll('2024-2025', session)
      .replaceAll('2023-2024', session);

  if (updated.contains(session)) {
    return updated;
  }

  return '$updated / $session';
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — StudentController
// ════════════════════════════════════════════════════════════════════════════

class StudentController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _profileEndpoint = '/student/profile';
  static const String _updateContactEndpoint = '/student/profile/contact';
  static const String _uploadPhotoEndpoint = '/student/profile/photo';

  String? _authToken;
  void setAuthToken(String token) => _authToken = token;
  String? get authToken => _authToken;

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
  Rx<StudentProfile?> profile = Rx<StudentProfile?>(null);

  var isSavingContact = false.obs;
  var isUploadingPhoto = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        hasError(true);
        errorMessage.value = 'Please log in to view profile.';
        isLoading(false);
        return;
      }

      isLoading(true);
      hasError(false);
      isSessionExpired(false);

      final uri = Uri.parse('$_baseUrl$_profileEndpoint');
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
        if (rawData is Map<String, dynamic>) {
          final profileData = rawData['profile'] ?? rawData['student'] ?? rawData;
          if (profileData is Map) {
            profile.value = StudentProfile.fromJson(profileData.cast<String, dynamic>());
          }
        }
      } else {
        _handleErrorStatus(response.statusCode, decoded);
      }
    } catch (e) {
      _showError('Could not connect to server. Please check your internet connection.');
    } finally {
      isLoading(false);
    }
  }

  void _handleErrorStatus(int statusCode, Map<String, dynamic>? decoded) {
    final serverMessage = decoded?['message']?.toString();
    switch (statusCode) {
      case 401:
        _authToken = null;
        isSessionExpired(true);
        _showError(serverMessage ?? 'Session expired. Please log in again.');
        break;
      case 403:
        _showError(serverMessage ?? 'Your account does not have student access.');
        break;
      case 404:
        _showError(serverMessage ?? 'Student profile not found. Please contact support.');
        break;
      case 500:
        _showError(serverMessage ?? 'Something went wrong on the server. Please try again.');
        break;
      default:
        _showError(serverMessage ?? 'Failed to load profile ($statusCode).');
    }
  }

  Future<void> refreshProfile() async => fetchProfile();

  Future<bool> updateContactNumber(String newContact) async {
    if (newContact.trim().isEmpty) return false;

    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return false;

      isSavingContact(true);

      final uri = Uri.parse('$_baseUrl$_updateContactEndpoint');
      final response = await http
          .put(uri, headers: _getHeaders(token), body: json.encode({'contact_number': newContact}))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          if (profile.value != null) {
            profile.value = profile.value!.copyWith(contactNumber: newContact);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isSavingContact(false);
    }
  }

  Future<bool> pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return false;

      return await _uploadPhoto(File(picked.path));
    } catch (e) {
      return false;
    }
  }

  Future<bool> _uploadPhoto(File imageFile) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) return false;

      isUploadingPhoto(true);

      final uri = Uri.parse('$_baseUrl$_uploadPhotoEndpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final newPhotoUrl = decoded['data']['profile_photo_url']?.toString() ?? '';

          if (profile.value != null && newPhotoUrl.isNotEmpty) {
            final cacheBustedUrl =
                '$newPhotoUrl${newPhotoUrl.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch}';
            profile.value = profile.value!.copyWith(profilePhotoUrl: cacheBustedUrl);
          }
          return true;
        }
      } else if (response.statusCode == 401) {
        _authToken = null;
        isSessionExpired(true);
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isUploadingPhoto(false);
    }
  }

  void _showError(String message) {
    hasError(true);
    errorMessage.value = message;
  }

  Future<void> logout() async {
    try {
      final token = await _ensureToken();
      if (token != null && token.isNotEmpty) {
        final uri = Uri.parse('$_baseUrl/logout');
        await http.post(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 10));
      }
    } catch (_) {
    } finally {
      _authToken = null;
      profile.value = null;
      hasError(false);
      isSessionExpired(false);
    }
  }
}
