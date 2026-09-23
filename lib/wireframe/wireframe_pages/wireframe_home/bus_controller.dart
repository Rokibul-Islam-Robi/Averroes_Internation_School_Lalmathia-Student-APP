import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODELS — Student Transport & Bus Tracking
// Matched to Averroes Mobile API Integration Guide (5 September 2026, Section 5)
// Endpoints:
//   - GET /transport/bus-schedule
//   - GET /transport/trip-history (alias: /transport/bus-log)
//   - GET /transport/live-location
// ════════════════════════════════════════════════════════════════════════════

class BusPoint {
  final String location;
  final String? time;

  BusPoint({required this.location, this.time});

  factory BusPoint.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BusPoint(location: '');
    return BusPoint(
      location: json['point']?.toString() ?? json['location']?.toString() ?? '',
      time: json['time']?.toString(),
    );
  }
}

class BusInfo {
  final int? id;
  final String busName;
  final String vehicleNo;
  final String? status;

  BusInfo({this.id, required this.busName, required this.vehicleNo, this.status});

  factory BusInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BusInfo(busName: '', vehicleNo: '');
    return BusInfo(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      busName: json['name']?.toString() ?? json['bus_name']?.toString() ?? '',
      vehicleNo: json['vehicle_no']?.toString() ?? '',
      status: json['status']?.toString(),
    );
  }
}

class BusDriverInfo {
  final int? userId;
  final String name;
  final String phone;

  BusDriverInfo({this.userId, required this.name, required this.phone});

  factory BusDriverInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BusDriverInfo(name: '', phone: '');
    return BusDriverInfo(
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class BusAssignment {
  final int? id;
  final String? status;
  final BusInfo bus;
  final BusDriverInfo? driver;
  final BusPoint pickup;
  final BusPoint drop;

  BusAssignment({
    this.id,
    this.status,
    required this.bus,
    this.driver,
    required this.pickup,
    required this.drop,
  });

  factory BusAssignment.fromJson(Map<String, dynamic> json) {
    return BusAssignment(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      status: json['status']?.toString(),
      bus: BusInfo.fromJson(json['bus'] as Map<String, dynamic>?),
      driver: json['driver'] != null ? BusDriverInfo.fromJson(json['driver'] as Map<String, dynamic>?) : null,
      pickup: BusPoint.fromJson(json['pickup'] as Map<String, dynamic>?),
      drop: BusPoint.fromJson(json['drop'] as Map<String, dynamic>?),
    );
  }
}

class BusStopInfo {
  final int stopOrder;
  final String stopName;
  final String pickupTime;
  final String dropTime;

  BusStopInfo({
    required this.stopOrder,
    required this.stopName,
    required this.pickupTime,
    required this.dropTime,
  });
}

class BusSchedule {
  final bool assigned;
  final BusAssignment? assignment;
  final bool scheduleTimesAvailable;
  final Map<String, dynamic>? activeTrip;
  final String? customDriverName;
  final String? customDriverPhone;
  final String? customHelperPhone;
  final String? customBusNumber;
  final String? customRouteName;

  BusSchedule({
    required this.assigned,
    required this.assignment,
    required this.scheduleTimesAvailable,
    this.activeTrip,
    this.customDriverName,
    this.customDriverPhone,
    this.customHelperPhone,
    this.customBusNumber,
    this.customRouteName,
  });

  String get routeName {
    if (customRouteName != null && customRouteName!.isNotEmpty) return customRouteName!;
    if (assignment != null) {
      if (assignment!.pickup.location.isNotEmpty && assignment!.drop.location.isNotEmpty) {
        return '${assignment!.pickup.location} - ${assignment!.drop.location}';
      } else if (assignment!.pickup.location.isNotEmpty) {
        return assignment!.pickup.location;
      }
    }
    return assigned ? 'Assigned School Route' : 'No Bus Assigned';
  }

  String get busNumber {
    if (customBusNumber != null && customBusNumber!.isNotEmpty) return customBusNumber!;
    if (assignment != null && assignment!.bus.vehicleNo.isNotEmpty) {
      return assignment!.bus.vehicleNo;
    }
    if (assignment != null && assignment!.bus.busName.isNotEmpty) {
      return assignment!.bus.busName;
    }
    return '';
  }

  String get driverName {
    if (assignment?.driver?.name.isNotEmpty == true) return assignment!.driver!.name;
    if (customDriverName != null && customDriverName!.isNotEmpty) return customDriverName!;
    return 'School Bus Driver';
  }

  String get driverPhone {
    if (assignment?.driver?.phone.isNotEmpty == true) return assignment!.driver!.phone;
    return customDriverPhone ?? '';
  }

  String get helperPhone => customHelperPhone ?? '';

  List<BusStopInfo> get stops {
    final list = <BusStopInfo>[];
    if (assignment != null) {
      if (assignment!.pickup.location.isNotEmpty) {
        list.add(BusStopInfo(
          stopOrder: 1,
          stopName: assignment!.pickup.location,
          pickupTime: assignment!.pickup.time ?? '--:--',
          dropTime: '--:--',
        ));
      }
      if (assignment!.drop.location.isNotEmpty) {
        list.add(BusStopInfo(
          stopOrder: list.length + 1,
          stopName: assignment!.drop.location,
          pickupTime: '--:--',
          dropTime: assignment!.drop.time ?? '--:--',
        ));
      }
    }
    return list;
  }

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    final assignmentJson = json['assignment'] as Map<String, dynamic>?;
    final driverJson = json['driver'] as Map<String, dynamic>? ?? assignmentJson?['driver'] as Map<String, dynamic>?;
    final busJson = json['bus'] as Map<String, dynamic>? ?? assignmentJson?['bus'] as Map<String, dynamic>?;

    final isAssigned = json['assigned'] == true ||
        json['is_assigned'] == true ||
        assignmentJson != null ||
        (json['status']?.toString().toLowerCase() == 'assigned' || json['status']?.toString().toLowerCase() == 'active');

    return BusSchedule(
      assigned: isAssigned,
      assignment: assignmentJson != null ? BusAssignment.fromJson(assignmentJson) : null,
      scheduleTimesAvailable: json['schedule_times_available'] == true,
      activeTrip: json['active_trip'] as Map<String, dynamic>?,
      customDriverName: driverJson?['name']?.toString() ?? json['driver_name']?.toString(),
      customDriverPhone: driverJson?['phone']?.toString() ?? json['driver_phone']?.toString(),
      customHelperPhone: json['helper_phone']?.toString() ?? (json['helper'] is Map ? json['helper']['phone']?.toString() : null),
      customBusNumber: busJson?['vehicle_no']?.toString() ?? busJson?['bus_no']?.toString() ?? json['bus_no']?.toString(),
      customRouteName: json['route_name']?.toString() ?? json['route']?.toString(),
    );
  }
}

/// Matches Section 5 `GET /transport/trip-history` and backward-compatible `GET /transport/bus-log`
class BusLogEntry {
  final String id;
  final String date;
  final String type; // 'pickup' | 'drop' | 'morning' | 'afternoon'
  final String pointName;
  final String? time;
  final String status; // 'completed', 'onboarded', 'dropped', 'cancelled', 'missed'
  final String? eventStatus; // 'on_bus', 'completed', 'cancelled'
  final String? onboardAt;
  final String? exitAt;
  final String? busName;
  final String? vehicleNo;
  final String? driverName;
  final String? driverPhone;
  final String? recordedBy;

  BusLogEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.pointName,
    this.time,
    required this.status,
    this.eventStatus,
    this.onboardAt,
    this.exitAt,
    this.busName,
    this.vehicleNo,
    this.driverName,
    this.driverPhone,
    this.recordedBy,
  });

  String? get entryTime {
    if (onboardAt != null && onboardAt!.isNotEmpty) {
      return _extractTime(onboardAt!);
    }
    if (type.toLowerCase() == 'pickup') return time;
    return null;
  }

  String? get exitTime {
    if (exitAt != null && exitAt!.isNotEmpty) {
      return _extractTime(exitAt!);
    }
    if (type.toLowerCase() == 'drop') return time;
    return null;
  }

  static String _extractTime(String dateTimeStr) {
    if (dateTimeStr.contains(' ')) {
      final parts = dateTimeStr.split(' ');
      if (parts.length > 1) return parts[1];
    }
    return dateTimeStr;
  }

  factory BusLogEntry.fromJson(Map<String, dynamic> json) {
    // ── Check if response is from modern /transport/trip-history ──
    final tripMap = json['trip'] as Map<String, dynamic>?;
    final busMap = json['bus'] as Map<String, dynamic>?;
    final onboardMap = json['onboard'] as Map<String, dynamic>?;
    final exitMap = json['exit'] as Map<String, dynamic>? ?? json['drop'] as Map<String, dynamic>?;
    final driverMap = tripMap?['driver'] as Map<String, dynamic>?;

    final rawOnboardAt = onboardMap?['at']?.toString();
    final rawExitAt = exitMap?['at']?.toString();
    final rawStartedAt = tripMap?['started_at']?.toString();

    // Determine representative date (e.g. 2026-09-05)
    String dateStr = json['date']?.toString() ?? '';
    if (dateStr.isEmpty && rawOnboardAt != null && rawOnboardAt.isNotEmpty) {
      dateStr = rawOnboardAt.split(' ').first;
    } else if (dateStr.isEmpty && rawStartedAt != null && rawStartedAt.isNotEmpty) {
      dateStr = rawStartedAt.split(' ').first;
    }

    final rawType = tripMap?['type']?.toString() ?? json['type']?.toString() ?? 'morning';
    final rawStatus = json['status']?.toString() ?? 'completed';
    final rawEventStatus = json['event_status']?.toString();
    final rawPointName = onboardMap?['address']?.toString() ??
        json['point_name']?.toString() ??
        json['location']?.toString() ??
        'Averroes Route';

    return BusLogEntry(
      id: json['id']?.toString() ?? '',
      date: dateStr,
      type: rawType,
      pointName: rawPointName,
      time: json['time']?.toString() ?? (rawOnboardAt != null ? _extractTime(rawOnboardAt) : null),
      status: rawStatus,
      eventStatus: rawEventStatus,
      onboardAt: rawOnboardAt,
      exitAt: rawExitAt,
      busName: busMap?['name']?.toString() ?? busMap?['bus_name']?.toString(),
      vehicleNo: busMap?['vehicle_no']?.toString(),
      driverName: driverMap?['name']?.toString() ?? json['driver_name']?.toString(),
      driverPhone: driverMap?['phone']?.toString() ?? json['driver_phone']?.toString(),
      recordedBy: json['recorded_by']?.toString(),
    );
  }
}

/// Matches Section 5 `GET /transport/live-location`
class BusLiveLocation {
  final bool assigned;
  final String trackingStatus; // 'live', 'stale', 'waiting_for_location', 'not_running', 'not_assigned'
  final BusInfo? bus;
  final Map<String, dynamic>? activeTrip;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double? heading;
  final double? speed;
  final String? recordedAt;
  final String? updatedAt;
  final int? ageSeconds;
  final bool isStale;
  final int refreshAfterSeconds;

  BusLiveLocation({
    this.assigned = true,
    required this.trackingStatus,
    this.bus,
    this.activeTrip,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.heading,
    this.speed,
    this.recordedAt,
    this.updatedAt,
    this.ageSeconds,
    required this.isStale,
    required this.refreshAfterSeconds,
  });

  factory BusLiveLocation.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;

    final lat = location?['latitude'] != null
        ? double.tryParse(location!['latitude'].toString())
        : (location?['lat'] != null ? double.tryParse(location!['lat'].toString()) : null);

    final lng = location?['longitude'] != null
        ? double.tryParse(location!['longitude'].toString())
        : (location?['lng'] != null ? double.tryParse(location!['lng'].toString()) : null);

    final accuracy = location?['accuracy_meters'] != null
        ? double.tryParse(location!['accuracy_meters'].toString())
        : (location?['accuracy'] != null ? double.tryParse(location!['accuracy'].toString()) : null);

    final headingDeg = location?['heading_degrees'] != null
        ? double.tryParse(location!['heading_degrees'].toString())
        : (location?['heading'] != null ? double.tryParse(location!['heading'].toString()) : null);

    final spd = location?['speed'] != null ? double.tryParse(location!['speed'].toString()) : null;

    final isStaleVal = location?['is_stale'] == true || (json['tracking_status']?.toString() == 'stale');
    final refreshSec = json['refresh_after_seconds'] is int
        ? json['refresh_after_seconds'] as int
        : (int.tryParse(json['refresh_after_seconds']?.toString() ?? '') ?? 10);

    return BusLiveLocation(
      assigned: json['assigned'] == true || json['assigned'] == null,
      trackingStatus: json['tracking_status']?.toString() ?? 'not_assigned',
      bus: json['bus'] != null ? BusInfo.fromJson(json['bus'] as Map<String, dynamic>) : null,
      activeTrip: json['active_trip'] as Map<String, dynamic>?,
      latitude: lat,
      longitude: lng,
      accuracyMeters: accuracy,
      heading: headingDeg,
      speed: spd,
      recordedAt: location?['recorded_at']?.toString(),
      updatedAt: location?['updated_at']?.toString(),
      ageSeconds: location?['age_seconds'] != null ? int.tryParse(location!['age_seconds'].toString()) : null,
      isStale: isStaleVal,
      refreshAfterSeconds: refreshSec,
    );
  }

  double? get speedKmh => speed;
  String get lastUpdated => isStale ? 'Stale' : (trackingStatus == 'live' ? 'Live' : trackingStatus);
}

// ════════════════════════════════════════════════════════════════════════════
// CONTROLLER — BusController
// ════════════════════════════════════════════════════════════════════════════

class BusController extends GetxController {
  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _scheduleEndpoint = '/transport/bus-schedule';
  static const String _tripHistoryEndpoint = '/transport/trip-history';
  static const String _liveLocationEndpoint = '/transport/live-location';

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

  // 1. Bus Schedule state
  var scheduleLoading = true.obs;
  var scheduleHasError = false.obs;
  var scheduleErrorMessage = ''.obs;
  Rx<BusSchedule?> schedule = Rx<BusSchedule?>(null);

  // 2. Bus log / trip history state
  var logLoading = true.obs;
  var logLoadingMore = false.obs;
  var logHasError = false.obs;
  var logErrorMessage = ''.obs;
  var busLogs = <BusLogEntry>[].obs;
  var logCurrentPage = 1.obs;
  var logLastPage = 1.obs;
  bool get hasMoreLogs => logCurrentPage.value < logLastPage.value;

  // 3 & 4. Live location / live tracking state
  var liveLoading = true.obs;
  var liveHasError = false.obs;
  var liveErrorMessage = ''.obs;
  Rx<BusLiveLocation?> liveLocation = Rx<BusLiveLocation?>(null);

  var isLiveTrackingActive = false.obs;
  Timer? _pollTimer;
  static const Duration _defaultPollInterval = Duration(seconds: 10);

  @override
  void onInit() {
    super.onInit();
    fetchSchedule();
    fetchBusLog();
  }

  @override
  void onClose() {
    stopLiveTracking();
    super.onClose();
  }

  Future<void> refreshSchedule() async => fetchSchedule();
  Future<void> refreshBusLog() async => fetchBusLog();
  Future<void> refreshLiveLocation() async => fetchLiveLocation();

  // ────────────────────────────────────────────────────────────────────────
  // 1. GET /transport/bus-schedule (Section 5)
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchSchedule() async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        scheduleHasError(true);
        scheduleErrorMessage.value = 'Please log in to view bus schedule.';
        scheduleLoading(false);
        return;
      }

      scheduleLoading(true);
      scheduleHasError(false);

      final endpoints = [_scheduleEndpoint, '/bus/schedule'];
      http.Response? response;

      for (final ep in endpoints) {
        try {
          final uri = Uri.parse('$_baseUrl$ep');
          final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 8));
          if (res.statusCode == 200) {
            response = res;
            break;
          }
        } catch (_) {}
      }

      response ??= await http
          .get(Uri.parse('$_baseUrl$_scheduleEndpoint'), headers: _getHeaders(token))
          .timeout(const Duration(seconds: 10));

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
        schedule.value = BusSchedule.fromJson(data);
      } else if (response.statusCode == 200 && decoded != null && decoded['data'] != null) {
        schedule.value = BusSchedule.fromJson(decoded['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        // No transport registered for student
        schedule.value = BusSchedule(assigned: false, assignment: null, scheduleTimesAvailable: false);
      } else {
        scheduleHasError(true);
        scheduleErrorMessage.value = decoded?['message']?.toString() ?? 'Failed to load bus schedule.';
      }
    } catch (e) {
      scheduleHasError(true);
      scheduleErrorMessage.value = 'Could not connect to server. Please check your internet connection.';
    } finally {
      scheduleLoading(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 2. GET /transport/trip-history (Section 5, alias /transport/bus-log)
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchBusLog({String? from, String? to, String? tripType, String? tripStatus}) async {
    await _fetchLogPage(page: 1, append: false, from: from, to: to, tripType: tripType, tripStatus: tripStatus);
  }

  Future<void> loadMoreBusLogs({String? from, String? to, String? tripType, String? tripStatus}) async {
    if (logLoadingMore.value || logLoading.value || !hasMoreLogs) return;
    await _fetchLogPage(page: logCurrentPage.value + 1, append: true, from: from, to: to, tripType: tripType, tripStatus: tripStatus);
  }

  Future<void> _fetchLogPage({
    required int page,
    required bool append,
    String? from,
    String? to,
    String? tripType,
    String? tripStatus,
  }) async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        logHasError(true);
        logErrorMessage.value = 'Please log in to view bus history.';
        logLoading(false);
        return;
      }

      if (append) {
        logLoadingMore(true);
      } else {
        logLoading(true);
        logHasError(false);
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': '30',
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        if (tripType != null && tripType.isNotEmpty) 'trip_type': tripType,
        if (tripStatus != null && tripStatus.isNotEmpty) 'trip_status': tripStatus,
      };

      final endpoints = [_tripHistoryEndpoint, '/transport/bus-log', '/bus/entry-exit-log'];
      http.Response? response;

      for (final ep in endpoints) {
        try {
          final uri = Uri.parse('$_baseUrl$ep').replace(queryParameters: queryParams);
          final res = await http.get(uri, headers: _getHeaders(token)).timeout(const Duration(seconds: 8));
          if (res.statusCode == 200) {
            response = res;
            break;
          }
        } catch (_) {}
      }

      response ??= await http
          .get(Uri.parse('$_baseUrl$_tripHistoryEndpoint').replace(queryParameters: queryParams), headers: _getHeaders(token))
          .timeout(const Duration(seconds: 10));

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
        final rawLogs = (data['trip_history'] as List<dynamic>? ?? data['logs'] as List<dynamic>? ?? []);
        final parsed = rawLogs
            .whereType<Map<String, dynamic>>()
            .map((e) => BusLogEntry.fromJson(e))
            .toList();

        if (append) {
          busLogs.addAll(parsed);
        } else {
          busLogs.value = parsed;
        }

        final pagination = data['pagination'] as Map<String, dynamic>?;
        logCurrentPage.value = pagination?['current_page'] as int? ?? page;
        logLastPage.value = pagination?['last_page'] as int? ?? logCurrentPage.value;
      } else if (response.statusCode == 404 || (response.statusCode == 200 && (decoded == null || decoded['data'] == null))) {
        // Valid empty state: Student has no bus logs
        if (!append) {
          busLogs.value = [];
        }
      } else {
        logHasError(true);
        logErrorMessage.value = decoded?['message']?.toString() ?? 'No bus log entries found.';
      }
    } catch (e) {
      if (!append) {
        busLogs.value = [];
      }
    } finally {
      logLoading(false);
      logLoadingMore(false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // 3. GET /transport/live-location (Section 5)
  // ────────────────────────────────────────────────────────────────────────
  Future<void> fetchLiveLocation() async {
    try {
      final token = await _ensureToken();
      if (token == null || token.isEmpty) {
        liveHasError(true);
        liveErrorMessage.value = 'Please log in to track bus.';
        liveLoading(false);
        return;
      }

      liveHasError(false);

      final uri = Uri.parse('$_baseUrl$_liveLocationEndpoint');
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
        liveLocation.value = BusLiveLocation.fromJson(data);
      } else {
        liveHasError(true);
        liveErrorMessage.value = decoded?['message']?.toString() ?? 'Live tracking not available.';
      }
    } catch (e) {
      liveHasError(true);
      liveErrorMessage.value = 'Could not connect to live location service.';
    } finally {
      liveLoading(false);
    }
  }

  void startLiveTracking() {
    if (isLiveTrackingActive.value) return;
    isLiveTrackingActive.value = true;
    liveLoading(true);
    fetchLiveLocation();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_defaultPollInterval, (_) {
      if (isLiveTrackingActive.value) {
        fetchLiveLocation();
      }
    });
  }

  void stopLiveTracking() {
    isLiveTrackingActive.value = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchSchedule(),
      fetchBusLog(),
    ]);
  }
}
