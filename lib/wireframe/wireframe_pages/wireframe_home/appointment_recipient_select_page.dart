import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'appointment_controller.dart';
import 'page_background.dart';

class AppointmentRecipientSelectPage extends StatefulWidget {
  final AppointmentRecipient? initialSelected;

  const AppointmentRecipientSelectPage({
    Key? key,
    this.initialSelected,
  }) : super(key: key);

  @override
  State<AppointmentRecipientSelectPage> createState() =>
      _AppointmentRecipientSelectPageState();
}

class _AppointmentRecipientSelectPageState
    extends State<AppointmentRecipientSelectPage> {
  final AppointmentController apptCtrl = Get.find<AppointmentController>();
  final TextEditingController _searchController = TextEditingController();

  String _categoryFilter = 'Principal & Vice Principal'; // Fixed: Principal & Vice Principal is always the initial default tab
  AppointmentRecipient? _currentSelected;

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.initialSelected;
    if (apptCtrl.recipientsList.isEmpty) {
      apptCtrl.fetchRecipients();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return PageBackground(
      category: PageCategory.appointment,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PageAppBar(
          title: "Select Teacher / Leadership",
          actions: [
            IconButton(
              tooltip: 'Refresh Staff Directory',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                apptCtrl.fetchRecipients();
                Get.snackbar(
                  'Refreshing',
                  'Fetching latest faculty and leadership directory from school server...',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xffF0F7FF),
                  colorText: const Color(0xff0369A1),
                  margin: const EdgeInsets.all(16),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Search & Filter Container ──
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(width / 24, height / 100, width / 24, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xffCBD5E1)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: sansproRegular.copyWith(
                          fontSize: 14,
                          color: const Color(0xff0F172A),
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search by Name, Subject, Designation, ID...',
                          hintStyle: sansproRegular.copyWith(
                            fontSize: 13,
                            color: const Color(0xff94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: WireframeColor.appcolor,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18, color: Color(0xff94A3B8)),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Filter Chips
                    Obx(() {
                      final allRecipients = apptCtrl.recipientsList;
                      final principalAndVice =
                          allRecipients.where((r) => r.isPrincipalOrVice).toList();
                      final leadership =
                          allRecipients.where((r) => r.isLeadership && !r.isPrincipalOrVice).toList();
                      final teachers =
                          allRecipients.where((r) => r.isTeacher).toList();

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Principal & Vice Principal (${principalAndVice.length})',
                              'Principal & Vice Principal',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Leadership & Heads (${leadership.length})',
                              'Leadership',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Class / Subject Teachers (${teachers.length})',
                              'Teachers',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'All (${allRecipients.length})',
                              'All',
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // ── Recipient List View ──
              Expanded(
                child: Obx(() {
                  if (apptCtrl.isRecipientsLoading.value &&
                      apptCtrl.recipientsList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    );
                  }

                  final allRecipients = apptCtrl.recipientsList;

                  if (allRecipients.isEmpty) {
                    return _buildEmptyState(
                      title: 'No Staff Found',
                      subtitle:
                          'Unable to load faculty from the school server. Please pull down or tap refresh to try again.',
                    );
                  }

                  final principalAndVice =
                      allRecipients.where((r) => r.isPrincipalOrVice).toList();
                  final leadership =
                      allRecipients.where((r) => r.isLeadership && !r.isPrincipalOrVice).toList();
                  final teachers =
                      allRecipients.where((r) => r.isTeacher).toList();

                  // 1. Category filter
                  List<AppointmentRecipient> categoryFiltered;
                  if (_categoryFilter == 'Principal & Vice Principal') {
                    categoryFiltered = principalAndVice;
                  } else if (_categoryFilter == 'Leadership') {
                    categoryFiltered = leadership;
                  } else if (_categoryFilter == 'Teachers') {
                    categoryFiltered = teachers;
                  } else {
                    categoryFiltered = allRecipients;
                  }

                  // 2. Search filter
                  final query = _searchController.text.toLowerCase().trim();
                  final filteredList = categoryFiltered.where((r) {
                    if (query.isEmpty) return true;
                    final matchesName = r.name.toLowerCase().contains(query);
                    final matchesDes = r.designation.toLowerCase().contains(query);
                    final matchesDept = r.department.toLowerCase().contains(query);
                    final matchesUid = r.employeeUid.toLowerCase().contains(query);
                    return matchesName || matchesDes || matchesDept || matchesUid;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return _buildEmptyState(
                      title: 'No Matching Faculty',
                      subtitle: query.isNotEmpty
                          ? 'No staff member matched "$query". Try searching with a different name, designation, or ID.'
                          : 'No staff members currently found in this category from the school server.',
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: width / 24,
                      vertical: 6,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final rec = filteredList[index];
                      return _buildRecipientCard(rec);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String categoryKey) {
    final isSelected = _categoryFilter == categoryKey;
    return ChoiceChip(
      label: Text(label),
      labelStyle: sansproSemibold.copyWith(
        fontSize: 12,
        color: isSelected ? Colors.white : const Color(0xff334155),
      ),
      selected: isSelected,
      selectedColor: const Color(0xff0B1E4D),
      backgroundColor: const Color(0xffF1F5F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? const Color(0xff0B1E4D) : const Color(0xffE2E8F0),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _categoryFilter = categoryKey);
        }
      },
    );
  }

  Widget _buildRecipientCard(AppointmentRecipient rec) {
    final isSelected = _currentSelected?.employeeId == rec.employeeId;

    Color badgeBg = const Color(0xffFEF3C7);
    Color badgeFg = const Color(0xffB45309);
    IconData roleIcon = Icons.menu_book_rounded;
    String roleTag = 'Faculty Teacher';
    Color tagBg = const Color(0xffFEF3C7);
    Color tagFg = const Color(0xffB45309);

    if (rec.isPrincipal) {
      badgeBg = const Color(0xffEDE9FE);
      badgeFg = const Color(0xff6D28D9);
      roleIcon = Icons.psychology_rounded;
      roleTag = 'Principal';
      tagBg = const Color(0xffEDE9FE);
      tagFg = const Color(0xff6D28D9);
    } else if (rec.isVicePrincipal) {
      badgeBg = const Color(0xffDCFCE7);
      badgeFg = const Color(0xff15803D);
      roleIcon = Icons.military_tech_rounded;
      roleTag = 'Vice Principal';
      tagBg = const Color(0xffDCFCE7);
      tagFg = const Color(0xff15803D);
    } else if (rec.isLeadership) {
      badgeBg = const Color(0xffE0F2FE);
      badgeFg = const Color(0xff0369A1);
      roleIcon = Icons.workspace_premium_rounded;
      roleTag = 'Leadership';
      tagBg = const Color(0xffE0F2FE);
      tagFg = const Color(0xff0369A1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? WireframeColor.appcolor : const Color(0xffE2E8F0),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? WireframeColor.appcolor.withAlpha(20)
                : Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _currentSelected = rec;
          });
          Navigator.pop(context, rec);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: badgeFg.withAlpha(40)),
                ),
                child: rec.avatarUrl != null && rec.avatarUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          rec.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(roleIcon, color: badgeFg, size: 24),
                        ),
                      )
                    : Icon(roleIcon, color: badgeFg, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            rec.name,
                            style: sansproBold.copyWith(
                              fontSize: 14.5,
                              color: const Color(0xff0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: tagFg.withAlpha(50)),
                          ),
                          child: Text(
                            roleTag,
                            style: sansproBold.copyWith(
                              fontSize: 9.5,
                              color: tagFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rec.designation,
                      style: sansproSemibold.copyWith(
                        fontSize: 12.5,
                        color: const Color(0xff0284C7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded,
                            size: 13, color: Color(0xff64748B)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            rec.department,
                            style: sansproRegular.copyWith(
                              fontSize: 11.5,
                              color: const Color(0xff64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rec.officeHours != null &&
                            rec.officeHours!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: Color(0xff64748B)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              rec.officeHours!,
                              style: sansproRegular.copyWith(
                                fontSize: 11.5,
                                color: const Color(0xff64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? WireframeColor.appcolor : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? WireframeColor.appcolor
                        : const Color(0xff94A3B8),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    Widget? actionButton,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xffF0F7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_off_rounded,
                  size: 28, color: Color(0xff0284C7)),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: sansproBold.copyWith(
                  fontSize: 15.5, color: const Color(0xff0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: sansproRegular.copyWith(
                  fontSize: 12, color: const Color(0xff64748B), height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 16),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }
}
