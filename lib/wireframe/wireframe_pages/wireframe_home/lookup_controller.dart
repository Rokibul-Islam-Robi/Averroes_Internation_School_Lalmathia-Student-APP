import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'routine_controller.dart';
import 'teachers_materials_controller.dart';
import 'student_controller.dart';

// =============================================================================
// MODELS — Lookups (Classes, Sections, Subjects, Sessions)
// =============================================================================

class SchoolClass {
  final String id;
  final String className;
  final String shift;

  SchoolClass({
    required this.id,
    required this.className,
    required this.shift,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? json['name']?.toString() ?? '',
      shift: json['shift']?.toString() ?? '',
    );
  }

  String get displayLabel => shift.isNotEmpty ? "$className ($shift)" : className;
}

class SchoolSection {
  final String id;
  final String classId;
  final String sectionName;
  final int capacity;

  SchoolSection({
    required this.id,
    required this.classId,
    required this.sectionName,
    required this.capacity,
  });

  factory SchoolSection.fromJson(Map<String, dynamic> json) {
    return SchoolSection(
      id: json['id']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      sectionName: json['section_name']?.toString() ?? json['name']?.toString() ?? '',
      capacity: int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
    );
  }

  String get displayLabel => sectionName;
}

class SchoolSubject {
  final String id;
  final String name;
  final String code;
  final String type;
  final bool isActive;

  SchoolSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.isActive,
  });

  factory SchoolSubject.fromJson(Map<String, dynamic> json) {
    return SchoolSubject(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['subject_name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isActive: json['status']?.toString().toLowerCase() != 'inactive',
    );
  }

  String get displayLabel => name;
}

class AcademicSession {
  final String id;
  final String sessionName;
  final bool isCurrent;

  AcademicSession({
    required this.id,
    required this.sessionName,
    required this.isCurrent,
  });

  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    final currentVal = json['is_current'];
    return AcademicSession(
      id: json['id']?.toString() ?? '',
      sessionName: json['session_name']?.toString() ?? json['name']?.toString() ?? '',
      isCurrent: currentVal == true || currentVal == 1 || currentVal?.toString() == '1',
    );
  }

  String get displayLabel => sessionName;
}

// =============================================================================
// CONTROLLER
// =============================================================================

class LookupController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _classesEndpoint = '/lookup/classes';
  static const String _sectionsEndpoint = '/lookup/sections';
  static const String _subjectsEndpoint = '/lookup/subjects';
  static const String _sessionsEndpoint = '/lookup/academic-sessions';

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

  // Reactive States
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final classes = <SchoolClass>[].obs;
  final sections = <SchoolSection>[].obs;
  final subjects = <SchoolSubject>[].obs;
  final sessions = <AcademicSession>[].obs;

  // Global Dropdown Selections
  final selectedClass = Rx<SchoolClass?>(null);
  final selectedSection = Rx<SchoolSection?>(null);
  final selectedSubject = Rx<SchoolSubject?>(null);
  final selectedSession = Rx<AcademicSession?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAllLookups();
  }

  Future<void> fetchAllLookups() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage.value = '';

      await Future.wait([
        _fetchClasses(),
        _fetchSections(),
        _fetchSubjects(),
        _fetchSessions(),
      ]);

      // Fallback: If subjects are empty from separate /lookup endpoint,
      // extract from real active student services or standard curriculum
      if (subjects.isEmpty) {
        _populateSubjectsFromActiveStudentData();
      }

      if (classes.isEmpty) {
        _populateClassesFromActiveStudentData();
      }

      if (sessions.isEmpty) {
        _populateSessionsFromActiveStudentData();
      }

      if (selectedSession.value == null && sessions.isNotEmpty) {
        selectedSession.value = sessions.firstWhere(
          (s) => s.isCurrent,
          orElse: () => sessions.first,
        );
      }
    } catch (e) {
      // Even if network fails, provide available cached/profile data
      _populateSubjectsFromActiveStudentData();
      _populateClassesFromActiveStudentData();
      _populateSessionsFromActiveStudentData();
    } finally {
      isLoading(false);
    }
  }

  void _populateSubjectsFromActiveStudentData() {
    final Map<String, SchoolSubject> extracted = {};

    // 1. Try extracting from live routine controller (real API data from /student/routine)
    try {
      if (Get.isRegistered<RoutineController>()) {
        final routineCtrl = Get.find<RoutineController>();
        final days = routineCtrl.days;
        for (final day in days) {
          for (final entry in day.entries) {
            final name = entry.subjectName.trim();
            if (name.isNotEmpty && TeachersMaterialsController.isValidSubject(name)) {
              extracted[name.toLowerCase()] = SchoolSubject(
                id: entry.id.isNotEmpty ? entry.id : name.toLowerCase(),
                name: name,
                code: name.length >= 3 ? name.substring(0, 3).toUpperCase() : 'SUB',
                type: 'Compulsory',
                isActive: true,
              );
            }
          }
        }
      }
    } catch (_) {}

    // 2. Try extracting from teachers materials (real API data from /student/teacher-materials/classes)
    try {
      if (Get.isRegistered<TeachersMaterialsController>()) {
        final tmCtrl = Get.find<TeachersMaterialsController>();
        for (final group in tmCtrl.classGroups) {
          final name = group.subjectName.trim();
          if (name.isNotEmpty && TeachersMaterialsController.isValidSubject(name)) {
            extracted[name.toLowerCase()] = SchoolSubject(
              id: group.id.isNotEmpty ? group.id : name.toLowerCase(),
              name: name,
              code: name.length >= 3 ? name.substring(0, 3).toUpperCase() : 'SUB',
              type: 'Theory',
              isActive: true,
            );
          }
        }
      }
    } catch (_) {}

    subjects.value = extracted.values.toList();
  }

  void _populateClassesFromActiveStudentData() {
    try {
      if (Get.isRegistered<StudentController>()) {
        final sc = Get.find<StudentController>();
        final realClass = sc.profile.value?.className;
        if (realClass != null && realClass.isNotEmpty) {
          classes.value = [
            SchoolClass(id: '1', className: realClass, shift: 'Morning'),
          ];
        }
      }
    } catch (_) {}
  }

  void _populateSessionsFromActiveStudentData() {
    String currentYear = resolveCurrentAcademicSession();
    try {
      if (Get.isRegistered<StudentController>()) {
        final sc = Get.find<StudentController>();
        if (sc.profile.value?.academicYear.isNotEmpty == true) {
          currentYear = resolveCurrentAcademicSession(sc.profile.value!.academicYear);
        }
      }
    } catch (_) {}

    sessions.value = [
      AcademicSession(id: '1', sessionName: currentYear, isCurrent: true),
    ];
  }

  Future<void> refreshAllLookups() async => fetchAllLookups();

  Future<bool> _fetchClasses() async => _performFetch(_classesEndpoint, (data) {
    classes.value = data.map((e) => SchoolClass.fromJson(e)).toList();
  });

  Future<bool> _fetchSections() async => _performFetch(_sectionsEndpoint, (data) {
    sections.value = data.map((e) => SchoolSection.fromJson(e)).toList();
  });

  Future<bool> _fetchSubjects() async => _performFetch(_subjectsEndpoint, (data) {
    subjects.value = data.map((e) => SchoolSubject.fromJson(e)).toList();
  });

  Future<bool> _fetchSessions() async => _performFetch(_sessionsEndpoint, (data) {
    sessions.value = data.map((e) => AcademicSession.fromJson(e)).toList();
  });

  Future<bool> _performFetch(String endpoint, Function(List) onSuccess) async {
    try {
      final token = await _ensureToken();
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null && decoded['data'] is List) {
          onSuccess(decoded['data'] as List);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  List<SchoolSection> sectionsForClass(String classId) {
    return sections.where((s) => s.classId == classId).toList();
  }

  Future<List<SchoolSubject>> fetchSubjectsForClassSection(String classId, String sectionId) async {
    try {
      final token = await _ensureToken();
      final uri = Uri.parse('$_baseUrl$_subjectsEndpoint?class_id=$classId&section_id=$sectionId');
      final response = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null && decoded['data'] is List) {
          final List rows = decoded['data'];
          return rows.map((e) => SchoolSubject.fromJson(e)).toList();
        }
      }
      return subjects;
    } catch (_) {
      return subjects;
    }
  }

  void selectClass(SchoolClass? value) {
    selectedClass.value = value;
    selectedSection.value = null;
  }

  void selectSection(SchoolSection? value) => selectedSection.value = value;
  void selectSubject(SchoolSubject? value) => selectedSubject.value = value;
  void selectSession(AcademicSession? value) => selectedSession.value = value;
}