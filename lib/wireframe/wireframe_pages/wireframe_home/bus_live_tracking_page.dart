import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'bus_controller.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// BUS LIVE TRACKING PAGE — REAL-TIME GOOGLE MAPS SERVICE
//
// Directly communicates with real GET /transport/live-location endpoint.
// Features dynamic live camera tracking, campus & bus markers, speed meter,
// and quick driver contact options.
// ════════════════════════════════════════════════════════════════════════════

class BusLiveTrackingPage extends StatefulWidget {
  const BusLiveTrackingPage({Key? key}) : super(key: key);

  @override
  State<BusLiveTrackingPage> createState() => _BusLiveTrackingPageState();
}

class _BusLiveTrackingPageState extends State<BusLiveTrackingPage> {
  final busCtrl = Get.put(BusController());
  GoogleMapController? _mapController;

  static const LatLng _campusLatLng = LatLng(23.7553, 90.3735); // Averroes Lalmatia
  static const CameraPosition _initialCamera = CameraPosition(
    target: _campusLatLng,
    zoom: 14.5,
  );

  @override
  void initState() {
    super.initState();
    busCtrl.startLiveTracking();
  }

  @override
  void dispose() {
    busCtrl.stopLiveTracking();
    super.dispose();
  }

  void _moveCameraTo(double lat, double lng, {double zoom = 15.5}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Live Bus Tracking',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Live Location',
            onPressed: () => busCtrl.refreshLiveLocation(),
          ),
        ],
      ),
      body: PageBackground(
        category: PageCategory.bus,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 8),
            Expanded(
              child: Stack(
                children: [
                  // ── 1. Google Maps View ─────────────────────────────────────────
                  Obx(() {
                    final loc = busCtrl.liveLocation.value;
                    final hasFix = loc != null && loc.latitude != null && loc.longitude != null;

                    if (hasFix && _mapController != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _moveCameraTo(loc.latitude!, loc.longitude!);
                      });
                    }

                    final markers = <Marker>{
                      const Marker(
                        markerId: MarkerId('school_campus'),
                        position: _campusLatLng,
                        infoWindow: InfoWindow(
                          title: 'Averroes International School',
                          snippet: 'Lalmatia Campus (Main Base)',
                        ),
                      ),
                    };

                    if (hasFix) {
                      markers.add(
                        Marker(
                          markerId: const MarkerId('school_bus'),
                          position: LatLng(loc.latitude!, loc.longitude!),
                          rotation: loc.heading ?? 0.0,
                          anchor: const Offset(0.5, 0.5),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                          infoWindow: InfoWindow(
                            title: 'Averroes School Bus',
                            snippet: loc.speedKmh != null
                                ? 'Speed: ${loc.speedKmh!.toStringAsFixed(0)} km/h · Real-Time'
                                : 'Live Location Active',
                          ),
                        ),
                      );
                    }

                    return GoogleMap(
                      initialCameraPosition: _initialCamera,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (hasFix) {
                          _moveCameraTo(loc.latitude!, loc.longitude!);
                        }
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      markers: markers,
                    );
                  }),

                  // ── 2. Top Live Status Floating Badge ─────────────────────────
                  Positioned(
                    top: 12,
                    left: width / 26,
                    right: width / 26,
                    child: Obx(() {
                      final isLive = busCtrl.isLiveTrackingActive.value;
                      final loc = busCtrl.liveLocation.value;
                      final hasFix = loc != null && loc.latitude != null && loc.longitude != null;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xff0B1E4D).withAlpha(220),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.white.withAlpha(40)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLive ? const Color(0xff22C55E) : const Color(0xff94A3B8),
                                boxShadow: isLive
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xff22C55E).withAlpha(150),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isLive ? 'LIVE REAL-TIME TRACKING' : 'TRACKING PAUSED',
                                    style: sansproBold.copyWith(
                                      fontSize: 12,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    hasFix
                                        ? 'GPS Live: ${loc.latitude!.toStringAsFixed(5)}, ${loc.longitude!.toStringAsFixed(5)}'
                                        : 'Awaiting Real GPS Coordinates from Vehicle',
                                    style: sansproRegular.copyWith(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  // ── 3. Quick Map Action Buttons (Recenter / Campus) ─────────
                  Positioned(
                    right: 16,
                    bottom: 160,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'recenter_bus',
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff0B1E4D),
                          elevation: 4,
                          tooltip: 'Center on Bus',
                          onPressed: () {
                            final loc = busCtrl.liveLocation.value;
                            if (loc != null && loc.latitude != null && loc.longitude != null) {
                              _moveCameraTo(loc.latitude!, loc.longitude!);
                            } else {
                              _moveCameraTo(_campusLatLng.latitude, _campusLatLng.longitude);
                            }
                          },
                          child: const Icon(Icons.directions_bus_rounded, size: 20),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton.small(
                          heroTag: 'recenter_campus',
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff0B1E4D),
                          elevation: 4,
                          tooltip: 'Center on School Campus',
                          onPressed: () {
                            _moveCameraTo(_campusLatLng.latitude, _campusLatLng.longitude);
                          },
                          child: const Icon(Icons.school_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),

                  // ── 4. Error Banner ───────────────────────────────────────────
                  Obx(() {
                    if (!busCtrl.liveHasError.value) return const SizedBox.shrink();
                    return Positioned(
                      top: 75,
                      left: width / 26,
                      right: width / 26,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xffDC2626),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                busCtrl.liveErrorMessage.value,
                                style: sansproRegular.copyWith(fontSize: 12, color: Colors.white),
                              ),
                            ),
                            InkWell(
                              onTap: () => busCtrl.refreshLiveLocation(),
                              child: Text(
                                'Retry',
                                style: sansproBold.copyWith(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // ── 5. Bottom Real-Time Telemetry Sheet ────────────────────────
                  Obx(() {
                    final loc = busCtrl.liveLocation.value;
                    final schedule = busCtrl.schedule.value;
                    final busNo = schedule?.busNumber.isNotEmpty == true
                        ? schedule!.busNumber
                        : (loc?.bus?.vehicleNo ?? 'AIS School Bus');
                    final routeName = schedule?.routeName ?? 'Lalmatia Transport Route';
                    final driverName = schedule?.driverName ?? 'Averroes Assigned Driver';
                    final driverPhone = schedule?.driverPhone ?? '01796409920';

                    return Positioned(
                      bottom: 16,
                      left: width / 26,
                      right: width / 26,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xffBFDBFE)),
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus_filled_rounded,
                                    color: Color(0xff2563EB),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        busNo,
                                        style: sansproBold.copyWith(
                                          fontSize: 15,
                                          color: const Color(0xff0B1E4D),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        routeName,
                                        style: sansproRegular.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xff64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (loc?.speedKmh != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xffE2E8F0)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          loc!.speedKmh!.toStringAsFixed(0),
                                          style: sansproBold.copyWith(
                                            fontSize: 18,
                                            color: const Color(0xff0B1E4D),
                                          ),
                                        ),
                                        Text(
                                          'km/h',
                                          style: sansproRegular.copyWith(
                                            fontSize: 10,
                                            color: const Color(0xff64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xffF1F5F9)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person_rounded, size: 16, color: Color(0xff64748B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    driverName,
                                    style: sansproSemibold.copyWith(
                                      fontSize: 12.5,
                                      color: const Color(0xff334155),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _makeCall(driverPhone),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffDCFCE7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xff86EFAC)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.call, size: 13, color: Color(0xff16A34A)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Call Driver',
                                          style: sansproBold.copyWith(
                                            fontSize: 11.5,
                                            color: const Color(0xff16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}