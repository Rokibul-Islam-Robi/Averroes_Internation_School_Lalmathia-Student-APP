import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'student_controller.dart';
import 'page_background.dart';
import 'id_card_replacement_page.dart';

class WireframeProfile extends StatefulWidget {
  const WireframeProfile({Key? key}) : super(key: key);

  @override
  State<WireframeProfile> createState() => _WireframeProfileState();
}

class _WireframeProfileState extends State<WireframeProfile> {
  final themedata = Get.put(WireframeThemecontroler());
  final studentCtrl = Get.put(StudentController());

  String _getCurrentAcademicSession(String apiAcademicYear) {
    final trimmed = apiAcademicYear.trim();
    final now = DateTime.now();
    final currentYear = now.year;
    final currentSession = "$currentYear-${currentYear + 1}";

    if (trimmed.isEmpty) return currentSession;
    if (trimmed.contains('$currentYear') && trimmed.contains('${currentYear + 1}')) {
      return trimmed;
    }
    return currentSession;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: 'My_profile'.tr,
      ),
      body: PageBackground(
        category: PageCategory.profile,
        child: Obx(() {
          if (studentCtrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (studentCtrl.hasError.value) {
            return _ErrorState(
              message: studentCtrl.errorMessage.value,
              onRetry: studentCtrl.refreshProfile,
              height: height,
            );
          }

          final profile = studentCtrl.profile.value;
          if (profile == null) {
            return Center(
              child: Text(
                "No profile data found".tr,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final bool isDark = themedata.isdark;

          return RefreshIndicator(
            color: WireframeColor.appcolor,
            onRefresh: studentCtrl.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff121826) : const Color(0xffF8FAFC),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width / 24,
                        vertical: height / 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CorporateIdCard(
                            profile: profile,
                            studentCtrl: studentCtrl,
                            isDark: isDark,
                            height: height,
                            width: width,
                          ),
                          SizedBox(height: height / 36),

                          _SectionHeader(
                            icon: Icons.school_rounded,
                            title: "Academic Information".tr,
                            accentColor: const Color(0xff4F46E5),
                            isDark: isDark,
                          ),
                          SizedBox(height: height / 80),
                          _CardContainer(
                            isDark: isDark,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _CorporateInfoTile(
                                    icon: Icons.calendar_today_rounded,
                                    iconColor: const Color(0xffF59E0B),
                                    iconBg: const Color(0xffFFFBEB),
                                    label: "Academic_Year".tr,
                                    value: _getCurrentAcademicSession(profile.academicYear),
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CorporateInfoTile(
                                    icon: Icons.event_available_rounded,
                                    iconColor: const Color(0xff6366F1),
                                    iconBg: const Color(0xffEEF2FF),
                                    label: "Joining_Date".tr,
                                    value: profile.joiningDate,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height / 36),

                          _SectionHeader(
                            icon: Icons.person_rounded,
                            title: "Personal Information".tr,
                            accentColor: const Color(0xffEC4899),
                            isDark: isDark,
                          ),
                          SizedBox(height: height / 80),
                          _CardContainer(
                            isDark: isDark,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CorporateInfoTile(
                                        icon: profile.gender.toLowerCase() == 'female'
                                            ? Icons.female_rounded
                                            : Icons.male_rounded,
                                        iconColor: const Color(0xff3B82F6),
                                        iconBg: const Color(0xffEFF6FF),
                                        label: "Gender".tr,
                                        value: profile.gender,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _CorporateInfoTile(
                                        icon: Icons.cake_rounded,
                                        iconColor: const Color(0xffF43F5E),
                                        iconBg: const Color(0xffFFF1F2),
                                        label: "Date_of_Birth".tr,
                                        value: profile.dateOfBirth,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CorporateInfoTile(
                                        icon: Icons.water_drop_rounded,
                                        iconColor: const Color(0xffDC2626),
                                        iconBg: const Color(0xffFEF2F2),
                                        label: "Blood_Group".tr,
                                        value: profile.bloodGroup,
                                        isBloodBadge: true,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _CorporateInfoTile(
                                        icon: Icons.auto_awesome_rounded,
                                        iconColor: const Color(0xffD97706),
                                        iconBg: const Color(0xffFFFBEB),
                                        label: "Religion".tr,
                                        value: profile.religion,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                ),
                                if (profile.nationality.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _CorporateInfoTile(
                                    icon: Icons.flag_rounded,
                                    iconColor: const Color(0xff10B981),
                                    iconBg: const Color(0xffECFDF5),
                                    label: "Nationality".tr,
                                    value: profile.nationality,
                                    isDark: isDark,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: height / 36),

                          _SectionHeader(
                            icon: Icons.contact_phone_rounded,
                            title: "Contact & Address".tr,
                            accentColor: const Color(0xff059669),
                            isDark: isDark,
                          ),
                          SizedBox(height: height / 80),
                          _CardContainer(
                            isDark: isDark,
                            child: Column(
                              children: [
                                _CorporateInfoTile(
                                  icon: Icons.phone_iphone_rounded,
                                  iconColor: const Color(0xff10B981),
                                  iconBg: const Color(0xffECFDF5),
                                  label: "Contact_Number".tr,
                                  value: profile.contactNumber.isNotEmpty
                                      ? profile.contactNumber
                                      : (profile.accountPhone.isNotEmpty ? profile.accountPhone : '—'),
                                  isDark: isDark,
                                ),
                                if (profile.accountEmail.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _CorporateInfoTile(
                                    icon: Icons.alternate_email_rounded,
                                    iconColor: const Color(0xff6366F1),
                                    iconBg: const Color(0xffEEF2FF),
                                    label: "Account_Email".tr,
                                    value: profile.accountEmail,
                                    isDark: isDark,
                                  ),
                                ],
                                if (profile.presentAddress.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _CorporateInfoTile(
                                    icon: Icons.location_on_rounded,
                                    iconColor: const Color(0xffEF4444),
                                    iconBg: const Color(0xffFEF2F2),
                                    label: "Present_Address".tr,
                                    value: profile.presentAddress,
                                    isDark: isDark,
                                  ),
                                ],
                                if (profile.permanentAddress.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _CorporateInfoTile(
                                    icon: Icons.home_work_rounded,
                                    iconColor: const Color(0xff8B5CF6),
                                    iconBg: const Color(0xffF5F3FF),
                                    label: "Parmanent_Add".tr,
                                    value: profile.permanentAddress,
                                    isDark: isDark,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: height / 36),

                          if (profile.transportFacility.isNotEmpty) ...[
                            _SectionHeader(
                              icon: Icons.directions_bus_rounded,
                              title: "Bus_Service".tr,
                              accentColor: const Color(0xffD97706),
                              isDark: isDark,
                            ),
                            SizedBox(height: height / 80),
                            _CardContainer(
                              isDark: isDark,
                              child: _CorporateInfoTile(
                                icon: Icons.commute_rounded,
                                iconColor: const Color(0xffD97706),
                                iconBg: const Color(0xffFFFBEB),
                                label: "Transport Details".tr,
                                value: '${profile.transportFacility}${profile.transportLocation.isNotEmpty ? ' • ${profile.transportLocation}' : ''}',
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(height: height / 36),
                          ],

                          if (profile.guardians.isNotEmpty) ...[
                            _SectionHeader(
                              icon: Icons.family_restroom_rounded,
                              title: "Guardian".tr,
                              accentColor: const Color(0xff2563EB),
                              isDark: isDark,
                            ),
                            SizedBox(height: height / 80),
                            ...profile.guardians.map((guardian) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ModernGuardianCard(
                                guardian: guardian,
                                isDark: isDark,
                              ),
                            )),
                            SizedBox(height: height / 60),
                          ],

                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withAlpha(8)
                                    : WireframeColor.bggray.withAlpha(90),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user_rounded,
                                    size: 14,
                                    color: WireframeColor.appcolor.withAlpha(200),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Verified Official Academic Record".tr,
                                    style: sansproSemibold.copyWith(
                                      fontSize: 11.5,
                                      color: WireframeColor.textgray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: height / 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CorporateIdCard extends StatelessWidget {
  final StudentProfile profile;
  final StudentController studentCtrl;
  final bool isDark;
  final double height;
  final double width;

  const _CorporateIdCard({
    required this.profile,
    required this.studentCtrl,
    required this.isDark,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : const Color(0xffE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WireframeColor.appcolor,
                  WireframeColor.lightappcolor,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(21),
                topRight: Radius.circular(21),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  "AVERROES INTERNATIONAL SCHOOL",
                  style: sansproBold.copyWith(
                    fontSize: 11.5,
                    letterSpacing: 1.1,
                    color: Colors.white.withAlpha(240),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width / 26,
              vertical: height / 54,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: height / 10.5,
                  height: height / 10.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: WireframeColor.appcolor.withAlpha(120),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profile.profilePhotoUrl.isNotEmpty
                        ? Image.network(
                            profile.profilePhotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _fallbackAvatar(),
                          )
                        : _fallbackAvatar(),
                  ),
                ),
                SizedBox(width: width / 26),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile.studentName.isNotEmpty ? profile.studentName : "Student Name",
                              style: sansproBold.copyWith(
                                fontSize: 18,
                                color: isDark ? Colors.white : const Color(0xff0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (profile.status.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _StatusBadge(status: profile.status),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _IdChip(
                            label: "${profile.className.isNotEmpty ? profile.className : '—'}${profile.section.isNotEmpty ? ' (${profile.section})' : ''}",
                            icon: Icons.school_outlined,
                            isDark: isDark,
                          ),
                          _IdChip(
                            label: "ID: ${profile.studentId.isNotEmpty ? profile.studentId : (profile.rollNo.isNotEmpty ? profile.rollNo : '—')}",
                            icon: Icons.badge_outlined,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withAlpha(20) : const Color(0xffF8FAFC),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(21),
                bottomRight: Radius.circular(21),
              ),
              border: Border(top: BorderSide(color: isDark ? Colors.white.withAlpha(15) : const Color(0xffE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xff16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      "Official AIS Digital ID",
                      style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff64748B)),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IdCardReplacementPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.cached_rounded, size: 13, color: Color(0xff2563EB)),
                        const SizedBox(width: 4),
                        Text(
                          "Reissue / Replace",
                          style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff2563EB)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: WireframeColor.appcolor.withAlpha(25),
      child: const Icon(
        Icons.person_rounded,
        color: WireframeColor.appcolor,
        size: 38,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final bool isDark;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(isDark ? 45 : 25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: accentColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: sansproBold.copyWith(
            fontSize: 15,
            color: isDark ? Colors.white : const Color(0xff1E293B),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _CardContainer({
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : const Color(0xffE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CorporateInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final bool isBloodBadge;
  final bool isDark;

  const _CorporateInfoTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.isBloodBadge = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final String displayVal = value.trim().isNotEmpty ? value.trim() : "—";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0F172A).withAlpha(150) : const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(10) : const Color(0xffF1F5F9),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withAlpha(35) : iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: sansproSemibold.copyWith(
                    fontSize: 11,
                    color: WireframeColor.textgray,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (isBloodBadge && displayVal != "—")
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayVal,
                      style: sansproBold.copyWith(
                        fontSize: 13,
                        color: const Color(0xffDC2626),
                      ),
                    ),
                  )
                else
                  Text(
                    displayVal,
                    style: sansproBold.copyWith(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xff1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernGuardianCard extends StatelessWidget {
  final StudentGuardian guardian;
  final bool isDark;

  const _ModernGuardianCard({
    required this.guardian,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: guardian.isPrimary
              ? WireframeColor.appcolor.withAlpha(90)
              : (isDark ? Colors.white.withAlpha(15) : const Color(0xffE2E8F0)),
          width: guardian.isPrimary ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 25 : 6),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: guardian.isPrimary
                      ? WireframeColor.appcolor.withAlpha(25)
                      : (isDark ? Colors.white.withAlpha(15) : const Color(0xffF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: guardian.isPrimary
                      ? WireframeColor.appcolor
                      : (isDark ? Colors.white70 : const Color(0xff64748B)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guardian.name.isNotEmpty ? guardian.name : "—",
                      style: sansproBold.copyWith(
                        fontSize: 14.5,
                        color: isDark ? Colors.white : const Color(0xff1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guardian.relation.isNotEmpty ? guardian.relation : "Guardian",
                      style: sansproSemibold.copyWith(
                        fontSize: 12,
                        color: WireframeColor.textgray,
                      ),
                    ),
                  ],
                ),
              ),
              if (guardian.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xffE3FCEF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Primary".tr,
                    style: sansproBold.copyWith(
                      fontSize: 10,
                      color: const Color(0xff0F9D58),
                    ),
                  ),
                ),
            ],
          ),
          if (guardian.phone.isNotEmpty || (guardian.email != null && guardian.email!.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xff0F172A).withAlpha(150)
                    : const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 14, color: Color(0xff10B981)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      guardian.phone.isNotEmpty ? guardian.phone : "—",
                      style: sansproSemibold.copyWith(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : const Color(0xff334155),
                      ),
                    ),
                  ),
                  if (guardian.phone.isNotEmpty)
                    InkWell(
                      onTap: () => launchUrl(Uri.parse('tel:${guardian.phone}')),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xff10B981).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          size: 14,
                          color: Color(0xff10B981),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (guardian.occupation != null && guardian.occupation!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Occupation: ${guardian.occupation}",
                style: sansproRegular.copyWith(
                  fontSize: 11.5,
                  color: WireframeColor.textgray,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xffE3FCEF) : WireframeColor.bggray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xff0F9D58) : WireframeColor.textgray,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: sansproBold.copyWith(
              fontSize: 10,
              color: isActive ? const Color(0xff0F9D58) : WireframeColor.textgray,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _IdChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(12)
            : WireframeColor.appcolor.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: WireframeColor.appcolor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: sansproSemibold.copyWith(
              fontSize: 11.5,
              color: isDark ? Colors.white70 : const Color(0xff334155),
            ),
          ),
        ],
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
            Icon(Icons.wifi_off_rounded, size: height / 16, color: Colors.white),
            SizedBox(height: height / 56),
            Text(
              message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 14, color: Colors.white),
            ),
            SizedBox(height: height / 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
