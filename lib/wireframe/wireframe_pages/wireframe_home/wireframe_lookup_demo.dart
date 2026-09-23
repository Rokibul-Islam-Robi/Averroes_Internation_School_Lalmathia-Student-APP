import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
// এখানে আপনার নতুন প্রজেক্টের নাম (averroes_student_app) পারফেক্টলি বসানো হয়েছে
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'lookup_controller.dart';
import 'lookup_dropdown.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// এই পেজটা একটা "Class & Section Directory" — Lookup module (Classes,
// Sections, Subjects, Sessions) কাজ করছে কিনা সেটা চোখে দেখে যাচাই করার
// জন্য। এই module-এর নিজের কোনো dashboard tile নেই, কারণ এটা সরাসরি
// ব্যবহারকারীর জন্য কোনো ফিচার না — এটা একটা shared reference data layer যা
// ভবিষ্যতে Homework, Syllabus, Result, Time Table পেজে dropdown filter
// হিসেবে ব্যবহার হবে।
//
// এই পেজে ৪টা dropdown একসাথে দেখানো হয়েছে (Session, Class, Section, Subject)
// — Class বদলালে Section dropdown automatically filter হয়ে যায়, ঠিক যেমন
// তোমার নোটে "ID → Class → Section → Capacity" structure-এ বলা ছিল।
// ════════════════════════════════════════════════════════════════════════════
class WireframeLookupDemo extends StatefulWidget {
  const WireframeLookupDemo({Key? key}) : super(key: key);

  @override
  State<WireframeLookupDemo> createState() => _WireframeLookupDemoState();
}

class _WireframeLookupDemoState extends State<WireframeLookupDemo> {
  final themedata = Get.put(WireframeThemecontroler());
  final lookupCtrl = Get.put(LookupController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(
        title: 'Lookup Demo',
      ),
      body: PageBackground(
        category: PageCategory.general,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Obx(() {
                // ১. লোডিং স্টেট
                if (lookupCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: WireframeColor.white),
                  );
                }

                // ২. এরর স্টেট
                if (lookupCtrl.hasError.value && lookupCtrl.classes.isEmpty) {
                  return _ErrorState(
                    message: lookupCtrl.errorMessage.value,
                    onRetry: lookupCtrl.refreshAllLookups,
                    height: height,
                  );
                }

                // ৩. মেইন কন্টেন্ট / সাকসেস স্টেট
                return RefreshIndicator(
                  onRefresh: lookupCtrl.refreshAllLookups,
                  color: WireframeColor.appcolor,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: themedata.isdark ? WireframeColor.black : WireframeColor.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(), // পুল-টু-রিফ্রেশ নিশ্চিত করার জন্য
                      padding: EdgeInsets.symmetric(horizontal: width / 26, vertical: height / 36),
                      children: [
                        // ── Session dropdown ──────────────────────────────────────
                        LookupDropdown<AcademicSession>(
                          label: "Academic_Session".tr,
                          hintText: "Select_Session".tr,
                          value: lookupCtrl.selectedSession.value,
                          items: lookupCtrl.sessions,
                          labelBuilder: (s) => s.displayLabel,
                          onChanged: lookupCtrl.selectSession,
                        ),
                        SizedBox(height: height / 56),

                        // ── Class dropdown ─────────────────────────────────────────
                        LookupDropdown<SchoolClass>(
                          label: "Class".tr,
                          hintText: "Select_Class".tr,
                          value: lookupCtrl.selectedClass.value,
                          items: lookupCtrl.classes,
                          labelBuilder: (c) => c.displayLabel,
                          onChanged: lookupCtrl.selectClass,
                        ),
                        SizedBox(height: height / 56),

                        // ── Section dropdown — সিলেক্ট করা Class এর উপর filter হয় ──
                        Builder(
                          builder: (context) {
                            final selectedClass = lookupCtrl.selectedClass.value;
                            final filteredSections = selectedClass == null
                                ? <SchoolSection>[]
                                : lookupCtrl.sectionsForClass(selectedClass.id);
                            return LookupDropdown<SchoolSection>(
                              label: "Section".tr,
                              hintText: selectedClass == null ? "Select_Class_First".tr : "Select_Section".tr,
                              value: lookupCtrl.selectedSection.value,
                              items: filteredSections,
                              labelBuilder: (s) => s.displayLabel,
                              onChanged: lookupCtrl.selectSection,
                              enabled: selectedClass != null,
                            );
                          },
                        ),
                        SizedBox(height: height / 56),

                        // ── Subject dropdown ───────────────────────────────────────
                        LookupDropdown<SchoolSubject>(
                          label: "Subject".tr,
                          hintText: "Select_Subject".tr,
                          value: lookupCtrl.selectedSubject.value,
                          items: lookupCtrl.subjects,
                          labelBuilder: (s) => s.displayLabel,
                          onChanged: lookupCtrl.selectSubject,
                        ),
                        SizedBox(height: height / 36),

                        // ── নির্বাচিত Section-এর Capacity দেখানো ───────────────────
                        Builder(
                          builder: (context) {
                            final section = lookupCtrl.selectedSection.value;
                            if (section == null) return const SizedBox.shrink();
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(width / 26),
                              decoration: BoxDecoration(
                                color: WireframeColor.appcolor.withAlpha(15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: WireframeColor.appcolor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.groups_outlined, color: WireframeColor.appcolor),
                                  SizedBox(width: width / 36),
                                  Text(
                                    "${"Section_Capacity".tr}: ${section.capacity}",
                                    style: sansproSemibold.copyWith(fontSize: 14, color: WireframeColor.appcolor),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: height / 36),
                        const Divider(color: WireframeColor.bggray),
                        SizedBox(height: height / 56),

                        // ── সব subject-এর তালিকা ──────────────────────────────────
                        Text(
                          "${"All_Subjects".tr} (${lookupCtrl.subjects.length})",
                          style: sansproSemibold.copyWith(
                            fontSize: 15,
                            color: themedata.isdark ? WireframeColor.white : WireframeColor.black,
                          ),
                        ),
                        SizedBox(height: height / 56),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: lookupCtrl.subjects
                              .map((subj) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: WireframeColor.lightgray,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              subj.displayLabel,
                              style: sansproRegular.copyWith(fontSize: 12),
                            ),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

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
            Icon(Icons.wifi_off, size: height / 16, color: WireframeColor.white),
            SizedBox(height: height / 56),
            Text(
              message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.white),
            ),
            SizedBox(height: height / 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => onRetry(),
              child: Text(
                "Retry".tr,
                style: sansproSemibold.copyWith(color: WireframeColor.appcolor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}