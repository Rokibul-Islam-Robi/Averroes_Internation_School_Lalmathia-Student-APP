import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS — mapped exactly to "Transport Mobile API Developer Instruction" PDF
// ════════════════════════════════════════════════════════════════════════════

class DriverUser {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String? phone;
  final String? photoUrl;

  DriverUser({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.phone,
    this.photoUrl,
  });

  factory DriverUser.fromJson(Map<String, dynamic> json) {
    return DriverUser(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      photoUrl: json['photo_url']?.toString() ?? json['photo']?.toString() ?? json['avatar']?.toString() ?? json['image']?.toString(),
    );
  }
}

class DriverBus {
  final int id;
  final String busName;
  final String vehicleNo;
  final int? driverUserId;
  final String status;

  DriverBus({
    required this.id,
    required this.busName,
    required this.vehicleNo,
    this.driverUserId,
    required this.status,
  });

  factory DriverBus.fromJson(Map<String, dynamic> json) {
    return DriverBus(
      id: int.tryParse(json['id'].toString()) ?? 0,
      busName: json['bus_name']?.toString() ?? '',
      vehicleNo: json['vehicle_no']?.toString() ?? '',
      driverUserId: json['driver_user_id'] != null
          ? int.tryParse(json['driver_user_id'].toString())
          : null,
      status: json['status']?.toString() ?? '',
    );
  }
}

class DriverActiveTrip {
  final int id;
  final int busId;
  final String status;
  final String? tripType;
  // ── PDF sample response এ started_at নেই, কিন্তু backend future-এ এই
  // key গুলোর যেকোনো একটা দিলে সেটাই ধরা হবে (leniently parsed) — না দিলে
  // controller নিজে trip-start সফল হওয়ার মুহূর্তে local fallback রাখে ──
  final DateTime? startedAt;

  DriverActiveTrip({
    required this.id,
    required this.busId,
    required this.status,
    this.tripType,
    this.startedAt,
  });

  factory DriverActiveTrip.fromJson(Map<String, dynamic> json) {
    DateTime? parsedStart;
    for (final key in ['started_at', 'start_time', 'trip_start_time', 'created_at']) {
      final raw = json[key]?.toString();
      if (raw != null && raw.isNotEmpty) {
        parsedStart = DateTime.tryParse(raw);
        if (parsedStart != null) break;
      }
    }
    return DriverActiveTrip(
      id: int.tryParse(json['id'].toString()) ?? 0,
      busId: int.tryParse(json['bus_id'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      tripType: json['trip_type']?.toString(),
      startedAt: parsedStart,
    );
  }
}

class OnboardedStudent {
  final int? logId;
  final String studentUid;
  final String studentName;
  final String? onboardedAt;
  final String? studentId;
  final String? className;
  final String? boardingLocation;
  final String? droppedAt;
  final String? dropLocation;
  final String? exitStatus;
  final String? seatNo;

  OnboardedStudent({
    this.logId,
    required this.studentUid,
    required this.studentName,
    this.onboardedAt,
    this.studentId,
    this.className,
    this.boardingLocation,
    this.droppedAt,
    this.dropLocation,
    this.exitStatus,
    this.seatNo,
  });

  factory OnboardedStudent.fromJson(Map<String, dynamic> json) {
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      return null;
    }

    // enrollment.class_name (nested, like busscan) fallback
    String? nestedClass;
    final enrollment = json['enrollment'];
    if (enrollment is Map) {
      nestedClass = enrollment['class_name']?.toString();
    }

    final rawLogId = json['log_id'] ?? json['onboard_log_id'] ?? json['id'];

    return OnboardedStudent(
      logId: rawLogId != null ? int.tryParse(rawLogId.toString()) : null,
      studentUid: json['student_uid']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      onboardedAt: pick(['onboarded_at', 'boarded_at', 'time']),
      studentId: pick(['student_id', 'id']),
      className: pick(['class_name', 'class', 'class_section']) ?? nestedClass,
      boardingLocation: pick(['boarding_location', 'pickup_location', 'location']),
      droppedAt: pick(['dropped_at', 'exit_time', 'off_at']),
      dropLocation: pick(['drop_location', 'exit_location']),
      exitStatus: pick(['exit_status', 'status']),
      seatNo: pick(['seat_no', 'seat', 'seat_number', 'seat_name', 'seat_id']),
    );
  }
}

// ── Trip History row (matches the admin "Transport Trip History" web page:
// SL, Date/Time, Bus, Driver, Trip Type, Status, Students, Action) ─────────
class DriverTripHistoryItem {
  final int id;
  final String busName;
  final String vehicleNo;
  final String driverName;
  final String tripType;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int studentsCount;

  DriverTripHistoryItem({
    required this.id,
    required this.busName,
    required this.vehicleNo,
    required this.driverName,
    required this.tripType,
    required this.status,
    this.startedAt,
    this.endedAt,
    required this.studentsCount,
  });

  Duration? get duration =>
      (startedAt != null && endedAt != null) ? endedAt!.difference(startedAt!) : null;

  factory DriverTripHistoryItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(List<String> keys) {
      for (final k in keys) {
        final raw = json[k]?.toString();
        if (raw != null && raw.isNotEmpty) {
          final d = DateTime.tryParse(raw);
          if (d != null) return d;
        }
      }
      return null;
    }

    return DriverTripHistoryItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      busName: json['bus_name']?.toString() ?? '',
      vehicleNo: json['vehicle_no']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      tripType: json['trip_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startedAt: parseDate(['started_at', 'start_time']),
      endedAt: parseDate(['ended_at', 'end_time']),
      studentsCount: int.tryParse((json['students_count'] ?? json['students'] ?? 0).toString()) ?? 0,
    );
  }
}

class ScannedStudentEnrollment {
  final String sessionName;
  final String className;

  ScannedStudentEnrollment({required this.sessionName, required this.className});

  factory ScannedStudentEnrollment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ScannedStudentEnrollment(sessionName: '', className: '');
    return ScannedStudentEnrollment(
      sessionName: json['session_name']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
    );
  }
}

class ScannedStudentBusAssignment {
  final int? busId;
  final String busName;
  final String vehicleNo;

  ScannedStudentBusAssignment({this.busId, required this.busName, required this.vehicleNo});

  factory ScannedStudentBusAssignment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ScannedStudentBusAssignment(busName: '', vehicleNo: '');
    }
    return ScannedStudentBusAssignment(
      busId: json['bus_id'] != null ? int.tryParse(json['bus_id'].toString()) : null,
      busName: json['bus_name']?.toString() ?? '',
      vehicleNo: json['vehicle_no']?.toString() ?? '',
    );
  }
}

class ScannedStudent {
  final int studentId;
  final String studentUid;
  final String studentName;
  final String? photoUrl;
  final String? guardianPhone;
  final String status;
  final bool isActive;
  final ScannedStudentEnrollment enrollment;
  final ScannedStudentBusAssignment busAssignment;

  ScannedStudent({
    required this.studentId,
    required this.studentUid,
    required this.studentName,
    this.photoUrl,
    this.guardianPhone,
    required this.status,
    required this.isActive,
    required this.enrollment,
    required this.busAssignment,
  });

  factory ScannedStudent.fromJson(Map<String, dynamic> json) {
    return ScannedStudent(
      studentId: int.tryParse(json['student_id'].toString()) ?? 0,
      studentUid: json['student_uid']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
      guardianPhone: json['guardian_phone']?.toString(),
      status: json['status']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active']?.toString() == 'true',
      enrollment: ScannedStudentEnrollment.fromJson(json['enrollment']),
      busAssignment: ScannedStudentBusAssignment.fromJson(json['bus_assignment']),
    );
  }
}

class BusScanResult {
  final ScannedStudent student;
  final DriverActiveTrip? activeTrip;
  final bool alreadyOnboarded;
  final bool canOnboard;
  final String? warning;

  BusScanResult({
    required this.student,
    this.activeTrip,
    required this.alreadyOnboarded,
    required this.canOnboard,
    this.warning,
  });

  factory BusScanResult.fromJson(Map<String, dynamic> json) {
    return BusScanResult(
      student: ScannedStudent.fromJson(json['student']),
      activeTrip: json['active_trip'] != null
          ? DriverActiveTrip.fromJson(json['active_trip'])
          : null,
      alreadyOnboarded: json['already_onboarded'] == true,
      canOnboard: json['can_onboard'] == true,
      warning: json['warning']?.toString(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ════════════════════════════════════════════════════════════════════════════
class DriverController extends GetxController {
  // ── Base API config (exact paths from the Developer Instruction PDF) ────────
  static const String _baseUrl =
      'https://averroesint.com/averroes_school_erp/api/v1/transport';

  String? _authToken;
  String? get authToken => _authToken;
  bool get isLoggedIn => _authToken != null && _authToken!.isNotEmpty;

  // ── login.dart এখান থেকে সরাসরি token বসাতে পারে (real API token হোক,
  // বা backend রেডি না থাকলে local session token) — student-side controller
  // গুলোর setAuthToken() এর সাথে consistent রাখা হলো, কোনো demo/mock data নেই ──
  void setAuthToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ── Auth state ───────────────────────────────────────────────────────────
  var isLoggingIn = false.obs;
  Rx<DriverUser?> driverUser = Rx<DriverUser?>(null);

  // ── Dashboard state ──────────────────────────────────────────────────────
  var dashboardLoading = false.obs;
  var dashboardHasError = false.obs;
  var dashboardErrorMessage = ''.obs;
  var buses = <DriverBus>[].obs;
  Rx<DriverActiveTrip?> activeTrip = Rx<DriverActiveTrip?>(null);
  var onboardedCount = 0.obs;
  var onboardedStudents = <OnboardedStudent>[].obs;

  // ── Trip start/end state ─────────────────────────────────────────────────
  var tripActionLoading = false.obs;

  // ── Live trip duration ticker (updates every second while a trip is
  // running, so the dashboard can show "Started At" + a live duration
  // without polling the server). Falls back to a locally-recorded start
  // time if the backend doesn't return one yet ──────────────────────────
  Timer? _tripTickTimer;
  DateTime? _localTripStartTime;
  var tripElapsedSeconds = 0.obs;

  DateTime? get effectiveTripStartTime => activeTrip.value?.startedAt ?? _localTripStartTime;

  void _startTripTicker() {
    _tripTickTimer?.cancel();
    _updateElapsed();
    _tripTickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateElapsed());
  }

  void _updateElapsed() {
    final start = effectiveTripStartTime;
    tripElapsedSeconds.value =
    start == null ? 0 : DateTime.now().difference(start).inSeconds.clamp(0, 999999);
  }

  void _stopTripTicker() {
    _tripTickTimer?.cancel();
    _tripTickTimer = null;
    tripElapsedSeconds.value = 0;
  }

  // ── Trip History state (Trip History page filters + list) ───────────────
  var tripHistoryLoading = false.obs;
  var tripHistoryHasError = false.obs;
  var tripHistoryErrorMessage = ''.obs;
  var tripHistory = <DriverTripHistoryItem>[].obs;

  // ── Live location (send-side, every 10s while trip running) ─────────────
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStreamSub;
  static const Duration _locationInterval = Duration(seconds: 10);
  var isSendingLocation = false.obs;
  var lastLocationSentAt = Rx<DateTime?>(null);
  var locationErrorMessage = ''.obs;

  // ── QR scan / onboard state ──────────────────────────────────────────────
  var scanLoading = false.obs;
  var scanErrorMessage = ''.obs;
  Rx<BusScanResult?> scanResult = Rx<BusScanResult?>(null);
  var onboardLoading = false.obs;

  @override
  void onClose() {
    _positionStreamSub?.cancel();
    _locationTimer?.cancel();
    _tripTickTimer?.cancel();
    super.onClose();
  }

  // ────────────────────────────────────────────────────────────────────────
  // helper: safe POST/GET wrapper returning decoded json or null on failure
  // ────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> _post(String path, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await http
          .post(
        uri,
        headers: withAuth
            ? _headers
            : {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      )
          .timeout(const Duration(seconds: 15));
      final decoded = json.decode(response.body);
      decoded['_statusCode'] = response.statusCode;
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server. Please check your internet connection.', '_statusCode': 0};
    }
  }

  Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      final decoded = json.decode(response.body);
      decoded['_statusCode'] = response.statusCode;
      return decoded;
    } catch (e) {
      return {'success': false, 'message': 'Could not connect to server. Please check your internet connection.', '_statusCode': 0};
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 1. LOGIN — POST /login.php  (no auth required)
  // ────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
    String deviceName = 'Driver Android App',
  }) async {
    isLoggingIn(true);
    try {
      final decoded = await _post(
        '/login.php',
        {
          'login': login,
          'password': password,
          'device_name': deviceName,
        },
        withAuth: false,
      );

      if (decoded == null) {
        return {'success': false, 'message': 'Unexpected error. Please try again.'};
      }

      if (decoded['success'] == true && decoded['data'] != null) {
        final data = decoded['data'];
        _authToken = data['access_token']?.toString();
        if (data['user'] != null) {
          driverUser.value = DriverUser.fromJson(data['user']);
        }
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': decoded['message']?.toString() ?? 'Login failed. Please check your credentials.',
        };
      }
    } finally {
      isLoggingIn(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 2. LOGOUT — POST /logout.php
  // ────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _post('/logout.php', {});
    } catch (_) {
      // ignore network errors on logout, clear local state regardless
    }
    stopLocationUpdates();
    _authToken = null;
    driverUser.value = null;
    buses.clear();
    activeTrip.value = null;
    onboardedCount.value = 0;
    onboardedStudents.clear();
    scanResult.value = null;
  }

  // ────────────────────────────────────────────────────────────────────────
  // 3. DRIVER DASHBOARD — GET /driver-dashboard.php
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchDashboard() async {
    try {
      dashboardLoading(true);
      dashboardHasError(false);

      final decoded = await _get('/driver-dashboard.php');
      if (decoded == null) {
        dashboardHasError(true);
        dashboardErrorMessage.value = 'Unexpected error. Please try again.';
        return;
      }

      if (decoded['success'] == true && decoded['data'] != null) {
        final data = decoded['data'];
        final List busesRaw = data['buses'] ?? [];
        buses.value = busesRaw.map((e) => DriverBus.fromJson(e)).toList();
        activeTrip.value = data['active_trip'] != null
            ? DriverActiveTrip.fromJson(data['active_trip'])
            : null;
        onboardedCount.value = int.tryParse(data['onboarded_count'].toString()) ?? 0;
        final List studentsRaw = data['onboarded_students'] ?? [];
        onboardedStudents.value = studentsRaw.map((e) => OnboardedStudent.fromJson(e)).toList();

        // If a trip is already running (e.g. app was reopened), resume sending
        // live location automatically so tracking never silently stops.
        if (activeTrip.value != null && activeTrip.value!.status == 'running') {
          if (!isSendingLocation.value) {
            startLocationUpdates(activeTrip.value!.id);
          }
          _startTripTicker();
        } else {
          _stopTripTicker();
          _localTripStartTime = null;
        }
      } else if (decoded['_statusCode'] == 401) {
        dashboardHasError(true);
        dashboardErrorMessage.value = 'Session expired. Please log in again.';
      } else {
        dashboardHasError(true);
        dashboardErrorMessage.value = decoded['message']?.toString() ?? 'Failed to load dashboard.';
      }
    } finally {
      dashboardLoading(false);
    }
  }

  Future<void> refreshDashboard() async => fetchDashboard();

  // ────────────────────────────────────────────────────────────────────────
  // helper: get current device position (used by trip-start/end, onboard,
  // and the live location ticker)
  // ────────────────────────────────────────────────────────────────────────
  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 4. START TRIP — POST /trip-start.php
  // ────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> startTrip({
    required int busId,
    required String tripType, // morning | afternoon | other
  }) async {
    tripActionLoading(true);
    try {
      final position = await _getCurrentPosition();
      final decoded = await _post('/trip-start.php', {
        'bus_id': busId,
        'trip_type': tripType,
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lng': position.longitude,
        if (position != null) 'accuracy': position.accuracy,
      });

      if (decoded == null) {
        return {'success': false, 'message': 'Unexpected error. Please try again.'};
      }

      if (decoded['success'] == true) {
        // Backend sample response has no started_at yet — record it locally
        // the instant the trip actually starts, so "Started At" / live
        // duration is real and correct even before the backend adds it.
        _localTripStartTime = DateTime.now();
        await fetchDashboard();
        if (activeTrip.value != null) {
          startLocationUpdates(activeTrip.value!.id);
        }
        _startTripTicker();
        return {'success': true};
      }
      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Failed to start trip.',
      };
    } finally {
      tripActionLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 5. END TRIP — POST /trip-end.php (Section 8)
  // ────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> endTrip() async {
    final trip = activeTrip.value;
    if (trip == null) {
      return {'success': false, 'message': 'No running trip found.'};
    }
    tripActionLoading(true);
    try {
      final startedAt = effectiveTripStartTime; // capture before it's cleared
      final position = await _getCurrentPosition();
      final decoded = await _post('/trip-end.php', {
        'trip_id': trip.id,
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lng': position.longitude,
        if (position != null) 'accuracy': position.accuracy,
      });

      if (decoded == null) {
        return {'success': false, 'message': 'Unexpected error. Please try again.'};
      }

      if (decoded['success'] == true) {
        stopLocationUpdates();
        _stopTripTicker();
        _localTripStartTime = null;
        final duration = startedAt != null ? DateTime.now().difference(startedAt) : null;
        await fetchDashboard();
        return {'success': true, 'duration': duration};
      }

      final pendingCount = (decoded['data'] is Map) ? decoded['data']['pending_exit_count'] : null;
      if (pendingCount != null) {
        return {
          'success': false,
          'message': 'All onboarded students must exit before ending the trip ($pendingCount students remaining).',
          'pending_exit_count': pendingCount,
        };
      }

      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Failed to end trip.',
      };
    } finally {
      tripActionLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 6. LIVE LOCATION UPDATE — POST /location-update.php every 10 seconds
  //    while a trip is running (per PDF section 4 & 8)
  // ────────────────────────────────────────────────────────────────────────
  void startLocationUpdates(int tripId) {
    if (isSendingLocation.value) return;
    isSendingLocation(true);
    _sendLocationOnce(tripId); // send immediately

    try {
      final AndroidSettings androidSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: _locationInterval,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: '🚌 AIS Bus Trip Active',
          notificationText: 'Bus Trip is Active - Live GPS tracking running...',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );

      _positionStreamSub?.cancel();
      _positionStreamSub = Geolocator.getPositionStream(
        locationSettings: androidSettings,
      ).listen(
        (position) {
          _postPosition(tripId, position);
        },
        onError: (err) {
          locationErrorMessage.value = 'GPS stream notice: $err';
        },
      );
    } catch (_) {
      // Fallback on systems without foreground notification support
    }

    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(_locationInterval, (_) {
      _sendLocationOnce(tripId);
    });
  }

  void stopLocationUpdates() {
    isSendingLocation(false);
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _postPosition(int tripId, Position position) async {
    final decoded = await _post('/location-update.php', {
      'trip_id': tripId,
      'lat': position.latitude,
      'lng': position.longitude,
      'accuracy': position.accuracy,
      'heading': position.heading,
      'speed': position.speed,
    });
    if (decoded != null && decoded['success'] == true) {
      lastLocationSentAt.value = DateTime.now();
      locationErrorMessage.value = '';
    } else if (decoded != null) {
      locationErrorMessage.value = decoded['message']?.toString() ?? 'Location update failed.';
    }
  }

  Future<void> _sendLocationOnce(int tripId) async {
    final position = await _getCurrentPosition();
    if (position == null) {
      locationErrorMessage.value = 'Location permission/service unavailable.';
      return;
    }
    await _postPosition(tripId, position);
  }

  // ────────────────────────────────────────────────────────────────────────
  // 7. BUS SCAN — GET /busscan.php?student_uid=XXXX
  //    QR on the student ID opens a URL like:
  //    .../admin/transport/bus-scan.php?student_uid=2024236
  //    The app must scan the QR and extract just the student_uid param.
  // ────────────────────────────────────────────────────────────────────────
  String? extractStudentUid(String qrRawValue) {
    final raw = qrRawValue.trim();
    if (raw.isEmpty) return null;

    // ── কেস ১: QR একটা URL, student_uid query parameter হিসেবে আছে ──────────
    // (query key case-insensitive ভাবে চেক করা হচ্ছে, যাতে student_uid /
    // Student_UID / STUDENT_UID সব ফরম্যাটেই কাজ করে — আগের কোডে শুধু
    // exact-case 'student_uid' চেক করত বলে অনেক real QR এখানে ম্যাচ করত না)
    try {
      final uri = Uri.parse(raw);
      if (uri.queryParameters.isNotEmpty) {
        for (final entry in uri.queryParameters.entries) {
          if (entry.key.toLowerCase() == 'student_uid' && entry.value.isNotEmpty) {
            return entry.value.trim();
          }
        }
      }
    } catch (_) {
      // not a valid URL — fall through
    }

    // ── কেস ২: QR একটা JSON payload, যেমন {"student_uid":"12345"} ──────────
    if (raw.startsWith('{') && raw.endsWith('}')) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) {
          for (final key in decoded.keys) {
            if (key.toString().toLowerCase() == 'student_uid') {
              final value = decoded[key]?.toString().trim();
              if (value != null && value.isNotEmpty) return value;
            }
          }
        }
      } catch (_) {
        // not valid JSON — fall through
      }
    }

    // ── কেস ৩: QR-এ শুধু raw student_uid টা-ই আছে (কোনো URL/JSON wrapper ছাড়া) ──
    if (!raw.contains('http') && !raw.contains('{')) {
      return raw;
    }

    return null;
  }

  Future<void> scanStudent(String studentUid) async {
    scanLoading(true);
    scanErrorMessage.value = '';
    scanResult.value = null;
    try {
      // ── Integration Guide (Section 7): GET /bus-scan.php?student_uid=... (fallback: /busscan.php) ──
      Map<String, dynamic>? decoded = await _get('/bus-scan.php?student_uid=${Uri.encodeQueryComponent(studentUid)}');
      if (decoded == null || (decoded['success'] != true && decoded['_statusCode'] == 404)) {
        decoded = await _get('/busscan.php?student_uid=${Uri.encodeQueryComponent(studentUid)}');
      }

      if (decoded == null) {
        scanErrorMessage.value = 'Unexpected error. Please try again.';
        return;
      }
      if (decoded['success'] == true && decoded['data'] != null) {
        scanResult.value = BusScanResult.fromJson(decoded['data']);
      } else {
        scanErrorMessage.value = decoded['message']?.toString() ?? 'Could not verify student.';
      }
    } finally {
      scanLoading(false);
    }
  }

  void clearScanResult() {
    scanResult.value = null;
    scanErrorMessage.value = '';
  }

  // ────────────────────────────────────────────────────────────────────────
  // 8. ONBOARD STUDENT — POST /onboard.php (Section 7)
  // ────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> onboardStudent(String studentUid) async {
    onboardLoading(true);
    try {
      final position = await _getCurrentPosition();
      final decoded = await _post('/onboard.php', {
        'student_uid': studentUid,
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lng': position.longitude,
        if (position != null) 'accuracy': position.accuracy,
      });

      if (decoded == null) {
        return {'success': false, 'message': 'Unexpected error. Please try again.'};
      }

      if (decoded['success'] == true) {
        // refresh dashboard + onboarded list so counts/lists stay in sync
        await fetchDashboard();
        await fetchOnboardList();
        return {
          'success': true,
          'message': decoded['message']?.toString() ?? 'Student onboarded successfully.',
        };
      }
      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Failed to onboard student.',
      };
    } finally {
      onboardLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 9. STUDENT EXIT — POST /student-exit.php (Section 7)
  // ────────────────────────────────────────────────────────────────────────
  var exitLoading = false.obs;

  Future<Map<String, dynamic>> recordStudentExit({
    int? logId,
    String? studentUid,
    int? tripId,
  }) async {
    exitLoading(true);
    try {
      final active = activeTrip.value;
      final tId = tripId ?? active?.id;
      final position = await _getCurrentPosition();

      final body = <String, dynamic>{
        if (logId != null && logId > 0) 'log_id': logId,
        if (studentUid != null && studentUid.isNotEmpty) 'student_uid': studentUid,
        if (tId != null && tId > 0) 'trip_id': tId,
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lng': position.longitude,
        if (position != null) 'accuracy': position.accuracy,
      };

      final decoded = await _post('/student-exit.php', body);
      if (decoded == null) {
        return {'success': false, 'message': 'Unexpected error. Please try again.'};
      }

      if (decoded['success'] == true) {
        await fetchDashboard();
        await fetchOnboardList();
        return {
          'success': true,
          'message': decoded['message']?.toString() ?? 'Student exit recorded successfully.',
        };
      }

      return {
        'success': false,
        'message': decoded['message']?.toString() ?? 'Failed to record student exit.',
      };
    } finally {
      exitLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 10. ONBOARDED LIST — GET /onboard-list.php (optionally ?trip_id=)
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchOnboardList({int? tripId}) async {
    try {
      final path = tripId != null ? '/onboard-list.php?trip_id=$tripId' : '/onboard-list.php';
      final decoded = await _get(path);
      if (decoded != null && decoded['success'] == true && decoded['data'] != null) {
        final List rows = decoded['data'] is List
            ? decoded['data']
            : (decoded['data']['onboarded_students'] ?? decoded['data']['students'] ?? []);
        onboardedStudents.value = rows.map((e) => OnboardedStudent.fromJson(e)).toList();
        onboardedCount.value = onboardedStudents.length;
      }
    } catch (_) {
      // silent — dashboard refresh already surfaces onboarded state
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 10. TRIP HISTORY — GET /trip-history.php (from, to, bus_id, status)
  //
  // NOTE: এই endpoint টা "Transport Mobile API Developer Instruction" PDF-এ
  // এখনো লেখা নেই (PDF only covers login → onboard-list). এটা backend-এর
  // admin "Transport Trip History" web page-এর মতোই একটা list, তাই একই
  // naming convention মেনে /trip-history.php ধরে কল করা হচ্ছে। Backend এ
  // এখনো যোগ করা না থাকলে এই কল fail করবে — তখন dashboard-এর মতোই real
  // error message (fake data নয়) ইনলাইন দেখানো হবে এবং Retry বাটন থাকবে।
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchTripHistory({
    DateTime? from,
    DateTime? to,
    int? busId,
    String? status, // completed | running | all
  }) async {
    tripHistoryLoading(true);
    tripHistoryHasError(false);
    try {
      final params = <String, String>{};
      if (from != null) params['from'] = _ymd(from);
      if (to != null) params['to'] = _ymd(to);
      if (busId != null) params['bus_id'] = '$busId';
      if (status != null && status != 'all') params['status'] = status;
      final query = params.isEmpty
          ? ''
          : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

      final decoded = await _get('/trip-history.php$query');
      if (decoded == null) {
        tripHistoryHasError(true);
        tripHistoryErrorMessage.value = 'Unexpected error. Please try again.';
        return;
      }
      if (decoded['success'] == true && decoded['data'] != null) {
        final List rows = decoded['data'] is List
            ? decoded['data']
            : (decoded['data']['trips'] ?? []);
        tripHistory.value = rows.map((e) => DriverTripHistoryItem.fromJson(e)).toList();
      } else {
        tripHistoryHasError(true);
        tripHistoryErrorMessage.value =
            decoded['message']?.toString() ?? 'Failed to load trip history.';
      }
    } finally {
      tripHistoryLoading(false);
    }
  }

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
