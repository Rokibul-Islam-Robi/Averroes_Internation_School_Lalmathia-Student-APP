import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'complain_controller.dart';
import 'student_controller.dart';
import 'page_background.dart';

class ComplainPage extends StatefulWidget {
  final int initialTabIndex;
  const ComplainPage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<ComplainPage> createState() => _ComplainPageState();
}

class _ComplainPageState extends State<ComplainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ComplainController complainCtrl = Get.put(ComplainController());
  final StudentController studentCtrl = Get.put(StudentController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentSearchController = TextEditingController();
  final TextEditingController _employeeSearchController = TextEditingController();
  final TextEditingController _historySearchController = TextEditingController();

  Timer? _employeeSearchDebounce;
  String _againstType = 'department'; // 'department' or 'employee'
  int? _selectedDepartmentId;
  int? _selectedEmployeeId;
  String _selectedPriority = 'normal'; // 'low', 'normal', 'high'
  String _historyStatusFilter = 'All'; // 'All', 'Submitted', 'Under Review', 'Action Taken', 'Resolved', 'Rejected'
  String _historyPriorityFilter = 'All'; // 'All', 'Urgent', 'Normal', 'Low'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);

    // Pre-fill phone if available from student profile
    final p = studentCtrl.profile.value;
    if (p != null) {
      if (p.contactNumber.isNotEmpty) {
        _phoneController.text = p.contactNumber;
      } else if (p.accountPhone.isNotEmpty) {
        _phoneController.text = p.accountPhone;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _departmentSearchController.dispose();
    _employeeSearchController.dispose();
    _historySearchController.dispose();
    _employeeSearchDebounce?.cancel();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_againstType == 'department' && (_selectedDepartmentId == null || _selectedDepartmentId == 0)) {
      Get.snackbar(
        'Department Required',
        'Please select a department to submit your feedback.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xffFEF2F2),
        colorText: const Color(0xff991B1B),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_againstType == 'employee' && (_selectedEmployeeId == null || _selectedEmployeeId == 0)) {
      Get.snackbar(
        'Staff / Teacher Required',
        'Please select a staff member or teacher to submit your feedback.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xffFEF2F2),
        colorText: const Color(0xff991B1B),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final created = await complainCtrl.submitComplaint(
      againstType: _againstType,
      departmentId: _selectedDepartmentId,
      employeeId: _selectedEmployeeId,
      subject: _subjectController.text.trim(),
      details: _descriptionController.text.trim(),
      priority: _selectedPriority,
      contactPhone: _phoneController.text.trim(),
    );

    if (created != null) {
      _subjectController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedEmployeeId = null;
        _selectedDepartmentId = null;
        _selectedPriority = 'normal';
      });

      if (!mounted) return;

      _showSuccessDialog(created.complaintNo);
    }
  }

  void _showSuccessDialog(String ticketNo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xffDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xff16A34A), size: 38),
              ),
              const SizedBox(height: 18),
              Text(
                'Feedback Submitted!',
                style: sansproBold.copyWith(fontSize: 19, color: WireframeColor.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your feedback has been forwarded directly to the school administration. We will review and respond promptly.',
                style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray, height: 1.45),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 16, color: Color(0xff475569)),
                    const SizedBox(width: 8),
                    Text(
                      'Ticket: $ticketNo',
                      style: sansproSemibold.copyWith(fontSize: 13, color: const Color(0xff1E293B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WireframeColor.appcolor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _tabController.animateTo(1); // Switch to history tab
                  },
                  child: Text(
                    'View in History',
                    style: sansproBold.copyWith(fontSize: 14.5, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCHABLE DEPARTMENT PICKER BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════════════
  void _openDepartmentSearchPicker(BuildContext context) {
    _departmentSearchController.clear();

    if (complainCtrl.departments.isEmpty) {
      complainCtrl.fetchDepartments();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xffCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WireframeColor.appcolor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.domain_rounded, color: WireframeColor.appcolor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Department',
                                style: sansproBold.copyWith(fontSize: 16, color: const Color(0xff0B1E4D)),
                              ),
                              Obx(() => Text(
                                '${complainCtrl.departments.length} Departments Available',
                                style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                              )),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: Color(0xff64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffE2E8F0)),
                      ),
                      child: TextField(
                        controller: _departmentSearchController,
                        autofocus: false,
                        style: sansproRegular.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Search department by name...',
                          hintStyle: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xff64748B), size: 20),
                          suffixIcon: _departmentSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xff64748B)),
                                  onPressed: () {
                                    _departmentSearchController.clear();
                                    setModalState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (_) {
                          setModalState(() {});
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Divider(color: Color(0xffF1F5F9), height: 1),

                  // Departments List
                  Expanded(
                    child: Obx(() {
                      if (complainCtrl.isDeptLoading.value && complainCtrl.departments.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(color: WireframeColor.appcolor),
                        );
                      }

                      final depts = complainCtrl.departments;
                      final query = _departmentSearchController.text.trim().toLowerCase();

                      final filtered = depts.where((dept) {
                        if (query.isNotEmpty) {
                          return dept.name.toLowerCase().contains(query);
                        }
                        return true;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 42, color: Color(0xff94A3B8)),
                                const SizedBox(height: 10),
                                Text(
                                  'No department found',
                                  style: sansproSemibold.copyWith(fontSize: 14.5, color: const Color(0xff334155)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try searching with another keyword',
                                  style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xffF8FAFC), height: 1),
                        itemBuilder: (context, idx) {
                          final dept = filtered[idx];
                          final isSelected = _selectedDepartmentId == dept.id;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDepartmentId = dept.id;
                              });
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: isSelected ? WireframeColor.appcolor.withAlpha(15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: WireframeColor.appcolor.withAlpha(60))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? WireframeColor.appcolor
                                          : const Color(0xffEEF2FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.corporate_fare_rounded,
                                      size: 19,
                                      color: isSelected ? Colors.white : WireframeColor.appcolor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dept.name,
                                          style: sansproBold.copyWith(
                                            fontSize: 13.5,
                                            color: isSelected ? WireframeColor.appcolor : const Color(0xff0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'School Department',
                                          style: sansproRegular.copyWith(
                                            fontSize: 11.5,
                                            color: const Color(0xff64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (isSelected)
                                    const Icon(Icons.check_circle_rounded, color: WireframeColor.appcolor, size: 20)
                                  else
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xffCBD5E1), size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCHABLE EMPLOYEE PICKER BOTTOM SHEET (With Department Filter Chips)
  // ══════════════════════════════════════════════════════════════════════════
  void _openEmployeeSearchPicker(BuildContext context) {
    _employeeSearchController.clear();
    int? modalFilterDeptId;

    if (complainCtrl.employees.isEmpty) {
      complainCtrl.fetchEmployees();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final depts = complainCtrl.departments;

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xffCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WireframeColor.appcolor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.badge_outlined, color: WireframeColor.appcolor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Staff / Teacher',
                                style: sansproBold.copyWith(fontSize: 16, color: const Color(0xff0B1E4D)),
                              ),
                              Obx(() => Text(
                                '${complainCtrl.employees.length} Members in Directory',
                                style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                              )),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: Color(0xff64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffE2E8F0)),
                      ),
                      child: TextField(
                        controller: _employeeSearchController,
                        autofocus: false,
                        style: sansproRegular.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                        decoration: InputDecoration(
                          hintText: 'Search by name, designation, or ID...',
                          hintStyle: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xff64748B), size: 20),
                          suffixIcon: _employeeSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xff64748B)),
                                  onPressed: () {
                                    _employeeSearchController.clear();
                                    setModalState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (q) {
                          setModalState(() {});
                          _employeeSearchDebounce?.cancel();
                          _employeeSearchDebounce = Timer(const Duration(milliseconds: 300), () {
                            complainCtrl.fetchEmployees(
                              departmentId: modalFilterDeptId,
                              search: q.trim(),
                            );
                          });
                        },
                      ),
                    ),
                  ),

                  // Department Filter Chips inside Modal
                  if (depts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        children: [
                          ChoiceChip(
                            label: const Text('All Departments'),
                            selected: modalFilterDeptId == null,
                            onSelected: (_) {
                              setModalState(() => modalFilterDeptId = null);
                            },
                            selectedColor: WireframeColor.appcolor,
                            backgroundColor: const Color(0xffF8FAFC),
                            labelStyle: sansproSemibold.copyWith(
                              fontSize: 11.5,
                              color: modalFilterDeptId == null ? Colors.white : const Color(0xff475569),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: modalFilterDeptId == null ? WireframeColor.appcolor : const Color(0xffCBD5E1),
                              ),
                            ),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          const SizedBox(width: 8),
                          ...depts.map((dept) {
                            final isSel = modalFilterDeptId == dept.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(dept.name),
                                selected: isSel,
                                onSelected: (_) {
                                  setModalState(() => modalFilterDeptId = isSel ? null : dept.id);
                                },
                                selectedColor: WireframeColor.appcolor,
                                backgroundColor: const Color(0xffF8FAFC),
                                labelStyle: sansproSemibold.copyWith(
                                  fontSize: 11.5,
                                  color: isSel ? Colors.white : const Color(0xff475569),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSel ? WireframeColor.appcolor : const Color(0xffCBD5E1),
                                  ),
                                ),
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),
                  const Divider(color: Color(0xffF1F5F9), height: 1),

                  // Employees List
                  Expanded(
                    child: Obx(() {
                      if (complainCtrl.isEmpLoading.value && complainCtrl.employees.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(color: WireframeColor.appcolor),
                        );
                      }

                      final emps = complainCtrl.employees;
                      final query = _employeeSearchController.text.trim().toLowerCase();

                      final filtered = emps.where((emp) {
                        // Department filter
                        if (modalFilterDeptId != null) {
                          if (emp.department != null && emp.department!.id != modalFilterDeptId) {
                            return false;
                          }
                        }
                        // Query filter
                        if (query.isNotEmpty) {
                          final n = emp.name.toLowerCase();
                          final d = emp.designation.toLowerCase();
                          final deptName = (emp.department?.name ?? '').toLowerCase();
                          final uid = emp.employeeUid.toLowerCase();
                          if (!n.contains(query) && !d.contains(query) && !deptName.contains(query) && !uid.contains(query)) {
                            return false;
                          }
                        }
                        return true;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 42, color: Color(0xff94A3B8)),
                                const SizedBox(height: 10),
                                Text(
                                  'No staff or teacher found',
                                  style: sansproSemibold.copyWith(fontSize: 14.5, color: const Color(0xff334155)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  modalFilterDeptId != null
                                      ? 'Try selecting "All Departments" or clear search'
                                      : 'Try searching with another name or title',
                                  style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xffF8FAFC), height: 1),
                        itemBuilder: (context, idx) {
                          final emp = filtered[idx];
                          final isSelected = _selectedEmployeeId == emp.id;
                          final desig = emp.designation.isNotEmpty
                              ? emp.designation
                              : (emp.department?.name ?? 'Staff');
                          final deptTitle = emp.department?.name ?? '';

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedEmployeeId = emp.id;
                              });
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? WireframeColor.appcolor.withAlpha(15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: WireframeColor.appcolor.withAlpha(60))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? WireframeColor.appcolor
                                          : const Color(0xffEEF2FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      emp.name.isNotEmpty ? emp.name.substring(0, 1).toUpperCase() : 'E',
                                      style: sansproBold.copyWith(
                                        fontSize: 15,
                                        color: isSelected ? Colors.white : WireframeColor.appcolor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp.name,
                                          style: sansproBold.copyWith(
                                            fontSize: 13.5,
                                            color: isSelected ? WireframeColor.appcolor : const Color(0xff0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                desig,
                                                style: sansproRegular.copyWith(
                                                  fontSize: 12,
                                                  color: const Color(0xff64748B),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (deptTitle.isNotEmpty && deptTitle != desig) ...[
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xffF1F5F9),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    deptTitle,
                                                    style: sansproSemibold.copyWith(
                                                      fontSize: 10,
                                                      color: const Color(0xff475569),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (isSelected)
                                    const Icon(Icons.check_circle_rounded, color: WireframeColor.appcolor, size: 20)
                                  else
                                    const Icon(Icons.chevron_right_rounded, color: Color(0xffCBD5E1), size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PageAppBar(
        title: 'Feedback',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              complainCtrl.fetchComplaints();
              complainCtrl.fetchDepartments();
              complainCtrl.fetchEmployees();
            },
          ),
        ],
      ),
      backgroundColor: WireframeColor.appcolor,
      body: PageBackground(
        category: PageCategory.complain,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 14),

            // ── Modern Corporate Segmented Tab Bar ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w / 22),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withAlpha(35)),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0.0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: WireframeColor.appcolor,
                  unselectedLabelColor: Colors.white.withAlpha(220),
                  labelStyle: sansproBold.copyWith(fontSize: 13.5),
                  unselectedLabelStyle: sansproSemibold.copyWith(fontSize: 13.5),
                  tabs: [
                    const Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('New Feedback'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history_rounded, size: 16),
                          const SizedBox(width: 6),
                          Obx(() => Text('History (${complainCtrl.complaintsList.length})')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: h / 65),

            // ── Tab Views Container ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFormTab(w, h),
                    _buildHistoryTab(w, h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: FORM TAB
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFormTab(double w, double h) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 45),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Student Context Card
            _buildStudentSummaryCard(w, h),

            SizedBox(height: h / 45),

            // 2. Target Selector: Department vs Employee
            Text(
              'Complaint Target *',
              style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
            ),
            SizedBox(height: h / 100),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _againstType = 'department'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _againstType == 'department' ? WireframeColor.appcolor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _againstType == 'department' ? WireframeColor.appcolor : const Color(0xffCBD5E1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.domain_rounded,
                            size: 16,
                            color: _againstType == 'department' ? Colors.white : const Color(0xff475569),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Department',
                              style: sansproSemibold.copyWith(
                                fontSize: 12.5,
                                color: _againstType == 'department' ? Colors.white : const Color(0xff475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _againstType = 'employee'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _againstType == 'employee' ? WireframeColor.appcolor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _againstType == 'employee' ? WireframeColor.appcolor : const Color(0xffCBD5E1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: _againstType == 'employee' ? Colors.white : const Color(0xff475569),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Staff / Teacher',
                              style: sansproSemibold.copyWith(
                                fontSize: 12.5,
                                color: _againstType == 'employee' ? Colors.white : const Color(0xff475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: h / 45),

            // 3. Department or Employee Selection
            if (_againstType == 'department') ...[
              Text(
                'Department *',
                style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
              ),
              SizedBox(height: h / 100),
              Obx(() {
                final depts = complainCtrl.departments;
                if (depts.isEmpty && complainCtrl.isDeptLoading.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.domain_rounded, size: 16, color: Color(0xff64748B)),
                        const SizedBox(width: 8),
                        Text(
                          'Loading departments...',
                          style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff64748B)),
                        ),
                      ],
                    ),
                  );
                }

                final selectedDept = _selectedDepartmentId != null
                    ? depts.firstWhereOrNull((d) => d.id == _selectedDepartmentId)
                    : null;

                return InkWell(
                  onTap: depts.isEmpty && complainCtrl.isDeptLoading.value
                      ? null
                      : () => _openDepartmentSearchPicker(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedDept != null
                            ? WireframeColor.appcolor.withAlpha(120)
                            : const Color(0xffCBD5E1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.domain_rounded, size: 18, color: Color(0xff64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedDept != null
                                ? selectedDept.name
                                : '-- Select Department --',
                            style: sansproRegular.copyWith(
                              fontSize: 13,
                              color: selectedDept != null ? const Color(0xff0F172A) : const Color(0xff94A3B8),
                              fontWeight: selectedDept != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xffF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.search_rounded, size: 16, color: Color(0xff64748B)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ] else ...[
              Text(
                'Select Staff / Teacher / Employee *',
                style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
              ),
              SizedBox(height: h / 100),
              Obx(() {
                final emps = complainCtrl.employees;
                if (emps.isEmpty && complainCtrl.isEmpLoading.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 16, color: Color(0xff64748B)),
                        const SizedBox(width: 8),
                        Text(
                          'Loading school employees...',
                          style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff64748B)),
                        ),
                      ],
                    ),
                  );
                }

                final selectedEmp = _selectedEmployeeId != null
                    ? emps.firstWhereOrNull((e) => e.id == _selectedEmployeeId)
                    : null;

                return InkWell(
                  onTap: emps.isEmpty && complainCtrl.isEmpLoading.value
                      ? null
                      : () => _openEmployeeSearchPicker(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedEmp != null
                            ? WireframeColor.appcolor.withAlpha(120)
                            : const Color(0xffCBD5E1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 18, color: Color(0xff64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedEmp != null
                                ? '${selectedEmp.name} (${selectedEmp.designation.isNotEmpty ? selectedEmp.designation : (selectedEmp.department?.name ?? "Staff")})'
                                : '-- Select Staff / Teacher / Employee --',
                            style: sansproRegular.copyWith(
                              fontSize: 13,
                              color: selectedEmp != null ? const Color(0xff0F172A) : const Color(0xff94A3B8),
                              fontWeight: selectedEmp != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xffF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.search_rounded, size: 16, color: Color(0xff64748B)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            SizedBox(height: h / 40),

            // 4. Priority Level
            Text(
              'Urgency / Priority *',
              style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
            ),
            SizedBox(height: h / 100),
            Row(
              children: [
                _priorityButton('Normal', 'normal'),
                const SizedBox(width: 8),
                _priorityButton('Urgent', 'high'),
                const SizedBox(width: 8),
                _priorityButton('Low', 'low'),
              ],
            ),

            SizedBox(height: h / 40),

            // 5. Contact Phone
            Text(
              'Guardian Contact Number *',
              style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
            ),
            SizedBox(height: h / 120),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.black),
              decoration: _inputDecoration(
                hint: 'e.g. 017XXXXXXXX',
                prefixIcon: Icons.phone_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a contact phone number';
                return null;
              },
            ),

            SizedBox(height: h / 40),

            // 6. Subject
            Text(
              'Subject / Title *',
              style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
            ),
            SizedBox(height: h / 120),
            TextFormField(
              controller: _subjectController,
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.black),
              decoration: _inputDecoration(
                hint: 'Brief summary of the issue...',
                prefixIcon: Icons.edit_note_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a subject';
                if (v.trim().length < 4) return 'Subject must be at least 4 characters';
                return null;
              },
            ),

            SizedBox(height: h / 40),

            // 7. Detailed Description
            Text(
              'Detailed Description *',
              style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
            ),
            SizedBox(height: h / 140),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 600,
              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.black, height: 1.4),
              decoration: _inputDecoration(
                hint: 'Please provide full details regarding your feedback or suggestion...',
                prefixIcon: null,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please write your feedback details';
                if (v.trim().length < 15) return 'Please provide at least 15 characters of detail';
                return null;
              },
            ),

            SizedBox(height: h / 60),

            // 8. Confidentiality Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffC7D2FE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.security_rounded, color: Color(0xff3730A3), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All feedback submitted via this app is strictly confidential and handled directly by school administration.',
                      style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff3730A3), height: 1.35),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h / 36),

            // 9. Submit Button
            Obx(() => InkWell(
              onTap: complainCtrl.isSubmitting.value ? null : _handleSubmit,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [WireframeColor.appcolor, Color(0xff1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: WireframeColor.appcolor.withAlpha(70),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: complainCtrl.isSubmitting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Submit Feedback',
                            style: sansproBold.copyWith(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      ),
              ),
            )),

            SizedBox(height: h / 30),
          ],
        ),
      ),
    );
  }

  Widget _priorityButton(String label, String value) {
    final isSelected = _selectedPriority == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPriority = value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? WireframeColor.appcolor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? WireframeColor.appcolor : const Color(0xffCBD5E1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: sansproSemibold.copyWith(
              fontSize: 12.5,
              color: isSelected ? Colors.white : const Color(0xff475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: HISTORY TAB (With Working Stage & Priority Filters + Search)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHistoryTab(double w, double h) {
    return Obx(() {
      if (complainCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: WireframeColor.appcolor),
        );
      }

      final allList = complainCtrl.complaintsList;

      if (allList.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w / 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xffEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inbox_outlined, color: WireframeColor.appcolor, size: 48),
                ),
                const SizedBox(height: 18),
                Text(
                  'No Feedback Submitted',
                  style: sansproBold.copyWith(fontSize: 17, color: WireframeColor.black),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have not submitted any complaints yet. Use the "New Complain" tab to send your feedback or concern.',
                  textAlign: TextAlign.center,
                  style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray, height: 1.4),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Write Feedback'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WireframeColor.appcolor,
                    side: const BorderSide(color: WireframeColor.appcolor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final searchKey = _historySearchController.text.trim().toLowerCase();

      // Filter list accurately by real API stages, priority, and search keyword
      final filteredList = allList.where((item) {
        final st = item.status.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');

        // Status Filter
        if (_historyStatusFilter != 'All') {
          if (_historyStatusFilter == 'Submitted') {
            if (st != 'submitted' && st != 'received' && st != 'pending' && st != 'new' && st != 'open') return false;
          } else if (_historyStatusFilter == 'Under Review') {
            if (st != 'under_review' && st != 'reviewing' && st != 'in_review' && st != 'investigating') return false;
          } else if (_historyStatusFilter == 'Action Taken') {
            if (st != 'action_taken' && st != 'in_progress' && st != 'processing' && st != 'escalated') return false;
          } else if (_historyStatusFilter == 'Resolved') {
            if (st != 'resolved' && st != 'closed' && st != 'completed' && st != 'solved') return false;
          } else if (_historyStatusFilter == 'Rejected') {
            if (st != 'rejected' && st != 'declined' && st != 'cancelled') return false;
          }
        }

        // Priority Filter
        if (_historyPriorityFilter != 'All') {
          final p = item.priority.toLowerCase().trim();
          if (_historyPriorityFilter == 'Urgent' && p != 'high' && p != 'urgent') return false;
          if (_historyPriorityFilter == 'Normal' && p != 'normal' && p != 'medium') return false;
          if (_historyPriorityFilter == 'Low' && p != 'low') return false;
        }

        // Search Filter
        if (searchKey.isNotEmpty) {
          final tNo = item.ticketNo.toLowerCase();
          final subj = item.subject.toLowerCase();
          final desc = item.description.toLowerCase();
          final cat = item.category.toLowerCase();
          final admin = (item.adminNote ?? '').toLowerCase();
          if (!tNo.contains(searchKey) &&
              !subj.contains(searchKey) &&
              !desc.contains(searchKey) &&
              !cat.contains(searchKey) &&
              !admin.contains(searchKey)) {
            return false;
          }
        }

        return true;
      }).toList();

      final statusOptions = ['All', 'Submitted', 'Under Review', 'Action Taken', 'Resolved', 'Rejected'];
      final priorityOptions = ['All', 'Urgent', 'Normal', 'Low'];

      return RefreshIndicator(
        onRefresh: () => complainCtrl.fetchComplaints(),
        color: WireframeColor.appcolor,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 50),
          children: [
            // Search Bar for History
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: TextField(
                controller: _historySearchController,
                style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff0F172A)),
                decoration: InputDecoration(
                  hintText: 'Search feedback by ticket, topic, keyword...',
                  hintStyle: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xff64748B), size: 18),
                  suffixIcon: _historySearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xff64748B)),
                          onPressed: () {
                            _historySearchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 12),

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statusOptions.map((f) {
                  final isSelected = _historyStatusFilter == f;
                  int count = 0;
                  if (f == 'All') {
                    count = allList.length;
                  } else {
                    count = allList.where((item) {
                      final st = item.status.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');
                      if (f == 'Submitted') return st == 'submitted' || st == 'received' || st == 'pending' || st == 'new' || st == 'open';
                      if (f == 'Under Review') return st == 'under_review' || st == 'reviewing' || st == 'in_review' || st == 'investigating';
                      if (f == 'Action Taken') return st == 'action_taken' || st == 'in_progress' || st == 'processing' || st == 'escalated';
                      if (f == 'Resolved') return st == 'resolved' || st == 'closed' || st == 'completed' || st == 'solved';
                      if (f == 'Rejected') return st == 'rejected' || st == 'declined' || st == 'cancelled';
                      return false;
                    }).length;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$f ($count)'),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _historyStatusFilter = f),
                      selectedColor: WireframeColor.appcolor,
                      backgroundColor: Colors.white,
                      labelStyle: sansproSemibold.copyWith(
                        fontSize: 11.5,
                        color: isSelected ? Colors.white : const Color(0xff475569),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? WireframeColor.appcolor : const Color(0xffCBD5E1),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // Priority Filter Chips
            Row(
              children: [
                Text(
                  'Priority: ',
                  style: sansproSemibold.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: priorityOptions.map((p) {
                        final isSel = _historyPriorityFilter == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _historyPriorityFilter = p),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xff0B1E4D) : const Color(0xffF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSel ? const Color(0xff0B1E4D) : const Color(0xffE2E8F0),
                                ),
                              ),
                              child: Text(
                                p == 'All' ? 'All Priorities' : p,
                                style: sansproSemibold.copyWith(
                                  fontSize: 10.5,
                                  color: isSel ? Colors.white : const Color(0xff475569),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: h / 70),

            if (filteredList.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: h / 20),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xffF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.filter_alt_off_rounded, color: Color(0xff94A3B8), size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No matching feedback found',
                        style: sansproSemibold.copyWith(fontSize: 14.5, color: const Color(0xff475569)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try clearing filters or search keyword',
                        style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff94A3B8)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filteredList.map((item) => _buildComplainCard(item, w, h)),
          ],
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStudentSummaryCard(double w, double h) {
    return Obx(() {
      final p = studentCtrl.profile.value;
      final name = p?.studentName.isNotEmpty == true ? p!.studentName : 'Student';
      final roll = p?.rollNo.isNotEmpty == true ? p!.rollNo : (p?.studentId ?? '');
      final cls = p?.className.isNotEmpty == true ? p!.className : '';
      final sec = p?.section.isNotEmpty == true ? p!.section : '';
      final session = resolveCurrentAcademicSession(p?.academicYear);
      final photo = p?.profilePhotoUrl ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: WireframeColor.appcolor.withAlpha(40), width: 1.5),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roll.isNotEmpty ? '$name ($roll)' : name,
                    style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0B1E4D)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cls.isNotEmpty ? 'Class: $cls - $sec  ·  Session: $session' : 'Session: $session',
                    style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildComplainCard(ComplaintItem item, double w, double h) {
    Color statusBg = const Color(0xffFEF3C7);
    Color statusText = const Color(0xffD97706);
    String displayStatus = 'SUBMITTED';

    final st = item.status.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');
    if (st == 'resolved' || st == 'closed' || st == 'completed' || st == 'solved') {
      statusBg = const Color(0xffDCFCE7);
      statusText = const Color(0xff16A34A);
      displayStatus = 'RESOLVED';
    } else if (st == 'under_review' || st == 'reviewing' || st == 'in_review' || st == 'investigating') {
      statusBg = const Color(0xffEFF6FF);
      statusText = const Color(0xff2563EB);
      displayStatus = 'UNDER REVIEW';
    } else if (st == 'action_taken' || st == 'in_progress' || st == 'processing' || st == 'escalated') {
      statusBg = const Color(0xffEDE9FE);
      statusText = const Color(0xff7C3AED);
      displayStatus = 'ACTION TAKEN';
    } else if (st == 'rejected' || st == 'declined' || st == 'cancelled') {
      statusBg = const Color(0xffFEE2E2);
      statusText = const Color(0xffDC2626);
      displayStatus = 'REJECTED';
    } else {
      statusBg = const Color(0xffFEF3C7);
      statusText = const Color(0xffD97706);
      displayStatus = 'SUBMITTED';
    }

    // Priority badge styling
    Color priBg = const Color(0xffF1F5F9);
    Color priText = const Color(0xff475569);
    final pLower = item.priority.toLowerCase().trim();
    if (pLower == 'high' || pLower == 'urgent') {
      priBg = const Color(0xffFEE2E2);
      priText = const Color(0xffDC2626);
    } else if (pLower == 'normal' || pLower == 'medium') {
      priBg = const Color(0xffEFF6FF);
      priText = const Color(0xff1D4ED8);
    } else if (pLower == 'low') {
      priBg = const Color(0xffF1F5F9);
      priText = const Color(0xff64748B);
    }

    final hasAdminMsg = item.adminNote != null && item.adminNote!.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: h / 65),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
              Text(
                item.ticketNo,
                style: sansproBold.copyWith(fontSize: 12.5, color: WireframeColor.appcolor),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category,
                    style: sansproSemibold.copyWith(fontSize: 10.5, color: const Color(0xff475569)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.priorityLabel,
                  style: sansproBold.copyWith(fontSize: 10, color: priText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayStatus,
                  style: sansproBold.copyWith(fontSize: 9.5, color: statusText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.subject,
            style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0F172A)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xff94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.createdAt,
                  style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff94A3B8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xffF1F5F9), height: 1),
          const SizedBox(height: 10),
          Text(
            'Complaint Details:',
            style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff475569)),
          ),
          const SizedBox(height: 5),
          Text(
            item.description,
            style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff334155), height: 1.45),
          ),
          if (item.contactPhone != null && item.contactPhone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 13, color: Color(0xff64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Contact Phone: ${item.contactPhone}',
                    style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (hasAdminMsg) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, size: 17, color: Color(0xff15803D)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Administration Reply:',
                          style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff15803D)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.response?.respondedAt != null && item.response!.respondedAt.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.response!.respondedAt,
                          style: sansproRegular.copyWith(fontSize: 11, color: const Color(0xff166534).withAlpha(180)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.adminNote!,
                    style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff166534), height: 1.45),
                  ),
                  if (item.assignedTo != null && item.assignedTo!.name.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xff15803D)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Assigned to: ${item.assignedTo!.name}',
                            style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff15803D)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ] else if (st == 'under_review' || st == 'action_taken' || st == 'resolved') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(
                    st == 'resolved' ? Icons.check_circle_outline_rounded : Icons.pending_outlined,
                    size: 15,
                    color: st == 'resolved' ? const Color(0xff16A34A) : const Color(0xff2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      st == 'resolved'
                          ? 'This complaint has been addressed and marked as resolved by the administration.'
                          : (st == 'action_taken'
                              ? 'Action has been initiated regarding this complaint by the administration.'
                              : 'This complaint is currently under review by the school administration.'),
                      style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff475569)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff94A3B8)),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xff64748B), size: 18) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WireframeColor.appcolor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
