import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'driver_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// Driver QR Scan Page
// PDF section 9 অনুযায়ী: student ID কার্ডের QR একটা URL ওপেন করে যার মধ্যে
// student_uid query parameter থাকে। এখানে শুধু QR স্ক্যান করে সেই student_uid
// বের করে busscan.php কল করা হয়, actual URL browser এ ওপেন করা হয় না।
// ════════════════════════════════════════════════════════════════════════════
class DriverQrScanPage extends StatefulWidget {
  const DriverQrScanPage({Key? key}) : super(key: key);

  @override
  State<DriverQrScanPage> createState() => _DriverQrScanPageState();
}

class _DriverQrScanPageState extends State<DriverQrScanPage> {
  final themedata = Get.put(WireframeThemecontroler());
  late final DriverController driverCtrl;
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessingScan = false; // duplicate scan callback ঠেকাতে

  @override
  void initState() {
    super.initState();
    driverCtrl = Get.isRegistered<DriverController>()
        ? Get.find<DriverController>()
        : Get.put(DriverController());
    driverCtrl.clearScanResult();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessingScan || driverCtrl.scanLoading.value) return;
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final rawValue = barcode?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    final studentUid = driverCtrl.extractStudentUid(rawValue);
    if (studentUid == null || studentUid.isEmpty) {
      Get.snackbar('Invalid QR', 'Could not find student UID from this QR code.');
      return;
    }

    _isProcessingScan = true;
    await _scannerController.stop();
    await driverCtrl.scanStudent(studentUid);
    _isProcessingScan = false;
  }

  Future<void> _rescan() async {
    driverCtrl.clearScanResult();
    await _scannerController.start();
  }

  Future<void> _confirmOnboard(String studentUid) async {
    final result = await driverCtrl.onboardStudent(studentUid);
    if (!mounted) return;
    if (result['success'] == true) {
      Get.snackbar('Success', result['message']?.toString() ?? 'Student onboarded successfully.');
      Navigator.pop(context);
    } else {
      Get.snackbar('Error', result['message']?.toString() ?? 'Failed to onboard student.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isDark = themedata.isdark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: WireframeColor.appcolor,
        elevation: 0,
        title: Text('Scan Student QR'.tr,
            style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 17)),
        iconTheme: const IconThemeData(color: WireframeColor.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: WireframeColor.white),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // ── স্ক্যানার ফ্রেম ওভারলে ─────────────────────────────────────
          Center(
            child: Container(
              width: width / 1.6,
              height: width / 1.6,
              decoration: BoxDecoration(
                border: Border.all(color: WireframeColor.appcolor, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // ── নিচে ফলাফল প্যানেল ────────────────────────────────────────
          Obx(() {
            if (driverCtrl.scanLoading.value) {
              return _bottomSheetWrapper(
                height,
                isDark,
                const Center(child: CircularProgressIndicator()),
              );
            }

            if (driverCtrl.scanErrorMessage.value.isNotEmpty) {
              return _bottomSheetWrapper(
                height,
                isDark,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: WireframeColor.red, size: 32),
                    SizedBox(height: height / 100),
                    Text(
                      driverCtrl.scanErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: sansproRegular.copyWith(
                          fontSize: 13, color: isDark ? WireframeColor.white : WireframeColor.black),
                    ),
                    SizedBox(height: height / 60),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: WireframeColor.appcolor),
                      onPressed: _rescan,
                      child: Text('Scan Again'.tr, style: const TextStyle(color: WireframeColor.white)),
                    ),
                  ],
                ),
              );
            }

            final result = driverCtrl.scanResult.value;
            if (result == null) {
              return _bottomSheetWrapper(
                height,
                isDark,
                Text(
                  'Align student ID QR code within the frame.'.tr,
                  textAlign: TextAlign.center,
                  style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.white),
                ),
              );
            }

            final student = result.student;
            return _bottomSheetWrapper(
              height,
              isDark,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: WireframeColor.appcolor.withAlpha(30),
                        backgroundImage: (student.photoUrl != null && student.photoUrl!.isNotEmpty)
                            ? NetworkImage(student.photoUrl!)
                            : null,
                        child: (student.photoUrl == null || student.photoUrl!.isEmpty)
                            ? const Icon(Icons.person, color: WireframeColor.appcolor, size: 26)
                            : null,
                      ),
                      SizedBox(width: width / 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.studentName,
                              style: sansproSemibold.copyWith(
                                  fontSize: 15, color: isDark ? WireframeColor.white : WireframeColor.black),
                            ),
                            Text(
                              'UID: ${student.studentUid}  •  ${student.enrollment.className}',
                              style: sansproRegular.copyWith(fontSize: 12, color: WireframeColor.textgray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height / 80),

                  if (!student.isActive)
                    _warningBanner('This student is currently inactive.'.tr)
                  else if (result.warning != null && result.warning!.isNotEmpty)
                    _warningBanner(result.warning!)
                  else if (result.activeTrip == null)
                      _warningBanner('No running trip found.'.tr)
                    else if (result.alreadyOnboarded)
                        _warningBanner('This student is already onboarded.'.tr, color: WireframeColor.textgray),

                  SizedBox(height: height / 60),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _rescan,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: height / 65),
                            side: const BorderSide(color: WireframeColor.bggray),
                          ),
                          child: Text('Rescan'.tr,
                              style: sansproSemibold.copyWith(
                                  color: isDark ? WireframeColor.white : WireframeColor.black)),
                        ),
                      ),
                      SizedBox(width: width / 30),
                      Expanded(
                        child: Obx(
                              () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WireframeColor.appcolor,
                              padding: EdgeInsets.symmetric(vertical: height / 65),
                            ),
                            onPressed: (result.canOnboard && !driverCtrl.onboardLoading.value)
                                ? () => _confirmOnboard(student.studentUid)
                                : null,
                            child: driverCtrl.onboardLoading.value
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.2, color: WireframeColor.white),
                            )
                                : Text('OK  (Onboard)'.tr,
                                style: sansproSemibold.copyWith(color: WireframeColor.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _warningBanner(String message, {Color color = WireframeColor.red}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: sansproRegular.copyWith(fontSize: 12, color: color),
      ),
    );
  }

  Widget _bottomSheetWrapper(double height, bool isDark, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: height / 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? WireframeColor.lightblack : WireframeColor.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(top: false, child: child),
      ),
    );
  }
}
