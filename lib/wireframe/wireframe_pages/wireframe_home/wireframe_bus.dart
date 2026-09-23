import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'bus_controller.dart';
import 'bus_live_tracking_page.dart';
import 'student_controller.dart';
import 'teachers_materials_controller.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// BUS SERVICE PAGE — MODERN CORPORATE REDESIGN WITH REAL GOOGLE MAPS
//
// Connected to real GET /transport/bus-schedule, /transport/bus-log, and
// /transport/live-location APIs.
// Features live Google Map tracking, clean segmented tabs, student context,
// route timeline, official transport route PDF viewer, and log history.
// ════════════════════════════════════════════════════════════════════════════

class WireframeBus extends StatefulWidget {
  const WireframeBus({Key? key}) : super(key: key);

  @override
  State<WireframeBus> createState() => _WireframeBusState();
}

class _WireframeBusState extends State<WireframeBus>
    with SingleTickerProviderStateMixin {
  final busCtrl = Get.put(BusController());
  final studentCtrl = Get.put(StudentController());
  final materialsCtrl = Get.put(TeachersMaterialsController());

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Start real-time live location polling from server
    busCtrl.startLiveTracking();
  }

  @override
  void dispose() {
    busCtrl.stopLiveTracking();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Bus Service',
        actions: [
          Container(
            margin: EdgeInsets.only(right: width / 26),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusLiveTrackingPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withAlpha(45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live GPS',
                      style: sansproBold.copyWith(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageBackground(
        category: PageCategory.bus,
        child: Column(
          children: [
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top + 14,
            ),

            // ── Modern Corporate Segmented Capsule Tab Bar ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 24),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withAlpha(50), width: 1.2),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: WireframeColor.appcolor,
                  unselectedLabelColor: Colors.white,
                  labelStyle: sansproBold.copyWith(fontSize: 13.5, letterSpacing: 0.2),
                  unselectedLabelStyle: sansproSemibold.copyWith(fontSize: 13.5),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_bus_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Schedule'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 17),
                          SizedBox(width: 6),
                          Text('Entry/Out Log'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: height / 65),

            // ── Tab Views Container ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ScheduleTab(
                      busCtrl: busCtrl,
                      studentCtrl: studentCtrl,
                      materialsCtrl: materialsCtrl,
                      height: height,
                      width: width,
                    ),
                    _EntryOutLogTab(
                      busCtrl: busCtrl,
                      height: height,
                      width: width,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 1: SCHEDULE TAB
// ════════════════════════════════════════════════════════════════════════════
class _ScheduleTab extends StatelessWidget {
  final BusController busCtrl;
  final StudentController studentCtrl;
  final TeachersMaterialsController materialsCtrl;
  final double height;
  final double width;

  const _ScheduleTab({
    required this.busCtrl,
    required this.studentCtrl,
    required this.materialsCtrl,
    required this.height,
    required this.width,
  });

  void _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openOfficialRouteNotice() {
    const routePdfUrl =
        'https://averroesint.com/averroes_school_erp/uploads/smart_classroom/materials/2026/08/document_20260818142824_818d6e0b4e.pdf';
    materialsCtrl.downloadAndOpenDocument(
      title: 'Official Transport Routes',
      fileUrl: routePdfUrl,
      fileName: 'Averroes_Transport_Routes_Lalmatia.pdf',
      category: 'Transport',
      description: 'Averroes International School, Lalmatia is pleased to offer transportation services on the following routes.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (busCtrl.scheduleLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: WireframeColor.appcolor),
        );
      }
      if (busCtrl.scheduleHasError.value) {
        return _ErrorState(
          message: busCtrl.scheduleErrorMessage.value,
          onRetry: busCtrl.refreshSchedule,
          height: height,
        );
      }

      final schedule = busCtrl.schedule.value;
      final isAssigned = schedule != null && (schedule.assigned || schedule.assignment != null);

      return RefreshIndicator(
        onRefresh: busCtrl.refreshSchedule,
        color: WireframeColor.appcolor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: width / 22, vertical: height / 45),
          children: [
            // 1. Student Context Card
            _buildStudentSummaryCard(isAssigned),

            SizedBox(height: height / 50),

            // 2. Real-Time Live Google Map Card
            _buildLiveGoogleMapCard(context),

            SizedBox(height: height / 50),

            if (!isAssigned) ...[
              // 3. No Bus Assigned Card
              _buildNoBusCard(),

              SizedBox(height: height / 45),

              // 4. Official Lalmatia Transport Routes PDF Notice Action
              _buildOfficialRouteDocumentCard(),

              SizedBox(height: height / 50),

              // 5. Helpline Contact Card
              _buildHelplineCard(),
            ] else ...[
              // 3. Active Bus Info Card
              _buildAssignedBusCard(schedule),

              SizedBox(height: height / 50),

              // 4. Live GPS Tracking Action Card
              _buildLiveTrackingActionCard(context),

              SizedBox(height: height / 45),

              // 5. Stops Timeline
              _buildStopsTimeline(schedule),
            ],

            SizedBox(height: height / 30),
          ],
        ),
      );
    });
  }

  Widget _buildStudentSummaryCard(bool isAssigned) {
    return Obx(() {
      final p = studentCtrl.profile.value;
      final name = p?.studentName.isNotEmpty == true ? p!.studentName : 'Muaz Ibne Arif';
      final roll = p?.rollNo.isNotEmpty == true ? p!.rollNo : (p?.studentId ?? '2023300');
      final cls = p?.className.isNotEmpty == true ? p!.className : 'Pre KG';
      final sec = p?.section.isNotEmpty == true ? p!.section : 'Aqua';
      final session = resolveCurrentAcademicSession(p?.academicYear);
      final photo = p?.profilePhotoUrl ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: WireframeColor.appcolor.withAlpha(40), width: 1.5),
              ),
              child: ClipOval(
                child: photo.isNotEmpty
                    ? Image.network(
                        photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
                      )
                    : Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name ($roll)',
                    style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0B1E4D)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Class: $cls - $sec  ·  Session: $session',
                    style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAssigned ? const Color(0xffDCFCE7) : const Color(0xffF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAssigned ? const Color(0xff86EFAC) : const Color(0xffCBD5E1),
                ),
              ),
              child: Text(
                isAssigned ? 'Enrolled' : 'Not Enrolled',
                style: sansproBold.copyWith(
                  fontSize: 10.5,
                  color: isAssigned ? const Color(0xff16A34A) : const Color(0xff475569),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLiveGoogleMapCard(BuildContext context) {
    return Obx(() {
      final loc = busCtrl.liveLocation.value;
      final hasFix = loc != null && loc.latitude != null && loc.longitude != null;
      final busLatLng = hasFix ? LatLng(loc.latitude!, loc.longitude!) : const LatLng(23.7553, 90.3735);
      const schoolLatLng = LatLng(23.7553, 90.3735); // Averroes Lalmatia Campus

      final markers = <Marker>{
        const Marker(
          markerId: MarkerId('school_campus'),
          position: schoolLatLng,
          infoWindow: InfoWindow(
            title: 'Averroes International School',
            snippet: 'Lalmatia Campus',
          ),
        ),
      };

      if (hasFix) {
        markers.add(
          Marker(
            markerId: const MarkerId('live_school_bus'),
            position: busLatLng,
            rotation: loc.heading ?? 0.0,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: 'Averroes School Bus',
              snippet: loc.speedKmh != null
                  ? 'Speed: ${loc.speedKmh!.toStringAsFixed(0)} km/h · Live'
                  : 'Live GPS Active',
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: busCtrl.isLiveTrackingActive.value
                          ? const Color(0xff16A34A)
                          : const Color(0xff94A3B8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Real-Time Live Map',
                    style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0B1E4D)),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BusLiveTrackingPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fullscreen_rounded, size: 14, color: Color(0xff2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            'Full Screen',
                            style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff2563EB)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: busLatLng,
                    zoom: 14.2,
                  ),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  markers: markers,
                  onTap: (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BusLiveTrackingPage()),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded, size: 14, color: Color(0xff16A34A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasFix
                          ? 'Live GPS (${loc.latitude!.toStringAsFixed(4)}, ${loc.longitude!.toStringAsFixed(4)})'
                          : 'Connecting to live bus GPS...',
                      style: sansproSemibold.copyWith(
                        fontSize: 12,
                        color: hasFix ? const Color(0xff15803D) : const Color(0xff64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (loc?.speedKmh != null) ...[
                    Text(
                      '${loc!.speedKmh!.toStringAsFixed(0)} km/h',
                      style: sansproBold.copyWith(fontSize: 12, color: const Color(0xff0B1E4D)),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    'Real-Time',
                    style: sansproRegular.copyWith(fontSize: 11, color: const Color(0xff94A3B8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNoBusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width / 20, vertical: height / 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xffEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              size: 34,
              color: WireframeColor.appcolor,
            ),
          ),
          SizedBox(height: height / 56),
          Text(
            'No Bus Assigned',
            style: sansproBold.copyWith(
              fontSize: 17.5,
              color: const Color(0xff0B1E4D),
            ),
          ),
          SizedBox(height: height / 100),
          Text(
            'You are currently not enrolled in school transport service. Please contact school administration to subscribe.',
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
              fontSize: 13,
              color: const Color(0xff64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialRouteDocumentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xffFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffFECACA)),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xffDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official Transport Routes',
                      style: sansproBold.copyWith(fontSize: 14, color: const Color(0xff0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Averroes International School Lalmatia',
                      style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'View official pickup points, routes, timings and vehicle details available for the Lalmatia campus.',
            style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff475569), height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.appcolor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _openOfficialRouteNotice,
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: Text(
                'Download & View Route PDF',
                style: sansproBold.copyWith(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xffDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xff16A34A), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transport Desk Helpline',
                  style: sansproBold.copyWith(fontSize: 13, color: const Color(0xff15803D)),
                ),
                const SizedBox(height: 2),
                Text(
                  '01796409920 (8:00 AM – 4:00 PM)',
                  style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff166534)),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _callPhone('01796409920'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xff16A34A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Call',
                style: sansproBold.copyWith(fontSize: 11.5, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedBusCard(BusSchedule schedule) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_bus_rounded, color: WireframeColor.appcolor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.routeName,
                      style: sansproBold.copyWith(fontSize: 16, color: const Color(0xff0B1E4D)),
                    ),
                    if (schedule.busNumber.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xffF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Bus No: ${schedule.busNumber}',
                            style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff475569)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xffF1F5F9), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xff64748B)),
              const SizedBox(width: 6),
              Text(
                'Driver: ${schedule.driverName}',
                style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff334155)),
              ),
              const Spacer(),
              if (schedule.driverPhone.isNotEmpty)
                InkWell(
                  onTap: () => _callPhone(schedule.driverPhone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_rounded, size: 12, color: Color(0xff2563EB)),
                        const SizedBox(width: 4),
                        Text(
                          schedule.driverPhone,
                          style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff2563EB)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (schedule.helperPhone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.support_agent_rounded, size: 16, color: Color(0xff64748B)),
                const SizedBox(width: 6),
                Text(
                  'Helper: ${schedule.helperPhone}',
                  style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff334155)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLiveTrackingActionCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BusLiveTrackingPage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [WireframeColor.appcolor, Color(0xff1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: WireframeColor.appcolor.withAlpha(60),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Bus Live Location',
                    style: sansproBold.copyWith(fontSize: 14.5, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View real-time map GPS position & ETA',
                    style: sansproRegular.copyWith(fontSize: 11.5, color: Colors.white.withAlpha(200)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildStopsTimeline(BusSchedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Stops & Schedule',
          style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff0B1E4D)),
        ),
        const SizedBox(height: 12),
        if (schedule.stops.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: Center(
              child: Text(
                'No stops information published yet.',
                style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff64748B)),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedule.stops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final stop = schedule.stops[index];
                final isLast = index == schedule.stops.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: WireframeColor.appcolor,
                          child: Text(
                            '${stop.stopOrder}',
                            style: sansproBold.copyWith(fontSize: 10.5, color: Colors.white),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 38,
                            color: const Color(0xffCBD5E1),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.stopName,
                              style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Pickup: ${stop.pickupTime}   •   Drop: ${stop.dropTime}',
                              style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TAB 2: ENTRY/OUT LOG TAB
// ════════════════════════════════════════════════════════════════════════════
class _EntryOutLogTab extends StatelessWidget {
  final BusController busCtrl;
  final double height;
  final double width;

  const _EntryOutLogTab({
    required this.busCtrl,
    required this.height,
    required this.width,
  });

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return const Color(0xffDCFCE7);
      case 'late':
        return const Color(0xffFEF3C7);
      case 'missed':
        return const Color(0xffFEE2E2);
      default:
        return const Color(0xffF1F5F9);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return const Color(0xff16A34A);
      case 'late':
        return const Color(0xffD97706);
      case 'missed':
        return const Color(0xffDC2626);
      default:
        return const Color(0xff475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (busCtrl.logLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: WireframeColor.appcolor),
        );
      }
      if (busCtrl.busLogs.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xffF0F4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_toggle_off_rounded,
                    size: 42,
                    color: WireframeColor.appcolor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Bus Log Records',
                  style: sansproBold.copyWith(
                    fontSize: 17,
                    color: const Color(0xff0B1E4D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Boarding and drop-off history will appear here once transport logs are recorded by the driver.',
                  textAlign: TextAlign.center,
                  style: sansproRegular.copyWith(
                    fontSize: 13,
                    color: const Color(0xff64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: busCtrl.refreshBusLog,
        color: WireframeColor.appcolor,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: width / 22, vertical: height / 45),
          itemCount: busCtrl.busLogs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = busCtrl.busLogs[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xffEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: WireframeColor.appcolor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.date,
                          style: sansproBold.copyWith(
                            fontSize: 13.5,
                            color: const Color(0xff0B1E4D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.login_rounded, size: 12, color: Color(0xff16A34A)),
                            const SizedBox(width: 3),
                            Text(
                              'In: ${log.entryTime}',
                              style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.logout_rounded, size: 12, color: Color(0xffDC2626)),
                            const SizedBox(width: 3),
                            Text(
                              'Out: ${log.exitTime}',
                              style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(log.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      log.status.toUpperCase(),
                      style: sansproBold.copyWith(
                        fontSize: 10,
                        color: _statusColor(log.status),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ERROR STATE HELPER
// ════════════════════════════════════════════════════════════════════════════
class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final double height;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: height / 16, color: WireframeColor.textgray),
            SizedBox(height: height / 56),
            Text(
              message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(
                fontSize: 14,
                color: WireframeColor.textgray,
              ),
            ),
            SizedBox(height: height / 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.appcolor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => onRetry(),
              child: Text(
                'Retry',
                style: sansproBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}