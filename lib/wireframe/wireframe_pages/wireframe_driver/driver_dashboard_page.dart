import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'driver_controller.dart';
import 'driver_drawer.dart';
import 'driver_qr_scan_page.dart';
import 'driver_trip_history_page.dart';
import 'driver_live_bus_map_page.dart';
import 'driver_support_page.dart';

// ════════════════════════════════════════════════════════════════════════════
// DRIVER DASHBOARD — MODERN CORPORATE REDESIGN
//
// Complete feature parity with the corporate student experience:
//   • Modern School Theme & Navigation Drawer
//   • Hero Driver Profile Header Card (with avatar, name, ID, phone, role)
//   • 2x2 Telemetry Stat Cards Grid
//   • Start / End Trip Control Panel with Live Elapsed Ticker
//   • Quick Action Grid (Scan QR, Live Map, Trip History, Support)
//   • Live GPS Telemetry Status Bar
//   • Real-Time Onboarded Students List with Drop/Exit Actions
//   • Corporate School Footer with Direct Helpline Chips & Copyright
// ════════════════════════════════════════════════════════════════════════════
class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({Key? key}) : super(key: key);

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final themedata = Get.put(WireframeThemecontroler());
  late final DriverController driverCtrl;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  DriverBus? _selectedBus;
  String _selectedTripType = 'morning'; // morning | afternoon | other
  bool _showSeatMap = false;

  @override
  void initState() {
    super.initState();
    driverCtrl = Get.isRegistered<DriverController>()
        ? Get.find<DriverController>()
        : Get.put(DriverController());
    driverCtrl.fetchDashboard();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _startTrip() async {
    if (_selectedBus == null && driverCtrl.buses.isNotEmpty) {
      _selectedBus = driverCtrl.buses.first;
    }
    if (_selectedBus == null) {
      Get.snackbar('Error', 'Please select a bus first.');
      return;
    }
    await driverCtrl.startTrip(busId: _selectedBus!.id, tripType: _selectedTripType);
  }

  Future<void> _endTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('End Trip', style: sansproBold.copyWith(fontSize: 17)),
        content: Text('Are you sure you want to end this running trip?', style: sansproRegular.copyWith(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WireframeColor.appcolor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await driverCtrl.endTrip();
    if (!mounted) return;
    if (result['success'] == true) {
      final Duration? duration = result['duration'];
      final durationText = duration != null ? _formatDuration(duration) : null;
      Get.snackbar(
        'Trip Ended',
        durationText != null ? 'Trip duration: $durationText' : 'Trip ended successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xff0B1E4D),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Notice',
        result['message']?.toString() ?? 'Failed to end trip.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: WireframeColor.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _confirmStudentExit(OnboardedStudent s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Student Drop', style: sansproBold.copyWith(fontSize: 17)),
        content: Text(
          'Record exit/drop for ${s.studentName.isNotEmpty ? s.studentName : s.studentUid}?',
          style: sansproRegular.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff16A34A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Drop'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await driverCtrl.recordStudentExit(logId: s.logId, studentUid: s.studentUid);
    if (!mounted) return;
    if (result['success'] == true) {
      Get.snackbar(
        'Student Dropped',
        result['message']?.toString() ?? 'Student exit recorded.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xff16A34A),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        result['message']?.toString() ?? 'Failed to record exit.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: WireframeColor.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openQrScan() async {
    final trip = driverCtrl.activeTrip.value;
    if (trip == null || trip.status != 'running') {
      Get.snackbar(
        'No Active Trip',
        'Please start a trip before scanning student QR codes.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xff0B1E4D),
        colorText: Colors.white,
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverQrScanPage()),
    );
    driverCtrl.fetchDashboard();
  }

  void _openTripHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverTripHistoryPage()),
    );
  }

  void _openLiveMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverLiveBusMapPage()),
    );
  }

  void _openSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DriverSupportPage()),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isDark = themedata.isdark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DriverAppDrawer(),
      backgroundColor: isDark ? WireframeColor.black : const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0B1E4D), WireframeColor.appcolor, WireframeColor.lightappcolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Image.asset(
                  WireframePngimage.averroesLogo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Driver Bus Portal',
                    style: sansproBold.copyWith(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Averroes International School',
                    style: sansproRegular.copyWith(color: Colors.white.withAlpha(200), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Help & Support',
            icon: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 24),
            onPressed: _openSupport,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            onPressed: driverCtrl.fetchDashboard,
          ),
        ],
      ),
      body: Obx(() {
        if (driverCtrl.dashboardLoading.value &&
            driverCtrl.buses.isEmpty &&
            !driverCtrl.dashboardHasError.value) {
          return const Center(child: CircularProgressIndicator(color: WireframeColor.appcolor));
        }

        final activeTrip = driverCtrl.activeTrip.value;
        final isTripRunning = activeTrip != null && activeTrip.status == 'running';
        DriverBus? selectedBusForStats;
        if (isTripRunning) {
          final runningBusId = activeTrip.busId;
          for (final b in driverCtrl.buses) {
            if (b.id == runningBusId) {
              selectedBusForStats = b;
              break;
            }
          }
        } else {
          selectedBusForStats = _selectedBus ?? (driverCtrl.buses.isNotEmpty ? driverCtrl.buses.first : null);
        }

        return RefreshIndicator(
          onRefresh: driverCtrl.fetchDashboard,
          color: WireframeColor.appcolor,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 50),
                children: [
                  if (driverCtrl.dashboardHasError.value) ...[
                    _buildErrorBanner(height, width, isDark),
                    SizedBox(height: height / 50),
                  ],

                  // ── 1. Hero Driver Profile Header Card (Student Style) ──
                  _buildDriverProfileCard(height, width, isDark, isTripRunning),
                  SizedBox(height: height / 50),

                  // ── 2. Modern 2x2 Telemetry Metric Cards Grid ──
                  _buildTelemetryGrid(height, width, isDark, isTripRunning, activeTrip, selectedBusForStats),
                  SizedBox(height: height / 50),

                  // ── 3. Start Trip / Active Running Trip Panel ──
                  if (isTripRunning)
                    _buildActiveRunningTripCard(height, width, isDark, activeTrip)
                  else
                    _buildStartTripCard(height, width, isDark),
                  SizedBox(height: height / 45),

                  // ── 4. Quick Actions 2x2 Grid ──
                  _buildQuickActionsGrid(height, width, isDark),
                  SizedBox(height: height / 45),

                  // ── 5. Live GPS Telemetry Status Bar ──
                  if (isTripRunning) ...[
                    _buildGpsTelemetryBanner(height, width, isDark),
                    SizedBox(height: height / 45),
                  ],

                  // ── 6. Onboarded Students & Seat Indicator Section ──
                  _buildOnboardedStudentsSection(height, width, isDark, isTripRunning),
                  SizedBox(height: height / 36),

                  // ── 7. Modern Corporate School Footer (Matches Student Dashboard) ──
                  _buildCorporateFooter(height, width),
                  SizedBox(height: height / 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. HERO DRIVER PROFILE CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDriverProfileCard(double height, double width, bool isDark, bool isTripRunning) {
    final user = driverCtrl.driverUser.value;
    final name = user?.name.isNotEmpty == true ? user!.name : 'Assigned Driver';
    final username = user?.username.isNotEmpty == true ? user!.username : 'driver17';
    final phone = user?.phone ?? '01796409920';
    final photo = user?.photoUrl ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: WireframeColor.appcolor.withAlpha(50), width: 2),
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isTripRunning ? const Color(0xff16A34A) : const Color(0xff3B82F6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: sansproBold.copyWith(
                    fontSize: 15.5,
                    color: isDark ? Colors.white : const Color(0xff0B1E4D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'UID: $username  ·  Phone: $phone',
                  style: sansproRegular.copyWith(
                    fontSize: 12,
                    color: isDark ? const Color(0xff94A3B8) : const Color(0xff64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: isTripRunning ? const Color(0xffDCFCE7) : const Color(0xffEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isTripRunning ? const Color(0xff86EFAC) : const Color(0xffBFDBFE),
              ),
            ),
            child: Text(
              isTripRunning ? 'On Trip' : 'Ready',
              style: sansproBold.copyWith(
                fontSize: 11,
                color: isTripRunning ? const Color(0xff16A34A) : const Color(0xff2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. 2x2 TELEMETRY METRIC CARDS GRID (Light Corporate Tints)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTelemetryGrid(
    double height,
    double width,
    bool isDark,
    bool isTripRunning,
    DriverActiveTrip? activeTrip,
    DriverBus? busForStats,
  ) {
    final start = driverCtrl.effectiveTripStartTime;
    String val = '-';
    String sub = 'Trip Start';
    if (isTripRunning && start != null) {
      val = DateFormat('hh:mm a').format(start);
      final secs = driverCtrl.tripElapsedSeconds.value;
      final m = (secs % 3600) ~/ 60;
      final s = secs % 60;
      sub = 'Duration: ${m}m ${s}s';
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.alt_route_rounded,
                iconColor: isTripRunning ? const Color(0xff16A34A) : const Color(0xff475569),
                bgColor: isTripRunning ? const Color(0xffF0FDF4) : const Color(0xffF8FAFC),
                borderColor: isTripRunning ? const Color(0xff86EFAC) : const Color(0xffCBD5E1),
                badgeBg: isTripRunning ? const Color(0xffDCFCE7) : const Color(0xffF1F5F9),
                label: 'Trip Status',
                value: isTripRunning ? 'Running' : 'Idle',
                subText: isTripRunning ? 'GPS Streaming' : 'No Active Trip',
                isDark: isDark,
              ),
            ),
            SizedBox(width: width / 30),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.directions_bus_filled_rounded,
                iconColor: const Color(0xff2563EB),
                bgColor: const Color(0xffEFF6FF),
                borderColor: const Color(0xffBFDBFE),
                badgeBg: const Color(0xffDBEAFE),
                label: 'Assigned Bus',
                value: busForStats != null ? busForStats.vehicleNo : 'No Bus',
                subText: busForStats != null ? busForStats.busName : 'Lalmatia Route',
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: height / 60),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xff7C3AED),
                bgColor: const Color(0xffFAF5FF),
                borderColor: const Color(0xffE9D5FF),
                badgeBg: const Color(0xffF3E8FF),
                label: 'Students Onboard',
                value: '${driverCtrl.onboardedCount.value}',
                subText: 'Current Passengers',
                isDark: isDark,
              ),
            ),
            SizedBox(width: width / 30),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xffEA580C),
                bgColor: const Color(0xffFFF7ED),
                borderColor: const Color(0xffFED7AA),
                badgeBg: const Color(0xffFFEDD5),
                label: 'Started At',
                value: val,
                subText: sub,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required Color badgeBg,
    required String label,
    required String value,
    required String subText,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : borderColor,
          width: 1.15,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withAlpha(15),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? WireframeColor.black : badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Text(
                label,
                style: sansproRegular.copyWith(
                  fontSize: 11,
                  color: isDark ? const Color(0xff94A3B8) : const Color(0xff64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: sansproBold.copyWith(
              fontSize: 15.5,
              color: isDark ? Colors.white : const Color(0xff0B1E4D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: sansproRegular.copyWith(
              fontSize: 11,
              color: isDark ? const Color(0xff64748B) : const Color(0xff64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. START / ACTIVE RUNNING TRIP CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveRunningTripCard(
    double height,
    double width,
    bool isDark,
    DriverActiveTrip trip,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0B1E4D).withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip In Progress',
                      style: sansproBold.copyWith(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      'Trip ID: #${trip.id} · ${(trip.tripType ?? 'morning').toUpperCase()}',
                      style: sansproRegular.copyWith(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Obx(() {
                driverCtrl.tripElapsedSeconds.value;
                final secs = driverCtrl.tripElapsedSeconds.value;
                final h = secs ~/ 3600;
                final m = (secs % 3600) ~/ 60;
                final s = secs % 60;
                final text = h > 0
                    ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
                    : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xff16A34A).withAlpha(220),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        text,
                        style: sansproBold.copyWith(color: Colors.white, fontSize: 11.5),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xffDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: driverCtrl.tripActionLoading.value ? null : _endTrip,
              icon: const Icon(Icons.stop_circle_rounded, size: 20),
              label: driverCtrl.tripActionLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xffDC2626)),
                    )
                  : Text('End Trip', style: sansproBold.copyWith(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTripCard(double height, double width, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: WireframeColor.appcolor.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.play_circle_fill_rounded, color: WireframeColor.appcolor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Start a New Trip',
                style: sansproBold.copyWith(
                  fontSize: 15.5,
                  color: isDark ? Colors.white : const Color(0xff0B1E4D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Select Bus',
            style: sansproSemibold.copyWith(
              fontSize: 12,
              color: isDark ? const Color(0xff94A3B8) : const Color(0xff475569),
            ),
          ),
          const SizedBox(height: 6),
          if (driverCtrl.buses.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? WireframeColor.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: Text(
                'No bus currently assigned to your driver profile.',
                style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
              ),
            )
          else
            DropdownButtonFormField<DriverBus>(
              initialValue: _selectedBus ?? driverCtrl.buses.first,
              isExpanded: true,
              dropdownColor: isDark ? WireframeColor.lightblack : Colors.white,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                filled: true,
                fillColor: isDark ? WireframeColor.black : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: WireframeColor.appcolor, width: 1.5),
                ),
              ),
              items: driverCtrl.buses.map((bus) {
                return DropdownMenuItem(
                  value: bus,
                  child: Text(
                    '${bus.busName} (${bus.vehicleNo})',
                    style: sansproSemibold.copyWith(
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xff0B1E4D),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBus = val),
            ),
          const SizedBox(height: 14),

          Text(
            'Trip Type',
            style: sansproSemibold.copyWith(
              fontSize: 12,
              color: isDark ? const Color(0xff94A3B8) : const Color(0xff475569),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: ['morning', 'afternoon', 'other'].map((type) {
              final selected = _selectedTripType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    type.capitalizeFirst ?? type,
                    style: sansproSemibold.copyWith(
                      fontSize: 12,
                      color: selected ? Colors.white : const Color(0xff475569),
                    ),
                  ),
                  selected: selected,
                  selectedColor: WireframeColor.appcolor,
                  backgroundColor: isDark ? WireframeColor.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: selected ? WireframeColor.appcolor : const Color(0xffCBD5E1),
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedTripType = type),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.appcolor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: driverCtrl.tripActionLoading.value ? null : _startTrip,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: driverCtrl.tripActionLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  : Text('Start Trip', style: sansproBold.copyWith(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. QUICK ACTIONS 2x2 GRID
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildQuickActionsGrid(double height, double width, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transport Actions',
          style: sansproBold.copyWith(
            fontSize: 14.5,
            color: isDark ? Colors.white : const Color(0xff0B1E4D),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Scan Student QR',
                subtitle: 'Verify & Onboard',
                accentColor: const Color(0xff2563EB),
                badgeBg: const Color(0xffEFF6FF),
                onTap: _openQrScan,
                isDark: isDark,
              ),
            ),
            SizedBox(width: width / 30),
            Expanded(
              child: _buildActionTile(
                icon: Icons.map_rounded,
                title: 'Live Bus Map',
                subtitle: 'GPS Live Route',
                accentColor: const Color(0xff059669),
                badgeBg: const Color(0xffECFDF5),
                onTap: _openLiveMap,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: height / 60),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.history_toggle_off_rounded,
                title: 'Trip History',
                subtitle: 'Past Logs & Records',
                accentColor: const Color(0xff4F46E5),
                badgeBg: const Color(0xffEEF2FF),
                onTap: _openTripHistory,
                isDark: isDark,
              ),
            ),
            SizedBox(width: width / 30),
            Expanded(
              child: _buildActionTile(
                icon: Icons.support_agent_rounded,
                title: 'Help & Support',
                subtitle: 'Direct Transport Desk',
                accentColor: const Color(0xffEA580C),
                badgeBg: const Color(0xffFFF7ED),
                onTap: _openSupport,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color badgeBg,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? WireframeColor.lightblack : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: sansproBold.copyWith(
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xff0B1E4D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: sansproRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xff64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5. LIVE GPS TELEMETRY BANNER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildGpsTelemetryBanner(double height, double width, bool isDark) {
    return Obx(() {
      final isSending = driverCtrl.isSendingLocation.value;
      final lastTime = driverCtrl.lastLocationSentAt.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSending ? const Color(0xffF0FDF4) : const Color(0xffFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSending ? const Color(0xffBBF7D0) : const Color(0xffFECACA),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSending ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
              size: 16,
              color: isSending ? const Color(0xff16A34A) : const Color(0xffDC2626),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSending
                    ? 'GPS Active · Broadcasting location every 10s'
                    : 'GPS Tracking Inactive',
                style: sansproSemibold.copyWith(
                  fontSize: 12,
                  color: isSending ? const Color(0xff15803D) : const Color(0xff991B1B),
                ),
              ),
            ),
            if (lastTime != null)
              Text(
                'Last: ${DateFormat('hh:mm:ss a').format(lastTime)}',
                style: sansproRegular.copyWith(fontSize: 10.5, color: const Color(0xff64748B)),
              ),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 6. ONBOARDED STUDENTS & SEAT INDICATOR SECTION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildOnboardedStudentsSection(
    double height,
    double width,
    bool isDark,
    bool isTripRunning,
  ) {
    final students = driverCtrl.onboardedStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Onboarded Students',
                  style: sansproBold.copyWith(
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xff0B1E4D),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xffEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffBFDBFE)),
                  ),
                  child: Text(
                    '${students.length}',
                    style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff2563EB)),
                  ),
                ),
              ],
            ),
            if (isTripRunning)
              InkWell(
                onTap: () => setState(() => _showSeatMap = !_showSeatMap),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _showSeatMap ? WireframeColor.appcolor : const Color(0xffEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _showSeatMap ? WireframeColor.appcolor : const Color(0xffC7D2FE)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.airline_seat_recline_normal_rounded,
                        size: 14,
                        color: _showSeatMap ? Colors.white : WireframeColor.appcolor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showSeatMap ? 'Hide Seat Map' : 'View Seat Map',
                        style: sansproBold.copyWith(
                          fontSize: 11.5,
                          color: _showSeatMap ? Colors.white : WireframeColor.appcolor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (!isTripRunning)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? WireframeColor.lightblack : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.directions_bus_outlined, size: 36, color: Color(0xff94A3B8)),
                const SizedBox(height: 8),
                Text(
                  'No Active Trip Running',
                  style: sansproBold.copyWith(fontSize: 14, color: const Color(0xff475569)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start a trip and scan student ID cards to see live passengers and seat occupancy here.',
                  textAlign: TextAlign.center,
                  style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff94A3B8)),
                ),
              ],
            ),
          )
        else ...[
          // ── Collapsible Interactive Bus Seat Map ──
          if (_showSeatMap) ...[
            _buildBusSeatMap(students, isDark, width),
            const SizedBox(height: 14),
          ],

          if (students.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? WireframeColor.lightblack : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 36, color: WireframeColor.appcolor),
                  const SizedBox(height: 8),
                  Text(
                    'No Students Onboard Yet',
                    style: sansproBold.copyWith(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xff0B1E4D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Scan Student QR" to verify and board students onto this bus.',
                    textAlign: TextAlign.center,
                    style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final s = students[index];
                final seatDisplay = s.seatNo?.isNotEmpty == true
                    ? s.seatNo!
                    : 'S-${(index + 1).toString().padLeft(2, '0')}';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? WireframeColor.lightblack : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF2FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xffC7D2FE)),
                        ),
                        child: const Icon(Icons.person_rounded, color: Color(0xff4F46E5), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.studentName.isNotEmpty ? s.studentName : s.studentUid,
                                    style: sansproBold.copyWith(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xff0B1E4D),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xff86EFAC)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.airline_seat_recline_normal_rounded,
                                        size: 11,
                                        color: Color(0xff16A34A),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        seatDisplay,
                                        style: sansproBold.copyWith(
                                          fontSize: 10.5,
                                          color: const Color(0xff16A34A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'UID: ${s.studentUid}${s.className != null ? ' · ${s.className}' : ''}',
                              style: sansproRegular.copyWith(
                                fontSize: 11.5,
                                color: const Color(0xff64748B),
                              ),
                            ),
                            if (s.onboardedAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Boarded: ${s.onboardedAt!}${s.boardingLocation != null ? ' (${s.boardingLocation})' : ''}',
                                  style: sansproRegular.copyWith(
                                    fontSize: 10.5,
                                    color: const Color(0xff16A34A),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFEF2F2),
                          foregroundColor: const Color(0xffDC2626),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xffFECACA)),
                          ),
                        ),
                        onPressed: () => _confirmStudentExit(s),
                        child: Text('Drop', style: sansproBold.copyWith(fontSize: 11.5)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INTERACTIVE BUS SEAT MAP & OCCUPANCY INDICATOR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBusSeatMap(List<OnboardedStudent> students, bool isDark, double width) {
    const int totalRows = 5;
    const int seatsPerRow = 4; // 2 left, 2 right (aisle in between)
    const int totalCapacity = totalRows * seatsPerRow;
    final int occupiedCount = students.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_bus_rounded, color: WireframeColor.appcolor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Live Bus Seating Layout',
                    style: sansproBold.copyWith(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xff0B1E4D),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffC7D2FE)),
                ),
                child: Text(
                  '$occupiedCount / $totalCapacity Occupied',
                  style: sansproBold.copyWith(fontSize: 11, color: WireframeColor.appcolor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Driver Cabin Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? WireframeColor.black : const Color(0xffE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.airline_seat_recline_extra_rounded, size: 15, color: Color(0xff475569)),
                    const SizedBox(width: 6),
                    Text(
                      'Driver Cabin & Entry Door',
                      style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff475569)),
                    ),
                  ],
                ),
                const Icon(Icons.airline_seat_recline_normal_rounded, size: 15, color: Color(0xff475569)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Seating Grid (5 rows x 4 seats with aisle)
          Column(
            children: List.generate(totalRows, (rowIndex) {
              final seatL1 = rowIndex * 4 + 1;
              final seatL2 = rowIndex * 4 + 2;
              final seatR1 = rowIndex * 4 + 3;
              final seatR2 = rowIndex * 4 + 4;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: _buildSeatTile(seatL1, students, isDark)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildSeatTile(seatL2, students, isDark)),
                    // Aisle
                    Container(
                      width: 24,
                      alignment: Alignment.center,
                      child: Text(
                        '${rowIndex + 1}',
                        style: sansproRegular.copyWith(fontSize: 10, color: const Color(0xff94A3B8)),
                      ),
                    ),
                    Expanded(child: _buildSeatTile(seatR1, students, isDark)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildSeatTile(seatR2, students, isDark)),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSeatLegend(
                color: const Color(0xffDCFCE7),
                borderColor: const Color(0xff86EFAC),
                label: 'Occupied ($occupiedCount)',
                textColor: const Color(0xff16A34A),
              ),
              const SizedBox(width: 16),
              _buildSeatLegend(
                color: isDark ? WireframeColor.black : const Color(0xffF1F5F9),
                borderColor: const Color(0xffCBD5E1),
                label: 'Available (${totalCapacity - occupiedCount})',
                textColor: const Color(0xff64748B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatTile(int seatNumber, List<OnboardedStudent> students, bool isDark) {
    OnboardedStudent? occupant;
    final seatCode = 'S-${seatNumber.toString().padLeft(2, '0')}';

    for (final s in students) {
      if (s.seatNo == '$seatNumber' || s.seatNo == seatCode) {
        occupant = s;
        break;
      }
    }

    if (occupant == null && seatNumber <= students.length) {
      occupant = students[seatNumber - 1];
    }

    final isOccupied = occupant != null;
    final displayName = occupant != null
        ? (occupant.studentName.isNotEmpty ? occupant.studentName.split(' ').first : occupant.studentUid)
        : seatCode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: isOccupied
            ? const Color(0xffDCFCE7)
            : (isDark ? WireframeColor.black : const Color(0xffFFFFFF)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOccupied
              ? const Color(0xff86EFAC)
              : (isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
          width: 1.1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOccupied
                ? Icons.airline_seat_recline_normal_rounded
                : Icons.event_seat_outlined,
            size: 15,
            color: isOccupied ? const Color(0xff16A34A) : const Color(0xff94A3B8),
          ),
          const SizedBox(height: 2),
          Text(
            displayName,
            style: sansproBold.copyWith(
              fontSize: 9.5,
              color: isOccupied ? const Color(0xff15803D) : const Color(0xff64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSeatLegend({
    required Color color,
    required Color borderColor,
    required String label,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: sansproSemibold.copyWith(fontSize: 11, color: textColor),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 7. CORPORATE SCHOOL FOOTER (MATCHES STUDENT SIDE EXACTLY)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCorporateFooter(double height, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: width / 22, vertical: height / 50),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22345FB4),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _footerChip(
                icon: Icons.call_rounded,
                text: '+880 1954-123 123',
                trailingTag: 'WhatsApp',
              ),
              _footerChip(
                icon: Icons.call_rounded,
                text: '+880 1949-000 555',
              ),
            ],
          ),
          SizedBox(height: height / 80),
          Divider(color: Colors.white.withAlpha(35), thickness: 1),
          SizedBox(height: height / 100),
          Text(
            'Copyright © 2026 Averroes International School Lalmatia.',
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
              fontSize: 11,
              color: Colors.white.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerChip({
    required IconData icon,
    required String text,
    String? trailingTag,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withAlpha(220)),
        const SizedBox(width: 5),
        Text(
          text,
          style: sansproSemibold.copyWith(fontSize: 12, color: Colors.white),
        ),
        if (trailingTag != null) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xff25D366).withAlpha(210),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trailingTag,
              style: sansproSemibold.copyWith(fontSize: 9, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorBanner(double height, double width, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xffDC2626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              driverCtrl.dashboardErrorMessage.value,
              style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xffDC2626)),
            ),
          ),
          TextButton(
            onPressed: driverCtrl.fetchDashboard,
            child: Text('Retry', style: sansproBold.copyWith(fontSize: 12, color: WireframeColor.appcolor)),
          ),
        ],
      ),
    );
  }
}
