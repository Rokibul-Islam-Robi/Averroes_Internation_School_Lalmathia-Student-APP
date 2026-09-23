import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'driver_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// Driver Trip History Page
// একদম "Transport Trip History" admin ওয়েব পেজের ডিজাইন অনুসরণ করে বানানো হলো:
// From/To Date + Bus + Status ফিল্টার, তারপর SL / Date-Time / Bus / Driver /
// Trip Type / Status / Students / Action (View Students) কলামসহ trip list।
// "View Students" চাপলে সেই ট্রিপের real onboarded student list (onboard-list.php
// ?trip_id=) দেখায় — কোনো ডামি/ফেক ডেটা ছাড়াই।
// ════════════════════════════════════════════════════════════════════════════
class DriverTripHistoryPage extends StatefulWidget {
  const DriverTripHistoryPage({Key? key}) : super(key: key);

  @override
  State<DriverTripHistoryPage> createState() => _DriverTripHistoryPageState();
}

class _DriverTripHistoryPageState extends State<DriverTripHistoryPage> {
  final themedata = Get.put(WireframeThemecontroler());
  late final DriverController driverCtrl;

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 3));
  DateTime _toDate = DateTime.now();
  DriverBus? _selectedBus; // null = All Buses
  String _selectedStatus = 'all'; // all | running | completed

  int? _expandedTripId; // details panel toggle
  bool _detailLoading = false;

  @override
  void initState() {
    super.initState();
    driverCtrl = Get.isRegistered<DriverController>()
        ? Get.find<DriverController>()
        : Get.put(DriverController());
    _applyFilter();
  }

  void _applyFilter() {
    driverCtrl.fetchTripHistory(
      from: _fromDate,
      to: _toDate,
      busId: _selectedBus?.id,
      status: _selectedStatus,
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _toggleDetails(DriverTripHistoryItem trip) async {
    if (_expandedTripId == trip.id) {
      setState(() => _expandedTripId = null);
      return;
    }
    setState(() {
      _expandedTripId = trip.id;
      _detailLoading = true;
    });
    await driverCtrl.fetchOnboardList(tripId: trip.id);
    if (!mounted) return;
    setState(() => _detailLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isDark = themedata.isdark;

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
        title: Text('Transport Trip History'.tr,
            style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 17)),
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async => _applyFilter(),
          child: ListView(
            padding: EdgeInsets.all(width / 24),
            children: [
              _filterCard(height, width, isDark),
              SizedBox(height: height / 40),

              if (driverCtrl.tripHistoryLoading.value && driverCtrl.tripHistory.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height / 10),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (driverCtrl.tripHistoryHasError.value)
                _errorBanner(height, width)
              else if (driverCtrl.tripHistory.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height / 12),
                    child: Center(
                      child: Text('No trips found for the selected filter.'.tr,
                          style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray)),
                    ),
                  )
                else
                  ...driverCtrl.tripHistory.asMap().entries.map((entry) {
                    final sl = entry.key + 1;
                    final trip = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: height / 60),
                      child: _tripCard(height, width, isDark, sl, trip),
                    );
                  }),
            ],
          ),
        );
      }),
    );
  }

  // ── Filters (From Date / To Date / Bus / Status) ──────────────────────────
  Widget _filterCard(double height, double width, bool isDark) {
    final fmt = DateFormat('dd MMM, yyyy');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width / 24),
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : WireframeColor.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _dateField(
                  label: 'From Date'.tr,
                  value: fmt.format(_fromDate),
                  onTap: () => _pickDate(isFrom: true),
                  isDark: isDark,
                  height: height,
                ),
              ),
              SizedBox(width: width / 30),
              Expanded(
                child: _dateField(
                  label: 'To Date'.tr,
                  value: fmt.format(_toDate),
                  onTap: () => _pickDate(isFrom: false),
                  isDark: isDark,
                  height: height,
                ),
              ),
            ],
          ),
          SizedBox(height: height / 60),

          Text('Bus'.tr, style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray)),
          SizedBox(height: height / 200),
          Obx(
                () => DropdownButtonFormField<DriverBus?>(
              initialValue: _selectedBus,
              isExpanded: true,
              decoration: _dropdownDecoration(width, height),
              items: [
                DropdownMenuItem<DriverBus?>(
                  value: null,
                  child: Text('All Buses'.tr, style: sansproRegular.copyWith(fontSize: 13)),
                ),
                ...driverCtrl.buses.map(
                      (bus) => DropdownMenuItem<DriverBus?>(
                    value: bus,
                    child: Text('${bus.busName} (${bus.vehicleNo})',
                        style: sansproRegular.copyWith(fontSize: 13)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedBus = value),
            ),
          ),
          SizedBox(height: height / 60),

          Text('Status'.tr, style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray)),
          SizedBox(height: height / 150),
          Row(
            children: [
              _statusChip('all', 'All Status'.tr, width),
              SizedBox(width: width / 50),
              _statusChip('running', 'Running'.tr, width),
              SizedBox(width: width / 50),
              _statusChip('completed', 'Completed'.tr, width),
            ],
          ),
          SizedBox(height: height / 45),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _fromDate = DateTime.now().subtract(const Duration(days: 3));
                      _toDate = DateTime.now();
                      _selectedBus = null;
                      _selectedStatus = 'all';
                    });
                    _applyFilter();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: height / 65),
                    side: const BorderSide(color: WireframeColor.bggray),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Reset'.tr,
                      style: sansproSemibold.copyWith(
                          fontSize: 13, color: isDark ? WireframeColor.white : WireframeColor.black)),
                ),
              ),
              SizedBox(width: width / 30),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WireframeColor.appcolor,
                    padding: EdgeInsets.symmetric(vertical: height / 65),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Filter'.tr,
                      style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label, double width) {
    final selected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label, style: sansproRegular.copyWith(fontSize: 12)),
      selected: selected,
      selectedColor: WireframeColor.appcolor.withAlpha(40),
      onSelected: (_) {
        setState(() => _selectedStatus = value);
        _applyFilter();
      },
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
    required double height,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: WireframeColor.bggray),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(value,
                  style: sansproSemibold.copyWith(
                      fontSize: 13, color: isDark ? WireframeColor.white : WireframeColor.black)),
            ),
            const Icon(Icons.calendar_today_outlined, size: 15, color: WireframeColor.textgray),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(double width, double height) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: width / 40, vertical: height / 120),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: WireframeColor.bggray),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _errorBanner(double height, double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width / 26),
      decoration: BoxDecoration(
        color: WireframeColor.red.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WireframeColor.red.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: WireframeColor.red, size: 20),
          SizedBox(width: width / 40),
          Expanded(
            child: Text(
              driverCtrl.tripHistoryErrorMessage.value,
              style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.red),
            ),
          ),
          TextButton(
            onPressed: _applyFilter,
            child: Text('Retry'.tr,
                style: sansproSemibold.copyWith(color: WireframeColor.appcolor, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── One trip card (Date/Time, Bus, Driver, Trip Type, Status, Students) ───
  Widget _tripCard(double height, double width, bool isDark, int sl, DriverTripHistoryItem trip) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    final isRunning = trip.status.toLowerCase() == 'running';
    final isExpanded = _expandedTripId == trip.id;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? WireframeColor.lightblack : WireframeColor.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _toggleDetails(trip),
            child: Padding(
              padding: EdgeInsets.all(width / 26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: WireframeColor.appcolor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$sl',
                        style: sansproSemibold.copyWith(fontSize: 12, color: WireframeColor.appcolor)),
                  ),
                  SizedBox(width: width / 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.startedAt != null ? fmt.format(trip.startedAt!) : '—',
                          style: sansproSemibold.copyWith(
                              fontSize: 13, color: isDark ? WireframeColor.white : WireframeColor.black),
                        ),
                        SizedBox(height: height / 260),
                        Text(
                          '${trip.busName.isNotEmpty ? trip.busName : 'Bus'} • ${trip.vehicleNo}',
                          style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
                        ),
                        if (trip.driverName.isNotEmpty)
                          Text(
                            trip.driverName,
                            style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray),
                          ),
                        SizedBox(height: height / 200),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _pill(trip.tripType.isNotEmpty ? trip.tripType : '-', WireframeColor.appcolor),
                            _pill(
                              trip.status.isNotEmpty ? trip.status : '-',
                              isRunning ? WireframeColor.green : WireframeColor.textgray,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${trip.studentsCount}',
                          style: sansproBold.copyWith(
                              fontSize: 18, color: isDark ? WireframeColor.white : WireframeColor.black)),
                      Text('Students'.tr,
                          style: sansproRegular.copyWith(fontSize: 10, color: WireframeColor.textgray)),
                      SizedBox(height: height / 200),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18, color: WireframeColor.textgray),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(width / 26, 0, width / 26, height / 50),
              child: _detailPanel(height, width, isDark),
            ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: sansproSemibold.copyWith(fontSize: 10, color: color)),
    );
  }

  // ── "View Students" detail — reuses the real onboard-list.php?trip_id= ────
  Widget _detailPanel(double height, double width, bool isDark) {
    if (_detailLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Obx(() {
      final students = driverCtrl.onboardedStudents;
      if (students.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: height / 80),
          child: Text('No onboarded students for this trip.'.tr,
              style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray)),
        );
      }
      return Container(
        padding: EdgeInsets.all(width / 30),
        decoration: BoxDecoration(
          color: isDark ? WireframeColor.black : WireframeColor.lightgray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: students.map((s) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: height / 200),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: WireframeColor.appcolor),
                  SizedBox(width: width / 60),
                  Expanded(
                    child: Text(
                      s.studentName.isNotEmpty ? s.studentName : s.studentUid,
                      style: sansproSemibold.copyWith(
                          fontSize: 12, color: isDark ? WireframeColor.white : WireframeColor.black),
                    ),
                  ),
                  Text('ID: ${s.studentId ?? s.studentUid}',
                      style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray)),
                  if (s.className != null) ...[
                    SizedBox(width: width / 60),
                    Text(s.className!,
                        style: sansproRegular.copyWith(fontSize: 11, color: WireframeColor.textgray)),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
