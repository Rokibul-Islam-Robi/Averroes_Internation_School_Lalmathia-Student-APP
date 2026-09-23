import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'lookup_controller.dart';
import 'student_controller.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// SUBJECTS DIRECTORY — Modern Corporate Standard
// Connected to real GET /student/lookups API endpoint via LookupController.
// ════════════════════════════════════════════════════════════════════════════

class WireframeSubjects extends StatelessWidget {
  const WireframeSubjects({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final themedata = Get.put(WireframeThemecontroler());
    final lookupCtrl = Get.put(LookupController());
    final studentCtrl = Get.isRegistered<StudentController>()
        ? Get.find<StudentController>()
        : Get.put(StudentController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(
        title: 'Subjects',
      ),
      body: PageBackground(
        category: PageCategory.syllabus,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

            Expanded(
              child: Obx(() {
                if (lookupCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: WireframeColor.white),
                  );
                }

                if (lookupCtrl.hasError.value && lookupCtrl.subjects.isEmpty) {
                  return _ErrorState(
                    message: lookupCtrl.errorMessage.value,
                    onRetry: lookupCtrl.refreshAllLookups,
                    height: height,
                  );
                }

                if (lookupCtrl.subjects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded, size: 56, color: Colors.white.withAlpha(180)),
                        const SizedBox(height: 12),
                        Text(
                          "No_subjects_found".tr,
                          style: sansproSemibold.copyWith(color: WireframeColor.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final profile = studentCtrl.profile.value;
                final className = profile?.className ?? '';
                final sectionName = profile?.section ?? '';
                final sessionName = resolveCurrentAcademicSession(profile?.academicYear);

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: themedata.isdark ? WireframeColor.black : const Color(0xffF8FAFC),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: lookupCtrl.refreshAllLookups,
                    color: WireframeColor.appcolor,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 24,
                        vertical: height / 45,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemCount: lookupCtrl.subjects.length + 1,
                      separatorBuilder: (_, index) {
                        if (index == 0) return SizedBox(height: height / 65);
                        return SizedBox(height: height / 75);
                      },
                      itemBuilder: (context, index) {
                        // ── Index 0: Header Info Summary Bar ──
                        if (index == 0) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: themedata.isdark ? WireframeColor.lightblack : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: themedata.isdark ? Colors.white12 : const Color(0xffE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: WireframeColor.appcolor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_stories_rounded,
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
                                        "${"Total_Subjects".tr}: ${lookupCtrl.subjects.length}",
                                        style: sansproBold.copyWith(
                                          fontSize: 14.5,
                                          color: themedata.isdark ? WireframeColor.white : const Color(0xff0F172A),
                                        ),
                                      ),
                                      if (className.isNotEmpty || sectionName.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          "Class: $className${sectionName.isNotEmpty ? ' • Section: $sectionName' : ''}${sessionName.isNotEmpty ? ' • $sessionName' : ''}",
                                          style: sansproRegular.copyWith(
                                            fontSize: 11.5,
                                            color: WireframeColor.textgray,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff059669).withAlpha(18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Curriculum",
                                    style: sansproBold.copyWith(
                                      fontSize: 11,
                                      color: const Color(0xff059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // ── Subject Item ──
                        final subject = lookupCtrl.subjects[index - 1];
                        final config = _getSubjectConfig(subject.name, subject.code);

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: themedata.isdark ? WireframeColor.lightblack : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: themedata.isdark ? Colors.white12 : const Color(0xffE2E8F0),
                            ),
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
                              // ── Distinctive Modern Gradient Icon Badge ──
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: config.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: config.gradient[0].withAlpha(60),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    config.icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // ── Subject Name, Code & Type Tags ──
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.name,
                                      style: sansproBold.copyWith(
                                        fontSize: 15,
                                        color: themedata.isdark
                                            ? WireframeColor.white
                                            : const Color(0xff0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        if (subject.code.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xffE2E8F0)),
                                            ),
                                            child: Text(
                                              "Code: ${subject.code}",
                                              style: sansproSemibold.copyWith(
                                                fontSize: 11,
                                                color: const Color(0xff475569),
                                              ),
                                            ),
                                          ),
                                        if (subject.type.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: config.badgeBg,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: config.badgeTextColor.withAlpha(40)),
                                            ),
                                            child: Text(
                                              subject.type,
                                              style: sansproBold.copyWith(
                                                fontSize: 11,
                                                color: config.badgeTextColor,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // ── Status Badge ──
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: subject.isActive
                                      ? const Color(0xffDCFCE7)
                                      : const Color(0xffFEE2E2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: subject.isActive
                                        ? const Color(0xff86EFAC)
                                        : const Color(0xffFCA5A5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: subject.isActive
                                            ? const Color(0xff16A34A)
                                            : const Color(0xffDC2626),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      subject.isActive ? "Active".tr : "Inactive".tr,
                                      style: sansproBold.copyWith(
                                        fontSize: 11,
                                        color: subject.isActive
                                            ? const Color(0xff15803D)
                                            : const Color(0xffB91C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

// ════════════════════════════════════════════════════════════════════════════
// Subject Configuration (Icon, Gradients, and Soft Badge Theming)
// ════════════════════════════════════════════════════════════════════════════

class _SubjectConfig {
  final IconData icon;
  final List<Color> gradient;
  final Color badgeBg;
  final Color badgeTextColor;

  const _SubjectConfig({
    required this.icon,
    required this.gradient,
    required this.badgeBg,
    required this.badgeTextColor,
  });
}

_SubjectConfig _getSubjectConfig(String name, String code) {
  final lower = "$name $code".toLowerCase();

  // English Literature
  if (lower.contains("literature")) {
    return const _SubjectConfig(
      icon: Icons.menu_book_rounded,
      gradient: [Color(0xff4F46E5), Color(0xff6366F1)], // Indigo
      badgeBg: Color(0xffEEF2FF),
      badgeTextColor: Color(0xff4338CA),
    );
  }

  // English / English Language / Grammar
  if (lower.contains("english") || lower.contains("language") || lower.contains("grammar")) {
    return const _SubjectConfig(
      icon: Icons.translate_rounded,
      gradient: [Color(0xff2563EB), Color(0xff3B82F6)], // Royal Blue
      badgeBg: Color(0xffEFF6FF),
      badgeTextColor: Color(0xff1D4ED8),
    );
  }

  // Mathematics / Algebra / Geometry / Math
  if (lower.contains("math") || lower.contains("algebra") || lower.contains("geometry")) {
    return const _SubjectConfig(
      icon: Icons.calculate_rounded,
      gradient: [Color(0xff7C3AED), Color(0xff8B5CF6)], // Purple
      badgeBg: Color(0xffF5F3FF),
      badgeTextColor: Color(0xff6D28D9),
    );
  }

  // Bangla / Bengali
  if (lower.contains("bangla") || lower.contains("bengali") || lower.contains("ban")) {
    return const _SubjectConfig(
      icon: Icons.history_edu_rounded,
      gradient: [Color(0xff059669), Color(0xff10B981)], // Emerald Green
      badgeBg: Color(0xffECFDF5),
      badgeTextColor: Color(0xff047857),
    );
  }

  // Science / Physics / Chemistry / Biology
  if (lower.contains("science") || lower.contains("physics") || lower.contains("chemistry") || lower.contains("biology") || lower.contains("sci")) {
    return const _SubjectConfig(
      icon: Icons.biotech_rounded,
      gradient: [Color(0xff0284C7), Color(0xff06B6D4)], // Cyan / Ocean Blue
      badgeBg: Color(0xffF0FDF4),
      badgeTextColor: Color(0xff0369A1),
    );
  }

  // Islamiyat / Religion / Islamic Studies
  if (lower.contains("islam") || lower.contains("isl") || lower.contains("deen") || lower.contains("religion")) {
    return const _SubjectConfig(
      icon: Icons.auto_stories_rounded,
      gradient: [Color(0xff0D9488), Color(0xff14B8A6)], // Teal
      badgeBg: Color(0xffF0FDFA),
      badgeTextColor: Color(0xff0F766E),
    );
  }

  // Al-Quran / Quran / Hadith
  if (lower.contains("quran") || lower.contains("qur") || lower.contains("hadith")) {
    return const _SubjectConfig(
      icon: Icons.menu_book_outlined,
      gradient: [Color(0xff0F766E), Color(0xff115E59)], // Deep Teal
      badgeBg: Color(0xffCCFBF1),
      badgeTextColor: Color(0xff115E59),
    );
  }

  // Arabic
  if (lower.contains("arabic") || lower.contains("arb")) {
    return const _SubjectConfig(
      icon: Icons.language_rounded,
      gradient: [Color(0xffD97706), Color(0xffF59E0B)], // Amber
      badgeBg: Color(0xffFFFBEB),
      badgeTextColor: Color(0xffB45309),
    );
  }

  // Social Studies / History / Geography / BGS
  if (lower.contains("social") || lower.contains("history") || lower.contains("geography") || lower.contains("global") || lower.contains("bgs")) {
    return const _SubjectConfig(
      icon: Icons.public_rounded,
      gradient: [Color(0xffEA580C), Color(0xffF97316)], // Orange
      badgeBg: Color(0xffFFF7ED),
      badgeTextColor: Color(0xffC2410C),
    );
  }

  // ICT / Computer / Technology
  if (lower.contains("computer") || lower.contains("ict") || lower.contains("tech")) {
    return const _SubjectConfig(
      icon: Icons.computer_rounded,
      gradient: [Color(0xff0284C7), Color(0xff38BDF8)], // Sky Blue
      badgeBg: Color(0xffF0F9FF),
      badgeTextColor: Color(0xff0369A1),
    );
  }

  // Art / Drawing / Craft
  if (lower.contains("art") || lower.contains("draw") || lower.contains("craft")) {
    return const _SubjectConfig(
      icon: Icons.palette_rounded,
      gradient: [Color(0xffDB2777), Color(0xffEC4899)], // Rose / Pink
      badgeBg: Color(0xffFDF2F8),
      badgeTextColor: Color(0xffBE185D),
    );
  }

  // Physical Education / Sports
  if (lower.contains("physical") || lower.contains("pe") || lower.contains("sport") || lower.contains("fitness")) {
    return const _SubjectConfig(
      icon: Icons.fitness_center_rounded,
      gradient: [Color(0xffDC2626), Color(0xffEF4444)], // Red
      badgeBg: Color(0xffFEF2F2),
      badgeTextColor: Color(0xffB91C1C),
    );
  }

  // Default fallback
  return const _SubjectConfig(
    icon: Icons.school_rounded,
    gradient: [Color(0xff2563EB), Color(0xff3B82F6)],
    badgeBg: Color(0xffEFF6FF),
    badgeTextColor: Color(0xff1D4ED8),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// Error State
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
            Icon(Icons.wifi_off_rounded, size: height / 16, color: WireframeColor.white),
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