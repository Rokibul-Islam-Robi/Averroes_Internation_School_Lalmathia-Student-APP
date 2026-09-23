import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';

import 'page_background.dart';
import 'student_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUPPORT PAGE — modern corporate contact card
// Direct Phone Call, Direct WhatsApp, and Direct Email Integration
// ════════════════════════════════════════════════════════════════════════════
class WireframeSupport extends StatefulWidget {
  const WireframeSupport({super.key});

  @override
  State<WireframeSupport> createState() => _WireframeSupportState();
}

class _WireframeSupportState extends State<WireframeSupport> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  late final StudentController studentCtrl;

  @override
  void initState() {
    super.initState();
    studentCtrl = Get.isRegistered<StudentController>()
        ? Get.find<StudentController>()
        : Get.put(StudentController());
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse("tel:$clean");
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
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
    final uri = Uri.parse("https://wa.me/$clean");
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(Uri.parse("whatsapp://send?phone=$clean"), mode: LaunchMode.externalApplication);
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
    final uri = Uri.parse("mailto:$email?subject=Student%20Support%20Request%20-%20Averroes%20International%20School");
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
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
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'Support'.tr,
      ),
      body: PageBackground(
        category: PageCategory.complain,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: height / 36),
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                      color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 26, vertical: height / 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height / 50),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: WireframeColor.appcolor.withAlpha(15),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              WireframePngimage.support,
                              height: height / 10,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: height / 60),
                        Text(
                          "Get_Support".tr,
                          style: sansproBold.copyWith(fontSize: 20),
                        ),
                        SizedBox(height: height / 120),
                        Text(
                          "For_any_support_request_regards_your_orders_or_deliveries_please_feel_free_to_speak_with_us_at_below"
                              .tr,
                          textAlign: TextAlign.center,
                          style: sansproRegular.copyWith(
                              fontSize: 13.5, color: WireframeColor.textgray),
                        ),
                        SizedBox(height: height / 40),

                        // Corporate contact card with live ERP student branch data and direct actions
                        _buildContactCard(),
                        SizedBox(height: height / 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Obx(() {
      final p = studentCtrl.profile.value;
      final branch = p?.branchName.isNotEmpty == true ? p!.branchName : 'Lalmatia';
      final schoolTitle = "Averroes International School ($branch)";
      final address = p?.branchAddress.isNotEmpty == true
          ? p!.branchAddress
          : "House No – 7/16, Block – B, Lalmatia,\nMohammadpur, Dhaka - 1207";

      return Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 44),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22345FB4),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: height / 120),
            Text(
              schoolTitle,
              textAlign: TextAlign.center,
              style: sansproBold.copyWith(fontSize: 16.5, height: 1.25, color: WireframeColor.white),
            ),
            const SizedBox(height: 6),
            Text(
              address,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(
                  fontSize: 12.5, height: 1.4, color: Colors.white.withAlpha(215)),
            ),
            SizedBox(height: height / 55),
            Divider(color: Colors.white.withAlpha(45), thickness: 1),
            SizedBox(height: height / 70),

            // 1. WhatsApp Contact — Direct WhatsApp chat/call
            _contactActionRow(
              icon: Icons.chat_rounded,
              iconColor: const Color(0xff25D366),
              label: "+880 1954-123 123",
              tag: "WhatsApp",
              tagColor: const Color(0xff25D366),
              onTap: () => _openWhatsApp("+8801954123123"),
            ),
            SizedBox(height: height / 90),

            // 2. Direct Phone Call — School Hotline
            _contactActionRow(
              icon: Icons.phone_in_talk_rounded,
              iconColor: const Color(0xff38BDF8),
              label: "+880 1949-000 555",
              tag: "Direct Call",
              tagColor: const Color(0xff0284C7),
              onTap: () => _makePhoneCall("+8801949000555"),
            ),
            SizedBox(height: height / 90),

            // 3. Direct Email — Official School Admin Mail
            _contactActionRow(
              icon: Icons.alternate_email_rounded,
              iconColor: const Color(0xffFBBF24),
              label: "admin@aisl.edu.bd",
              tag: "Direct Email",
              tagColor: const Color(0xffD97706),
              onTap: () => _sendEmail("admin@aisl.edu.bd"),
            ),

            SizedBox(height: height / 55),
            Divider(color: Colors.white.withAlpha(45), thickness: 1),
            SizedBox(height: height / 90),
            Text(
              "Copyright © 2026 Averroes International School.",
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 10.5, color: Colors.white.withAlpha(170)),
            ),
          ],
        ),
      );
    });
  }

  Widget _contactActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    String? tag,
    Color? tagColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      highlightColor: Colors.white.withAlpha(25),
      splashColor: Colors.white.withAlpha(25),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width / 40, vertical: height / 100),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(25), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.white).withAlpha(35),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: iconColor ?? WireframeColor.white),
            ),
            SizedBox(width: width / 36),
            Expanded(
              child: Text(
                label,
                style: sansproSemibold.copyWith(fontSize: 13.5, color: WireframeColor.white),
              ),
            ),
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: (tagColor ?? const Color(0xff25D366)).withAlpha(220),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: sansproBold.copyWith(fontSize: 9.5, color: WireframeColor.white),
                ),
              ),
            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white.withAlpha(200)),
          ],
        ),
      ),
    );
  }
}