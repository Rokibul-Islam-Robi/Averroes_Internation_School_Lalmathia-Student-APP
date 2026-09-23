import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// 2nd code-er correct package path ekhane use kora hoyeche
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// SETTINGS PAGE
//
// 3-dot AppBar menu থেকে আসা "Settings" entry-এর জন্য একটা সাধারণ পেজ।
// এটা নতুন কোনো dark-mode logic বানায় না — dashboard-এ যে Dark Mode card
// আগে থেকেই আছে (WireframeThemecontroler ব্যবহার করে), এই পেজ ঠিক সেই
// একই controller আর একই changeTheme() method reuse করে, যাতে dark mode
// state সবখানে sync থাকে।
// ════════════════════════════════════════════════════════════════════════════
class WireframeSettings extends StatefulWidget {
  const WireframeSettings({Key? key}) : super(key: key);

  @override
  State<WireframeSettings> createState() => _WireframeSettingsState();
}

class _WireframeSettingsState extends State<WireframeSettings> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      // 1st code-er custom PageAppBar rakha hoyeche + 2nd code-er moto translation (.tr) add kora hoyeche
      appBar: PageAppBar(
        title: "Settings".tr,
      ),
      body: PageBackground(
        category: PageCategory.general,
        child: Column(
          children: [
            // Safe spacing top header
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: GetBuilder<WireframeThemecontroler>(
                builder: (themeCtrl) {
                  return Container(
                    decoration: BoxDecoration(
                      color: themeCtrl.isdark ? WireframeColor.black : WireframeColor.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 26,
                        vertical: height / 36,
                      ),
                      children: [
                        // ── Dark Mode toggle ──
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width / 26,
                            vertical: height / 56,
                          ),
                          decoration: BoxDecoration(
                            color: themeCtrl.isdark
                                ? WireframeColor.lightblack
                                : WireframeColor.lightgray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                themeCtrl.isdark
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: WireframeColor.appcolor,
                              ),
                              SizedBox(width: width / 36),
                              Expanded(
                                child: Text(
                                  "Dark_Mode".tr,
                                  style: sansproSemibold.copyWith(
                                    fontSize: 15,
                                    color: themeCtrl.isdark
                                        ? WireframeColor.white
                                        : WireframeColor.black,
                                  ),
                                ),
                              ),
                              Switch(
                                activeThumbColor: WireframeColor.appcolor,
                                value: themeCtrl.isdark,
                                onChanged: (state) {
                                  themeCtrl.changeTheme(state);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height / 56),

                        // ── Change Layout ──
                        _SettingsTile(
                          icon: Icons.swap_horiz,
                          label: "Change_Layout".tr,
                          isDark: themeCtrl.isdark,
                          onTap: () => _showLayoutSheet(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── "Select Application Layout" (LTR/RTL) bottom sheet ───────────────────
  void _showLayoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
          height: height / 4,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  "Select Application Layout",
                  style: sansproBold.copyWith(fontSize: 16),
                ),
              ),
              const Divider(),
              SizedBox(
                height: height / 26,
                child: InkWell(
                  highlightColor: WireframeColor.transparent,
                  splashColor: WireframeColor.transparent,
                  onTap: () async {
                    await Get.updateLocale(const Locale('en', 'US'));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("LTR", style: sansproRegular.copyWith(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const Divider(),
              SizedBox(
                height: height / 26,
                child: InkWell(
                  highlightColor: WireframeColor.transparent,
                  splashColor: WireframeColor.transparent,
                  onTap: () async {
                    await Get.updateLocale(const Locale('ar', 'ab'));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("RTL".tr, style: sansproRegular.copyWith(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const Divider(),
              SizedBox(
                height: height / 26,
                child: InkWell(
                  highlightColor: WireframeColor.transparent,
                  splashColor: WireframeColor.transparent,
                  onTap: () async {
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Cancel'.tr, style: sansproRegular.copyWith(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? WireframeColor.lightblack : WireframeColor.lightgray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: WireframeColor.appcolor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: sansproSemibold.copyWith(
                  fontSize: 15,
                  color: isDark ? WireframeColor.white : WireframeColor.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: WireframeColor.textgray),
          ],
        ),
      ),
    );
  }
}