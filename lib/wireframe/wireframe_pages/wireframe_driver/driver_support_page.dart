import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import '../wireframe_home/page_background.dart';
import 'driver_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// DRIVER HELP & SUPPORT PAGE — MODERN CORPORATE CONTACT HUB
//
// Direct Phone Call, Direct WhatsApp, and Direct Email launchers for drivers
// communicating with the school transport desk and administration.
// ════════════════════════════════════════════════════════════════════════════
class DriverSupportPage extends StatefulWidget {
  const DriverSupportPage({Key? key}) : super(key: key);

  @override
  State<DriverSupportPage> createState() => _DriverSupportPageState();
}

class _DriverSupportPageState extends State<DriverSupportPage> {
  final themedata = Get.put(WireframeThemecontroler());
  late final DriverController driverCtrl;

  static const String _transportDeskPhone = '01796409920';
  static const String _transportDeskWhatsApp = '01796409920';
  static const String _transportDeskEmail = 'transport@averroesint.com';
  static const String _campusAdminPhone = '01953409920';

  @override
  void initState() {
    super.initState();
    driverCtrl = Get.isRegistered<DriverController>()
        ? Get.find<DriverController>()
        : Get.put(DriverController());
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) await launchUrl(uri);
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (_) {
        Get.snackbar(
          'Notice',
          'Could not initiate phone call.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(Uri.parse('whatsapp://send?phone=$clean'), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (_) {
        Get.snackbar(
          'Notice',
          'WhatsApp could not be opened.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final driverName = driverCtrl.driverUser.value?.name ?? 'Driver';
    final driverUser = driverCtrl.driverUser.value?.username ?? '';
    final subject = Uri.encodeComponent('Driver Support Request - $driverName ($driverUser)');
    final uri = Uri.parse('mailto:$email?subject=$subject');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) await launchUrl(uri);
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (_) {
        Get.snackbar(
          'Notice',
          'Could not open email application.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isDark = themedata.isdark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(
        title: 'Transport Help & Support',
      ),
      body: PageBackground(
        category: PageCategory.bus,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: isDark ? WireframeColor.black : const Color(0xffF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 45),
                  child: Column(
                    children: [
                      // ── Top Icon Badge ──
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: WireframeColor.appcolor.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            WireframePngimage.support,
                            height: height / 12,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: height / 60),

                      Center(
                        child: Text(
                          'Driver & Transport Support',
                          style: sansproBold.copyWith(
                            fontSize: 20,
                            color: isDark ? Colors.white : const Color(0xff0B1E4D),
                          ),
                        ),
                      ),
                      SizedBox(height: height / 120),
                      Center(
                        child: Text(
                          'For trip assistance, emergency breakdown, route changes, or student boarding queries, please reach our Transport Desk immediately.',
                          textAlign: TextAlign.center,
                          style: sansproRegular.copyWith(
                            fontSize: 13,
                            color: const Color(0xff64748B),
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(height: height / 36),

                      // ── Primary Action Contact Cards ──
                      _buildContactMethodCard(
                        icon: Icons.phone_in_talk_rounded,
                        iconColor: const Color(0xff16A34A),
                        badgeBg: const Color(0xffDCFCE7),
                        title: 'Transport Desk Helpline',
                        subtitle: '$_transportDeskPhone · Available 8:00 AM – 4:00 PM',
                        actionLabel: 'Call Now',
                        onTap: () => _makePhoneCall(_transportDeskPhone),
                        isDark: isDark,
                      ),
                      SizedBox(height: height / 60),

                      _buildContactMethodCard(
                        icon: Icons.chat_rounded,
                        iconColor: const Color(0xff25D366),
                        badgeBg: const Color(0xffDCFCE7),
                        title: 'WhatsApp Coordinator',
                        subtitle: 'Instant messaging & location sharing',
                        actionLabel: 'Open Chat',
                        onTap: () => _openWhatsApp(_transportDeskWhatsApp),
                        isDark: isDark,
                      ),
                      SizedBox(height: height / 60),

                      _buildContactMethodCard(
                        icon: Icons.alternate_email_rounded,
                        iconColor: const Color(0xff2563EB),
                        badgeBg: const Color(0xffEFF6FF),
                        title: 'Transport Desk Email',
                        subtitle: _transportDeskEmail,
                        actionLabel: 'Send Mail',
                        onTap: () => _sendEmail(_transportDeskEmail),
                        isDark: isDark,
                      ),
                      SizedBox(height: height / 60),

                      _buildContactMethodCard(
                        icon: Icons.emergency_rounded,
                        iconColor: const Color(0xffDC2626),
                        badgeBg: const Color(0xffFEF2F2),
                        title: 'Emergency Administration',
                        subtitle: '$_campusAdminPhone · Lalmatia Campus Security',
                        actionLabel: 'Call Admin',
                        onTap: () => _makePhoneCall(_campusAdminPhone),
                        isDark: isDark,
                      ),
                      SizedBox(height: height / 36),

                      // ── Operational Guidelines Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? WireframeColor.lightblack : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffE2E8F0)),
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
                              children: [
                                const Icon(Icons.info_outline_rounded, color: WireframeColor.appcolor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Transport Protocols for Drivers',
                                  style: sansproBold.copyWith(
                                    fontSize: 14.5,
                                    color: isDark ? Colors.white : const Color(0xff0B1E4D),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _protocolBullet('Always ensure device GPS is turned ON before starting any trip.'),
                            _protocolBullet("Scan every student's QR card upon boarding to update school records."),
                            _protocolBullet('Confirm student exit/drop upon reaching destination stops.'),
                            _protocolBullet('In case of unexpected delay or reroute, notify the Transport Desk immediately.'),
                          ],
                        ),
                      ),
                      SizedBox(height: height / 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethodCard({
    required IconData icon,
    required Color iconColor,
    required Color badgeBg,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
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
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: sansproBold.copyWith(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xff0B1E4D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: sansproRegular.copyWith(
                    fontSize: 11.5,
                    color: const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(
              actionLabel,
              style: sansproBold.copyWith(fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _protocolBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: WireframeColor.appcolor, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff475569), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
