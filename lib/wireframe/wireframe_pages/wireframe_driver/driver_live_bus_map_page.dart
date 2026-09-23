import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'driver_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// Driver Live Bus Map
// Admin panel-এর "Live Bus Map" পেজের (Bus dropdown + Google Map + Dhaka city
// live location) মতোই ডিজাইন, কিন্তু ড্রাইভার অ্যাপের জন্য মোবাইলে বানানো।
//
// google_maps_flutter হলো Google Maps SDK for Android/iOS — এখানে শুধু
// device-এর নিজের GPS (Geolocator, ইতিমধ্যেই location-update.php তে যেটা
// পাঠানো হচ্ছে) ব্যবহার করে ম্যাপে মার্কার আঁকা হয়, এর জন্য কোনো paid
// Directions/Places API লাগে না — শুধু বিনামূল্যের Maps SDK render + free
// device GPS। PDF-এ driver-এর জন্য অন্য কোনো bus-এর location GET করার আলাদা
// endpoint নেই, তাই এই পেজে ড্রাইভারের নিজের (running trip-এর) bus-টাই
// দেখানো হয় — যেটা সে নিজেই location-update.php দিয়ে সার্ভারে পাঠাচ্ছে ──
// ════════════════════════════════════════════════════════════════════════════
class DriverLiveBusMapPage extends StatefulWidget {
  const DriverLiveBusMapPage({Key? key}) : super(key: key);

  @override
  State<DriverLiveBusMapPage> createState() => _DriverLiveBusMapPageState();
}

class _DriverLiveBusMapPageState extends State<DriverLiveBusMapPage> {
  final themedata = Get.put(WireframeThemecontroler());
  late final DriverController driverCtrl;

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSub;
  Position? _currentPosition;
  String? _locationError;
  DateTime? _lastUpdated;

  static const CameraPosition _dhakaCamera = CameraPosition(
    target: LatLng(23.7808875, 90.2792371), // Dhaka city center fallback
    zoom: 12.5,
  );

  @override
  void initState() {
    super.initState();
    driverCtrl = Get.isRegistered<DriverController>()
        ? Get.find<DriverController>()
        : Get.put(DriverController());
    _startWatchingPosition();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _startWatchingPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        setState(() => _locationError = 'Location permission denied.'.tr);
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = 'Please turn on device GPS/location service.'.tr);
        return;
      }

      // ── প্রথমবার সাথে সাথে একটা reading নিয়ে ম্যাপে দেখানো হয় ──────────
      final first = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _onNewPosition(first);

      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // 5 মিটার নড়লেই আপডেট
        ),
      ).listen(_onNewPosition, onError: (_) {
        setState(() => _locationError = 'Could not read live location.'.tr);
      });
    } catch (_) {
      setState(() => _locationError = 'Could not read live location.'.tr);
    }
  }

  void _onNewPosition(Position position) {
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _lastUpdated = DateTime.now();
      _locationError = null;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  Future<void> _refresh() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _onNewPosition(position);
    } catch (_) {
      Get.snackbar('Error', 'Could not refresh location.'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isDark = themedata.isdark;
    final activeTrip = driverCtrl.activeTrip.value;

    return Scaffold(
      backgroundColor: isDark ? WireframeColor.black : WireframeColor.lightgray,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0d2461), WireframeColor.appcolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Live Bus Map'.tr,
            style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: WireframeColor.white),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Bus selector (context only — the map always tracks this
          // device's own live GPS, same as what's sent to the server) ──────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 80),
            color: isDark ? WireframeColor.lightblack : WireframeColor.white,
            child: Row(
              children: [
                const Icon(Icons.directions_bus_filled, color: WireframeColor.appcolor, size: 18),
                SizedBox(width: width / 50),
                Expanded(
                  child: Obx(() {
                    DriverBus? bus;
                    for (final b in driverCtrl.buses) {
                      if (b.id == activeTrip?.busId) {
                        bus = b;
                        break;
                      }
                    }
                    return Text(
                      bus != null
                          ? '${bus.busName} • ${bus.vehicleNo}'
                          : (driverCtrl.buses.isNotEmpty
                          ? driverCtrl.buses.first.busName
                          : 'Bus'.tr),
                      style: sansproSemibold.copyWith(
                          fontSize: 13, color: isDark ? WireframeColor.white : WireframeColor.black),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (activeTrip?.status == 'running' ? WireframeColor.green : WireframeColor.textgray)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    activeTrip?.status == 'running' ? 'Live'.tr : 'No Running Trip'.tr,
                    style: sansproSemibold.copyWith(
                      fontSize: 11,
                      color: activeTrip?.status == 'running' ? WireframeColor.green : WireframeColor.textgray,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _dhakaCamera,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                            LatLng(_currentPosition!.latitude, _currentPosition!.longitude)),
                      );
                    }
                  },
                  markers: _currentPosition == null
                      ? {}
                      : {
                    Marker(
                      markerId: const MarkerId('my_bus'),
                      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      rotation: _currentPosition!.heading,
                      anchor: const Offset(0.5, 0.5),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: InfoWindow(
                        title: 'My Bus'.tr,
                        snippet:
                        '${(_currentPosition!.speed * 3.6).toStringAsFixed(0)} km/h',
                      ),
                    ),
                  },
                ),

                if (_currentPosition == null && _locationError == null)
                  Container(
                    color: WireframeColor.black.withAlpha(40),
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                if (_locationError != null)
                  Positioned(
                    top: height / 60,
                    left: width / 26,
                    right: width / 26,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 80),
                      decoration: BoxDecoration(
                        color: WireframeColor.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: WireframeColor.white, size: 18),
                          SizedBox(width: width / 56),
                          Expanded(
                            child: Text(_locationError!,
                                style:
                                sansproRegular.copyWith(fontSize: 12, color: WireframeColor.white)),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_currentPosition != null)
                  Positioned(
                    bottom: height / 40,
                    left: width / 26,
                    right: width / 26,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 56),
                      decoration: BoxDecoration(
                        color: isDark ? WireframeColor.lightblack : WireframeColor.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: WireframeColor.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: WireframeColor.appcolor.withAlpha(25),
                            child: const Icon(Icons.my_location, color: WireframeColor.appcolor),
                          ),
                          SizedBox(width: width / 36),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Updated: ${_lastUpdated != null ? DateFormat('hh:mm:ss a').format(_lastUpdated!) : '-'}'.tr,
                                    style: sansproSemibold.copyWith(
                                        fontSize: 12,
                                        color: isDark ? WireframeColor.white : WireframeColor.black)),
                                Text(
                                  '${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
                                  style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text((_currentPosition!.speed * 3.6).toStringAsFixed(0),
                                  style: sansproBold.copyWith(fontSize: 18, color: WireframeColor.appcolor)),
                              Text('km/h', style: sansproRegular.copyWith(fontSize: 10, color: WireframeColor.textgray)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
