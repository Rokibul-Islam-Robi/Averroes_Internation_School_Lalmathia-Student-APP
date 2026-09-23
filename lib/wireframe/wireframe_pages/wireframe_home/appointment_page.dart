import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'appointment_controller.dart';
import 'appointment_recipient_select_page.dart';
import 'notification_page.dart';
import 'student_controller.dart';
import 'page_background.dart';

class AppointmentPage extends StatefulWidget {
  final int initialTabIndex;
  const AppointmentPage({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentController apptCtrl = Get.put(AppointmentController());
  final StudentController studentCtrl = Get.put(StudentController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _attendeeNameController = TextEditingController();
  final TextEditingController _attendeePhoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int _currentStep = 0; // Step 0: Staff, Step 1: Purpose & Agenda, Step 2: Date & Time, Step 3: Attendee & Submit
  AppointmentRecipient? _selectedRecipient;
  DateTime? _selectedDate;
  String _selectedTimeSlot = '10:00 AM - 10:30 AM';
  String _attendeeRelation = 'Father';
  String _selectedPurposeValue = 'academic';
  String _historyStatusFilter = 'All';

  final List<String> _timeSlots = [
    '09:30 AM - 10:00 AM',
    '10:00 AM - 10:30 AM',
    '10:30 AM - 11:00 AM',
    '11:00 AM - 11:30 AM',
    '11:30 AM - 12:00 PM',
    '01:30 PM - 02:00 PM',
    '02:00 PM - 02:30 PM',
    '02:30 PM - 03:00 PM',
  ];

  final List<String> _relations = [
    'Father',
    'Mother',
    'Legal Guardian',
    'Brother',
    'Sister',
    'Uncle',
    'Aunt',
    'Self (Student)',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );

    // Initial fetch of real API data
    apptCtrl.fetchRecipients();
    apptCtrl.fetchAppointments();

    // Pre-fill student and guardian info from real logged-in session
    _prefillAttendeeInfo();

    // Default preferred date = Tomorrow (or next Sunday if Fri/Sat)
    _initDefaultDate();
  }

  void _prefillAttendeeInfo() {
    final p = studentCtrl.profile.value;
    if (p != null) {
      if (p.guardians.isNotEmpty) {
        final g = p.guardians.first;
        if (g.name.isNotEmpty) {
          _attendeeNameController.text = g.name;
        }
        if (g.relation.isNotEmpty) {
          final match = _relations.firstWhereOrNull((r) => r.toLowerCase() == g.relation.toLowerCase());
          if (match != null) _attendeeRelation = match;
        }
        if (g.phone.isNotEmpty) {
          _attendeePhoneController.text = g.phone;
        }
      }

      if (_attendeePhoneController.text.isEmpty) {
        if (p.contactNumber.isNotEmpty) {
          _attendeePhoneController.text = p.contactNumber;
        } else if (p.accountPhone.isNotEmpty) {
          _attendeePhoneController.text = p.accountPhone;
        }
      }
    }
  }

  void _initDefaultDate() {
    DateTime next = DateTime.now().add(const Duration(days: 1));
    while (next.weekday == DateTime.friday || next.weekday == DateTime.saturday) {
      next = next.add(const Duration(days: 1));
    }
    _selectedDate = next;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _detailsController.dispose();
    _attendeeNameController.dispose();
    _attendeePhoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, String?> _parseTimeSlot(String slot) {
    // e.g. "10:00 AM - 10:30 AM" or "01:30 PM - 02:00 PM"
    final parts = slot.split('-');
    if (parts.length == 2) {
      return {
        'start': _to24Hour(parts[0].trim()),
        'end': _to24Hour(parts[1].trim()),
      };
    }
    return {'start': null, 'end': null};
  }

  String? _to24Hour(String timeStr) {
    try {
      final clean = timeStr.toUpperCase().trim();
      final isPm = clean.endsWith('PM');
      final isAm = clean.endsWith('AM');
      final timeOnly = clean.replaceAll('AM', '').replaceAll('PM', '').trim();
      final timeParts = timeOnly.split(':');
      int hour = int.parse(timeParts[0].trim());
      final minute = timeParts.length > 1 ? timeParts[1].trim().padLeft(2, '0') : '00';
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (_) {
      return null;
    }
  }

  String _formatApiDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRecipient == null) {
      Get.snackbar(
        'Staff Selection Required',
        'Please select a Principal, Vice Principal, or Teacher to request an appointment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xffFEF2F2),
        colorText: const Color(0xff991B1B),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_selectedDate == null) {
      Get.snackbar(
        'Date Required',
        'Please select your preferred appointment date.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xffFEF2F2),
        colorText: const Color(0xff991B1B),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final times = _parseTimeSlot(_selectedTimeSlot);
    final apiDate = _formatApiDate(_selectedDate!);

    final result = await apptCtrl.submitAppointment(
      recipientEmployeeId: _selectedRecipient!.employeeId,
      purpose: _selectedPurposeValue,
      subject: _subjectController.text.trim(),
      details: _detailsController.text.trim(),
      preferredDate: apiDate,
      preferredStartTime: times['start'],
      preferredEndTime: times['end'],
      attendeeName: _attendeeNameController.text.trim(),
      attendeeRelation: _attendeeRelation,
      attendeePhone: _attendeePhoneController.text.trim(),
    );

    if (result['success'] == true) {
      _subjectController.clear();
      _detailsController.clear();
      setState(() {
        _currentStep = 0;
      });

      if (!mounted) return;
      final AppointmentItem? created = result['item'] as AppointmentItem?;
      if (created != null) {
        _showSuccessDialog(created);
      } else {
        Get.snackbar(
          'Appointment Submitted',
          result['message'] ?? 'Appointment request submitted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffDCFCE7),
          colorText: const Color(0xff166534),
          margin: const EdgeInsets.all(16),
        );
        _tabController.animateTo(1);
      }
    } else {
      if (!mounted) return;
      Get.snackbar(
        'Submission Failed',
        result['message'] ?? 'Unable to submit appointment request. Please review the form and try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xffFEF2F2),
        colorText: const Color(0xff991B1B),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _showSuccessDialog(AppointmentItem item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xffDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xff16A34A), size: 42),
              ),
              const SizedBox(height: 16),
              Text(
                'Appointment Requested!',
                style: sansproBold.copyWith(fontSize: 20, color: WireframeColor.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment request with ${item.recipient.name} (${item.recipient.designation}) has been submitted to the ERP server.',
                style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffCBD5E1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_rounded, size: 16, color: Color(0xff0284C7)),
                    const SizedBox(width: 8),
                    Text(
                      'Appointment No: ',
                      style: sansproRegular.copyWith(fontSize: 12.5, color: WireframeColor.textgray),
                    ),
                    Text(
                      item.appointmentNo,
                      style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffBAE6FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, size: 15, color: Color(0xff0284C7)),
                        const SizedBox(width: 6),
                        Text(
                          'Real-Time Status & SMS Notification',
                          style: sansproSemibold.copyWith(fontSize: 12, color: const Color(0xff0369A1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'When school leadership/faculty accepts and schedules your consultation, you will receive an SMS and in-app update with the confirmed meeting date, time, and venue.',
                      style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff334155), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xffCBD5E1)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _tabController.animateTo(1);
                      },
                      child: Text(
                        'View History',
                        style: sansproSemibold.copyWith(fontSize: 13.5, color: const Color(0xff334155)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WireframeColor.appcolor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Done',
                        style: sansproSemibold.copyWith(fontSize: 13.5, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          title: "Appointment".tr,
          actions: [
            Obx(() {
              final list = apptCtrl.appointmentsList;
              final unreadCount = list.where((a) => a.hasUpdate).length;
              final scheduledCount = list.where((a) => a.isScheduled).length;
              final badgeCount = unreadCount > 0 ? unreadCount : scheduledCount;
              final showBadge = unreadCount > 0 || scheduledCount > 0;

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Appointment Notifications & Alerts',
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 23),
                    onPressed: () => _showAppointmentNotificationsSheet(context),
                  ),
                  if (showBadge)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: unreadCount > 0 ? const Color(0xffEF4444) : const Color(0xff10B981),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
            IconButton(
              tooltip: 'Refresh Appointments',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                apptCtrl.fetchAppointments();
                apptCtrl.fetchRecipients();
                Get.snackbar(
                  'Refreshing',
                  'Fetching latest appointment status from school server...',
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
              // ── Tab Bar ──
              Container(
                margin: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 100),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xff64748B),
                  labelStyle: sansproBold.copyWith(fontSize: 13.5),
                  unselectedLabelStyle: sansproSemibold.copyWith(fontSize: 13.5),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_calendar_rounded, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Book_Appointment".tr,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Obx(() {
                        final list = apptCtrl.appointmentsList;
                        final count = list.length;
                        final hasUnread = list.any((a) => a.hasUpdate);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.history_toggle_off_rounded, size: 16),
                                if (hasUnread)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xffEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                count > 0 ? "My Appointments ($count)" : "My_Appointments".tr,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // ── Tab Bar View ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingFormTab(width: width, height: height),
                    _buildHistoryTrackingTab(width: width, height: height),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: BOOKING FORM
  // ══════════════════════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1: STEP-BY-STEP BOOKING FLOW (Modern & Corporate Multi-Step Stepper)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBookingFormTab({required double width, required double height}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 90),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Student identity snapshot banner
            _buildStudentSummaryBanner(),
            const SizedBox(height: 12),

            // Live Appointment Notification / Scheduled Meeting Alert Banner (if any)
            _buildActiveNotificationsNotice(),
            const SizedBox(height: 4),

            // 2. Corporate Multi-Step Stepper Progress Bar
            _buildStepperHeader(),
            const SizedBox(height: 10),

            // 3. Current Step Content
            // ── STEP 1: Select Principal / Vice Principal / Leadership / Teacher ──
            if (_currentStep == 0) ...[
              _buildSectionHeader(
                title: 'Step 1 of 4: Select Faculty or Leadership',
                subtitle: 'Choose Principal, Vice Principal, Leadership, or Subject Teacher',
                icon: Icons.person_search_rounded,
              ),
              const SizedBox(height: 12),
              _buildRecipientSelector(),
              const SizedBox(height: 20),
              _buildStepNavigationButtons(
                showBack: false,
                nextLabel: 'Next: Meeting Purpose & Agenda',
                onNext: () => _tryGoToStep(1),
              ),
            ]
            // ── STEP 2: Meeting Purpose, Subject & Details ──
            else if (_currentStep == 1) ...[
              _buildSelectedRecipientMiniBadge(),
              const SizedBox(height: 14),
              _buildSectionHeader(
                title: 'Step 2 of 4: Meeting Purpose & Subject Agenda',
                subtitle: 'Select consultation purpose and explain discussion topics',
                icon: Icons.topic_rounded,
              ),
              const SizedBox(height: 12),
              _buildPurposeAndSubjectSection(),
              const SizedBox(height: 20),
              _buildStepNavigationButtons(
                showBack: true,
                nextLabel: 'Next: Preferred Date & Time',
                onNext: () => _tryGoToStep(2),
              ),
            ]
            // ── STEP 3: Preferred Date & Time Slot ──
            else if (_currentStep == 2) ...[
              _buildSelectedRecipientMiniBadge(),
              const SizedBox(height: 14),
              _buildSectionHeader(
                title: 'Step 3 of 4: Preferred Date & Time Slot',
                subtitle: 'Select your preferred consultation date & time slot (next 120 days)',
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(height: 12),
              _buildDateTimeSelection(width: width),
              const SizedBox(height: 20),
              _buildStepNavigationButtons(
                showBack: true,
                nextLabel: 'Next: Attendee Information',
                onNext: () => _tryGoToStep(3),
              ),
            ]
            // ── STEP 4: Guardian / Attendee Contact & Final Confirmation ──
            else if (_currentStep == 3) ...[
              _buildSectionHeader(
                title: 'Step 4 of 4: Guardian / Attendee Contact & Review',
                subtitle: 'Review consultation booking overview and confirm attendance',
                icon: Icons.assignment_turned_in_rounded,
              ),
              const SizedBox(height: 12),
              _buildAttendeeContactSection(),
              const SizedBox(height: 16),
              _buildBookingReviewSummaryCard(),
              const SizedBox(height: 16),
              _buildExecutiveNoticeCard(),
              const SizedBox(height: 20),
              _buildFinalSubmitRow(),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Corporate Stepper Header ──
  Widget _buildStepperHeader() {
    final steps = [
      {'title': 'Staff', 'icon': Icons.person_rounded},
      {'title': 'Purpose', 'icon': Icons.topic_rounded},
      {'title': 'Date & Time', 'icon': Icons.event_available_rounded},
      {'title': 'Attendee', 'icon': Icons.assignment_turned_in_rounded},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final prevStep = index ~/ 2;
            final isDone = _currentStep > prevStep;
            return Expanded(
              child: Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDone ? WireframeColor.appcolor : const Color(0xffE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIdx = index ~/ 2;
          final isCurrent = _currentStep == stepIdx;
          final isDone = _currentStep > stepIdx;
          final stepData = steps[stepIdx];

          return InkWell(
            onTap: () {
              if (stepIdx < _currentStep) {
                setState(() => _currentStep = stepIdx);
              } else if (stepIdx > _currentStep) {
                _tryGoToStep(stepIdx);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? WireframeColor.appcolor
                        : (isDone ? const Color(0xffDCFCE7) : const Color(0xffF1F5F9)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? WireframeColor.appcolor
                          : (isDone ? const Color(0xff16A34A) : const Color(0xffCBD5E1)),
                      width: isCurrent ? 2 : 1.2,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: WireframeColor.appcolor.withAlpha(50),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, size: 16, color: Color(0xff15803D))
                        : Text(
                            '${stepIdx + 1}',
                            style: sansproBold.copyWith(
                              fontSize: 12.5,
                              color: isCurrent ? Colors.white : const Color(0xff64748B),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepData['title'] as String,
                  style: isCurrent
                      ? sansproBold.copyWith(fontSize: 11, color: WireframeColor.appcolor)
                      : (isDone
                          ? sansproSemibold.copyWith(fontSize: 10.5, color: const Color(0xff15803D))
                          : sansproRegular.copyWith(fontSize: 10.5, color: const Color(0xff94A3B8))),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Selected Recipient Mini Badge ──
  Widget _buildSelectedRecipientMiniBadge() {
    final rec = _selectedRecipient;
    if (rec == null) return const SizedBox.shrink();

    Color badgeBg = const Color(0xffFEF3C7);
    Color badgeFg = const Color(0xffB45309);
    String roleTag = 'Faculty Teacher';
    if (rec.isPrincipal) {
      badgeBg = const Color(0xffEDE9FE);
      badgeFg = const Color(0xff6D28D9);
      roleTag = 'Principal';
    } else if (rec.isVicePrincipal) {
      badgeBg = const Color(0xffDCFCE7);
      badgeFg = const Color(0xff15803D);
      roleTag = 'Vice Principal';
    } else if (rec.isLeadership) {
      badgeBg = const Color(0xffE0F2FE);
      badgeFg = const Color(0xff0369A1);
      roleTag = 'Leadership';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF0F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WireframeColor.appcolor.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, size: 16, color: badgeFg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        rec.name,
                        style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roleTag,
                        style: sansproBold.copyWith(fontSize: 9.5, color: badgeFg),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${rec.designation} · ${rec.department}',
                  style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() => _currentStep = 0);
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xffCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_horiz_rounded, size: 13, color: WireframeColor.appcolor),
                  const SizedBox(width: 3),
                  Text(
                    'Change',
                    style: sansproBold.copyWith(fontSize: 11, color: WireframeColor.appcolor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Navigation Buttons (Modern & Corporate) ──
  Widget _buildStepNavigationButtons({
    required VoidCallback onNext,
    required String nextLabel,
    IconData nextIcon = Icons.arrow_forward_rounded,
    bool showBack = true,
  }) {
    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffCBD5E1), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xff475569)),
                label: Text(
                  'Back',
                  style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff475569)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: showBack ? 2 : 1,
          child: SizedBox(
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: WireframeColor.appcolor.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        nextLabel,
                        style: sansproBold.copyWith(fontSize: 13.5, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(nextIcon, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step Validation & Navigation ──
  bool _validateStep(int step) {
    if (step == 0) {
      if (_selectedRecipient == null) {
        Get.snackbar(
          'Staff Selection Required',
          'Please choose a Principal, Vice Principal, or Teacher to request an appointment.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      return true;
    } else if (step == 1) {
      if (_subjectController.text.trim().isEmpty) {
        Get.snackbar(
          'Subject Required',
          'Please enter a subject or agenda outline.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      if (_subjectController.text.trim().length < 5) {
        Get.snackbar(
          'Subject Too Short',
          'Subject must be at least 5 characters.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      if (_detailsController.text.trim().isEmpty) {
        Get.snackbar(
          'Explanation Required',
          'Please provide discussion points or explanation.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      if (_detailsController.text.trim().length < 10) {
        Get.snackbar(
          'Explanation Too Short',
          'Please provide at least 10 characters of detail.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      return true;
    } else if (step == 2) {
      if (_selectedDate == null) {
        Get.snackbar(
          'Date Required',
          'Please select your preferred appointment date.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      if (_selectedTimeSlot.isEmpty) {
        Get.snackbar(
          'Time Slot Required',
          'Please select a preferred time slot.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      return true;
    } else if (step == 3) {
      if (_attendeeNameController.text.trim().isEmpty) {
        Get.snackbar(
          'Attendee Name Required',
          'Please enter the full name of the attending parent/guardian.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      if (_attendeePhoneController.text.trim().isEmpty) {
        Get.snackbar(
          'Contact Phone Required',
          'Please enter a contact phone number.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
      return true;
    }
    return true;
  }

  void _tryGoToStep(int targetStep) {
    if (targetStep < _currentStep) {
      setState(() => _currentStep = targetStep);
      return;
    }
    for (int s = 0; s < targetStep; s++) {
      if (!_validateStep(s)) return;
    }
    setState(() => _currentStep = targetStep);
  }

  // ── Final Booking Review Summary Card ──
  Widget _buildBookingReviewSummaryCard() {
    final purposeObj = apptCtrl.purposesList.firstWhereOrNull((p) => p.value == _selectedPurposeValue);
    final purposeLabel = purposeObj?.label ?? _selectedPurposeValue.capitalizeFirst ?? 'General';
    final rec = _selectedRecipient;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xff0B1E4D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.preview_rounded, size: 15, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Appointment Booking Overview',
                style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0B1E4D)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xffE2E8F0), height: 1),
          const SizedBox(height: 10),

          // Faculty
          _buildReviewRow(
            icon: Icons.person_outline_rounded,
            label: 'Faculty',
            value: rec != null ? '${rec.name} (${rec.designation})' : 'Not selected',
            highlight: true,
          ),
          const SizedBox(height: 8),

          // Purpose & Subject
          _buildReviewRow(
            icon: Icons.topic_outlined,
            label: 'Purpose',
            value: '$purposeLabel · ${_subjectController.text.trim()}',
          ),
          const SizedBox(height: 8),

          // Preferred Schedule
          _buildReviewRow(
            icon: Icons.calendar_month_outlined,
            label: 'Schedule',
            value: _selectedDate != null
                ? '${_formatDisplayDate(_selectedDate!)} ($_selectedTimeSlot)'
                : 'Not selected',
          ),
          const SizedBox(height: 8),

          // Attendee
          _buildReviewRow(
            icon: Icons.badge_outlined,
            label: 'Attendee',
            value: '${_attendeeNameController.text.trim()} ($_attendeeRelation) · ${_attendeePhoneController.text.trim()}',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: highlight ? WireframeColor.appcolor : const Color(0xff64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label: ',
              style: sansproSemibold.copyWith(fontSize: 12, color: const Color(0xff475569)),
              children: [
                TextSpan(
                  text: value,
                  style: (highlight ? sansproBold : sansproRegular).copyWith(
                    fontSize: 12,
                    color: highlight ? const Color(0xff0B1E4D) : const Color(0xff0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Final Submit Row for Step 4 ──
  Widget _buildFinalSubmitRow() {
    return Obx(() {
      final isSubmitting = apptCtrl.isSubmitting.value;
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffCBD5E1), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                ),
                onPressed: isSubmitting
                    ? null
                    : () {
                        setState(() => _currentStep = 2);
                      },
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xff475569)),
                label: Text(
                  'Back',
                  style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff475569)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: WireframeColor.appcolor.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Submit Request',
                                style: sansproBold.copyWith(fontSize: 14.5, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // ── Student Summary Mini Banner ──
  Widget _buildStudentSummaryBanner() {
    return Obx(() {
      final p = studentCtrl.profile.value;
      final photoUrl = p?.profilePhotoUrl;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: WireframeColor.appcolor.withAlpha(80), width: 1.5),
              ),
              child: ClipOval(
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                      )
                    : const Icon(Icons.school_rounded, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p?.studentName.isNotEmpty == true ? p!.studentName : 'Averroes Student',
                    style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'ID: ${p?.studentId.isNotEmpty == true ? p!.studentId : "—"}',
                          style: sansproSemibold.copyWith(fontSize: 11.5, color: const Color(0xff0284C7)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xff94A3B8), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Class: ${p?.className.isNotEmpty == true ? p!.className : "—"}${p?.section != null && p!.section.isNotEmpty ? " (${p.section})" : ""}',
                          style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffBBF7D0)),
              ),
              child: Text(
                'Lalmatia',
                style: sansproBold.copyWith(fontSize: 10.5, color: const Color(0xff16A34A)),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Section Header Helper ──
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xff0B1E4D).withAlpha(18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: const Color(0xff0B1E4D)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0F172A)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            subtitle,
            style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
          ),
        ),
      ],
    );
  }

  // ── 1. Recipient Selector Card & Dedicated Search/Filter Page ──
  Widget _buildRecipientSelector() {
    return Obx(() {
      final rec = _selectedRecipient;
      final allRecipients = apptCtrl.recipientsList;

      // If no recipient selected yet, auto-select Principal first, then Vice Principal, then Leadership, then first available
      if (rec == null && allRecipients.isNotEmpty) {
        final principal = allRecipients.firstWhereOrNull((r) => r.isPrincipal) ??
            allRecipients.firstWhereOrNull((r) => r.isPrincipalOrVice) ??
            allRecipients.firstWhereOrNull((r) => r.isLeadership) ??
            allRecipients.firstOrNull;
        _selectedRecipient = principal;
      }

      final activeRec = _selectedRecipient;

      if (activeRec == null) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffCBD5E1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _openRecipientSelectionPage,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_search_rounded,
                        color: Color(0xff4F46E5), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Principal, Vice Principal or Teacher',
                          style: sansproBold.copyWith(
                              fontSize: 13.5, color: const Color(0xff0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          allRecipients.isNotEmpty
                              ? 'Search across ${allRecipients.length} staff & leadership members'
                              : 'Tap to browse staff directory',
                          style: sansproRegular.copyWith(
                              fontSize: 11.5, color: const Color(0xff64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xff0B1E4D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Browse',
                          style: sansproBold.copyWith(
                              fontSize: 11.5, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      Color badgeBg = const Color(0xffFEF3C7);
      Color badgeFg = const Color(0xffB45309);
      IconData roleIcon = Icons.menu_book_rounded;
      String roleTag = 'Faculty Teacher';
      Color tagBg = const Color(0xffFEF3C7);
      Color tagFg = const Color(0xffB45309);

      if (activeRec.isPrincipal) {
        badgeBg = const Color(0xffEDE9FE);
        badgeFg = const Color(0xff6D28D9);
        roleIcon = Icons.psychology_rounded;
        roleTag = 'Principal';
        tagBg = const Color(0xffEDE9FE);
        tagFg = const Color(0xff6D28D9);
      } else if (activeRec.isVicePrincipal) {
        badgeBg = const Color(0xffDCFCE7);
        badgeFg = const Color(0xff15803D);
        roleIcon = Icons.military_tech_rounded;
        roleTag = 'Vice Principal';
        tagBg = const Color(0xffDCFCE7);
        tagFg = const Color(0xff15803D);
      } else if (activeRec.isLeadership) {
        badgeBg = const Color(0xffE0F2FE);
        badgeFg = const Color(0xff0369A1);
        roleIcon = Icons.workspace_premium_rounded;
        roleTag = 'Leadership';
        tagBg = const Color(0xffE0F2FE);
        tagFg = const Color(0xff0369A1);
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffF0F7FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: WireframeColor.appcolor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: WireframeColor.appcolor.withAlpha(16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    child: activeRec.avatarUrl != null && activeRec.avatarUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              activeRec.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(roleIcon, color: badgeFg, size: 26),
                            ),
                          )
                        : Icon(roleIcon, color: badgeFg, size: 26),
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
                                activeRec.name,
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
                          activeRec.designation,
                          style: sansproSemibold.copyWith(
                            fontSize: 12.5,
                            color: const Color(0xff0284C7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.apartment_rounded,
                                size: 13, color: Color(0xff64748B)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                activeRec.department,
                                style: sansproRegular.copyWith(
                                  fontSize: 11.5,
                                  color: const Color(0xff64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (activeRec.officeHours != null &&
                                activeRec.officeHours!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.access_time_rounded,
                                  size: 13, color: Color(0xff64748B)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  activeRec.officeHours!,
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
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xffCBD5E1), height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: Color(0xff16A34A)),
                      const SizedBox(width: 6),
                      Text(
                        'Selected for Consultation',
                        style: sansproSemibold.copyWith(
                            fontSize: 12, color: const Color(0xff15803D)),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _openRecipientSelectionPage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_rounded,
                              size: 14, color: WireframeColor.appcolor),
                          const SizedBox(width: 4),
                          Text(
                            'Change / Search',
                            style: sansproBold.copyWith(
                                fontSize: 11.5,
                                color: WireframeColor.appcolor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openRecipientSelectionPage() async {
    final selected = await Navigator.push<AppointmentRecipient>(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentRecipientSelectPage(
          initialSelected: _selectedRecipient,
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedRecipient = selected;
        // Automatically directs to the Meeting Purpose & Agenda step as requested
        _currentStep = 1;
      });
    }
  }

  // ── 2. Meeting Purpose & Subject Section ──
  Widget _buildPurposeAndSubjectSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultation Purpose',
            style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final purposes = apptCtrl.purposesList;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: purposes.any((p) => p.value == _selectedPurposeValue)
                      ? _selectedPurposeValue
                      : (purposes.isNotEmpty ? purposes.first.value : 'academic'),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: WireframeColor.appcolor),
                  items: purposes.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.value,
                      child: Text(
                        p.label,
                        style: sansproSemibold.copyWith(fontSize: 13, color: const Color(0xff0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPurposeValue = val;
                      });
                    }
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(
            'Subject / Agenda (Required, 5–180 characters)',
            style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _subjectController,
            style: sansproRegular.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Subject is required';
              }
              if (v.trim().length < 5) {
                return 'Subject must be at least 5 characters';
              }
              if (v.trim().length > 180) {
                return 'Subject must be at most 180 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'e.g. Discussion about academic progress and study guidance',
              hintStyle: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: WireframeColor.appcolor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Detailed Explanation / Points (Required, 10–3000 characters)',
            style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _detailsController,
            maxLines: 4,
            style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff0F172A)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Details are required';
              }
              if (v.trim().length < 10) {
                return 'Please provide at least 10 characters of explanation.';
              }
              if (v.trim().length > 3000) {
                return 'Details must be at most 3000 characters.';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Please describe the topics, questions, or guidance needed from the Principal, Vice Principal, or Teacher...',
              hintStyle: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff94A3B8)),
              contentPadding: const EdgeInsets.all(14),
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: WireframeColor.appcolor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Preferred Date & Time Selection ──
  Widget _buildDateTimeSelection({required double width}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Preferred Date (Within next 120 days)',
            style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: WireframeColor.appcolor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null ? _formatDisplayDate(_selectedDate!) : 'Choose Date (Sun - Thu)',
                      style: sansproBold.copyWith(
                        fontSize: 13.5,
                        color: _selectedDate != null ? const Color(0xff0F172A) : const Color(0xff94A3B8),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Change',
                      style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff0284C7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Select Preferred Time Slot',
            style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              return ChoiceChip(
                label: Text(slot),
                labelStyle: sansproSemibold.copyWith(
                  fontSize: 11.5,
                  color: isSelected ? Colors.white : const Color(0xff334155),
                ),
                selected: isSelected,
                selectedColor: WireframeColor.appcolor,
                backgroundColor: const Color(0xffF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? WireframeColor.appcolor : const Color(0xffE2E8F0),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTimeSlot = slot;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final first = now.add(const Duration(days: 1));
    final last = now.add(const Duration(days: 120)); // per doc: up to 120 days

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? first,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: WireframeColor.appcolor,
              onPrimary: Colors.white,
              onSurface: Color(0xff0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.weekday == DateTime.friday) {
        Get.snackbar(
          'Friday Weekend',
          'School office remains closed on Fridays. Please pick a working day (Sunday to Thursday).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xffFEF2F2),
          colorText: const Color(0xff991B1B),
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ── 4. Guardian & Attendee Contact Info ──
  Widget _buildAttendeeContactSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attending Parent / Guardian Name (Required, max 150 chars)',
            style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _attendeeNameController,
            style: sansproRegular.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Attendee name is required';
              if (v.trim().length > 150) return 'Attendee name must be at most 150 characters';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Full name of Parent / Guardian',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: WireframeColor.appcolor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: WireframeColor.appcolor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Relationship (Max 50 chars)',
                      style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xffCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _attendeeRelation,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: WireframeColor.appcolor),
                          items: _relations.map((r) {
                            return DropdownMenuItem<String>(
                              value: r,
                              child: Text(
                                r,
                                style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff0F172A)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _attendeeRelation = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Phone (Max 30 chars)',
                      style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _attendeePhoneController,
                      keyboardType: TextInputType.phone,
                      style: sansproRegular.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Contact phone is required';
                        if (v.trim().length > 30) return 'Phone must be at most 30 characters';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '01XXXXXXXXX',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: WireframeColor.appcolor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xffF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xffCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: WireframeColor.appcolor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Executive Notice Card ──
  Widget _buildExecutiveNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xff0284C7)),
              const SizedBox(width: 8),
              Text(
                'Averroes Official Appointment Protocol',
                style: sansproBold.copyWith(fontSize: 13, color: const Color(0xff0369A1)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '• A student can have at most five active appointments in requested or scheduled status.\n'
            '• School leadership & faculty schedule consultations according to official academic hours.\n'
            '• You will receive SMS & in-app updates with confirmed schedule date, time, venue, or online link.\n'
            '• Please bring relevant student records (ID Card, class notes, test reports) on consultation day.',
            style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff334155), height: 1.4),
          ),
        ],
      ),
    );
  }



  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2: HISTORY & LIVE SCHEDULE TRACKING
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHistoryTrackingTab({required double width, required double height}) {
    return Obx(() {
      if (apptCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        );
      }

      final allList = apptCtrl.appointmentsList;

      // Filter by search and status
      final query = _searchController.text.toLowerCase().trim();
      final filteredList = allList.where((a) {
        if (_historyStatusFilter != 'All') {
          final filterNorm = _historyStatusFilter.toLowerCase();
          if (a.status.toLowerCase() != filterNorm) return false;
        }
        if (query.isNotEmpty) {
          final matchesNo = a.appointmentNo.toLowerCase().contains(query);
          final matchesName = a.recipient.name.toLowerCase().contains(query);
          final matchesDes = a.recipient.designation.toLowerCase().contains(query);
          final matchesSub = a.subject.toLowerCase().contains(query);
          final matchesPur = a.purposeLabel.toLowerCase().contains(query);
          if (!matchesNo && !matchesName && !matchesDes && !matchesSub && !matchesPur) return false;
        }
        return true;
      }).toList();

      // Check if there is an upcoming scheduled appointment to highlight prominently
      final scheduledItem = allList.firstWhereOrNull((a) => a.isScheduled);

      return RefreshIndicator(
        onRefresh: () async {
          await apptCtrl.fetchAppointments(showLoading: false);
          await apptCtrl.fetchRecipients();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VIP Scheduled Meeting Card (if exists)
              if (scheduledItem != null) ...[
                _buildScheduledVipBanner(scheduledItem),
                const SizedBox(height: 16),
              ],

              // Search Bar
              _buildHistorySearchBar(),
              const SizedBox(height: 12),

              // Status Filter Chips
              _buildStatusFilterChips(),
              const SizedBox(height: 16),

              // Appointment Cards List
              if (filteredList.isEmpty) ...[
                _buildEmptyHistoryState(allList.isEmpty),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(filteredList[index]);
                  },
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  // ── Scheduled Meeting VIP Banner ──
  Widget _buildScheduledVipBanner(AppointmentItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff0F172A), Color(0xff1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1E3A8A).withAlpha(60),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xffF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CONFIRMED SCHEDULED MEETING',
                  style: sansproBold.copyWith(fontSize: 12, color: const Color(0xffFBBF24), letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.appointmentNo,
                  style: sansproBold.copyWith(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.recipient.name,
            style: sansproBold.copyWith(fontSize: 16, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.recipient.designation,
            style: sansproSemibold.copyWith(fontSize: 13, color: const Color(0xff93C5FD)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xff38BDF8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Date: ${item.schedule?.date ?? item.preferredDate}',
                        style: sansproSemibold.copyWith(fontSize: 12.5, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 15, color: Color(0xff38BDF8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Time: ${_formatScheduleTime(item.schedule)}',
                        style: sansproSemibold.copyWith(fontSize: 12.5, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (item.schedule?.meetingModeLabel != null && item.schedule!.meetingModeLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.category_rounded, size: 15, color: Color(0xff38BDF8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode: ${item.schedule!.meetingModeLabel}',
                          style: sansproSemibold.copyWith(fontSize: 12.5, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.schedule?.venue != null && item.schedule!.venue!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.meeting_room_rounded, size: 15, color: Color(0xff38BDF8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Venue: ${item.schedule!.venue}',
                          style: sansproSemibold.copyWith(fontSize: 12.5, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.schedule?.meetingLink != null && item.schedule!.meetingLink!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 15, color: Color(0xff38BDF8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Link: ${item.schedule!.meetingLink}',
                          style: sansproSemibold.copyWith(fontSize: 12.5, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (item.teacherResponse != null && item.teacherResponse!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.message_rounded, size: 14, color: Color(0xffFBBF24)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'School Response: ${item.teacherResponse}',
                    style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xffE2E8F0), height: 1.3),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatScheduleTime(AppointmentSchedule? sch) {
    if (sch == null) return 'As Scheduled';
    if (sch.startTime != null && sch.endTime != null) {
      return '${sch.startTime} - ${sch.endTime}';
    }
    return sch.startTime ?? 'Scheduled Time';
  }

  // ── Search Bar ──
  Widget _buildHistorySearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: sansproRegular.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search by Ref No, Staff Name, Subject...',
          hintStyle: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xff64748B)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xff94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ── Status Filter Chips ──
  Widget _buildStatusFilterChips() {
    final filters = ['All', 'Requested', 'Scheduled', 'Completed', 'Declined', 'Cancelled'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _historyStatusFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              labelStyle: sansproSemibold.copyWith(
                fontSize: 11.5,
                color: isSelected ? Colors.white : const Color(0xff475569),
              ),
              selected: isSelected,
              selectedColor: const Color(0xff0B1E4D),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? const Color(0xff0B1E4D) : const Color(0xffE2E8F0),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _historyStatusFilter = f);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Appointment Card ──
  Widget _buildAppointmentCard(AppointmentItem item) {
    Color statusBg = const Color(0xffFEF3C7);
    Color statusFg = const Color(0xffB45309);
    IconData statusIcon = Icons.pending_actions_rounded;

    if (item.isScheduled) {
      statusBg = const Color(0xffDCFCE7);
      statusFg = const Color(0xff15803D);
      statusIcon = Icons.check_circle_rounded;
    } else if (item.isCompleted) {
      statusBg = const Color(0xffEDE9FE);
      statusFg = const Color(0xff6D28D9);
      statusIcon = Icons.task_alt_rounded;
    } else if (item.isDeclined) {
      statusBg = const Color(0xffFEE2E2);
      statusFg = const Color(0xffB91C1C);
      statusIcon = Icons.block_rounded;
    } else if (item.isCancelled) {
      statusBg = const Color(0xffF1F5F9);
      statusFg = const Color(0xff64748B);
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.hasUpdate ? const Color(0xff0284C7) : const Color(0xffE2E8F0),
          width: item.hasUpdate ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            if (expanded && item.hasUpdate) {
              apptCtrl.markAsRead(item.id);
            }
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusFg, size: 22),
              ),
              if (item.hasUpdate)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xff0284C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  item.recipient.name,
                  style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                item.subject.isNotEmpty ? item.subject : item.purposeLabel,
                style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xffCBD5E1)),
                    ),
                    child: Text(
                      item.appointmentNo,
                      style: sansproBold.copyWith(fontSize: 10.5, color: const Color(0xff334155)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: sansproBold.copyWith(fontSize: 10.5, color: statusFg),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(color: Color(0xffE2E8F0)),
            const SizedBox(height: 6),
            _buildDetailRow(label: 'Staff Member', value: '${item.recipient.name} (${item.recipient.designation})'),
            _buildDetailRow(label: 'Department', value: item.recipient.department),
            _buildDetailRow(label: 'Purpose', value: item.purposeLabel),
            _buildDetailRow(
              label: 'Preferred Slot',
              value: '${item.preferredDate}${item.preferredStartTime != null ? " at ${item.preferredStartTime}" : ""}',
            ),
            if (item.schedule != null && item.schedule!.date != null) ...[
              _buildDetailRow(
                label: 'Scheduled Meeting',
                value: '${item.schedule!.date} (${_formatScheduleTime(item.schedule)})',
                valueColor: const Color(0xff15803D),
                isBold: true,
              ),
              if (item.schedule!.meetingModeLabel.isNotEmpty)
                _buildDetailRow(label: 'Meeting Mode', value: item.schedule!.meetingModeLabel),
              if (item.schedule!.venue != null && item.schedule!.venue!.isNotEmpty)
                _buildDetailRow(label: 'Venue', value: item.schedule!.venue!, valueColor: const Color(0xff0369A1), isBold: true),
              if (item.schedule!.meetingLink != null && item.schedule!.meetingLink!.isNotEmpty)
                _buildDetailRow(label: 'Online Link', value: item.schedule!.meetingLink!, valueColor: const Color(0xff0284C7), isBold: true),
            ],
            _buildDetailRow(label: 'Attendee', value: '${item.attendee.name} (${item.attendee.relationship})'),
            _buildDetailRow(label: 'Attendee Phone', value: item.attendee.phone),
            if (item.details.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discussion Points / Details:',
                      style: sansproSemibold.copyWith(fontSize: 11.5, color: const Color(0xff475569)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.details,
                      style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff0F172A), height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
            if (item.teacherResponse != null && item.teacherResponse!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.isDeclined ? const Color(0xffFEF2F2) : const Color(0xffF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: item.isDeclined ? const Color(0xffFECACA) : const Color(0xffBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item.isDeclined ? Icons.report_problem_rounded : Icons.mark_email_read_rounded,
                          size: 14,
                          color: item.isDeclined ? const Color(0xffDC2626) : const Color(0xff16A34A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.isDeclined ? 'Reason for Declining / School Response:' : 'School Response / Instructions:',
                          style: sansproBold.copyWith(
                            fontSize: 11.5,
                            color: item.isDeclined ? const Color(0xffB91C1C) : const Color(0xff15803D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.teacherResponse!,
                      style: sansproRegular.copyWith(
                        fontSize: 12,
                        color: item.isDeclined ? const Color(0xff7F1D1D) : const Color(0xff14532D),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (item.cancellationReason != null && item.cancellationReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancellation Reason:',
                      style: sansproSemibold.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.cancellationReason!,
                      style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff334155), height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
            if (item.canCancel) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmCancel(item),
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xffDC2626)),
                  label: Text(
                    'Cancel Request',
                    style: sansproSemibold.copyWith(fontSize: 12, color: const Color(0xffDC2626)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: (isBold ? sansproBold : sansproSemibold).copyWith(
                fontSize: 12,
                color: valueColor ?? const Color(0xff0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(AppointmentItem item) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancel Appointment?',
          style: sansproBold.copyWith(fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel appointment request ${item.appointmentNo}?',
              style: sansproRegular.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Cancellation reason (Optional)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffDC2626)),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await apptCtrl.cancelAppointment(item.id, reason: reasonController.text.trim());
              if (res['success'] == true) {
                Get.snackbar(
                  'Appointment Cancelled',
                  res['message'] ?? 'Appointment request has been marked as cancelled.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xffFEF2F2),
                  colorText: const Color(0xff991B1B),
                  margin: const EdgeInsets.all(16),
                );
              } else {
                Get.snackbar(
                  'Cancellation Failed',
                  res['message'] ?? 'Unable to cancel appointment.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xffFEF2F2),
                  colorText: const Color(0xff991B1B),
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyHistoryState(bool isCompletelyEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xffF0F7FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_note_rounded, size: 30, color: Color(0xff0284C7)),
          ),
          const SizedBox(height: 14),
          Text(
            isCompletelyEmpty ? 'No Appointments Yet' : 'No Matching Appointments',
            style: sansproBold.copyWith(fontSize: 15.5, color: const Color(0xff0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            isCompletelyEmpty
                ? 'You have not scheduled any appointments with the Principal, Vice Principal, or Teachers. Tap "Book Appointment" to submit a consultation request.'
                : 'No appointment matches your selected filter criteria.',
            style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B), height: 1.4),
            textAlign: TextAlign.center,
          ),
          if (isCompletelyEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: WireframeColor.appcolor,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: Text(
                'Book New Appointment',
                style: sansproBold.copyWith(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDisplayDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION & LIVE UPDATE NOTICES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildActiveNotificationsNotice() {
    return Obx(() {
      final list = apptCtrl.appointmentsList;
      final unreadItems = list.where((a) => a.hasUpdate).toList();
      final scheduledItems = list.where((a) => a.isScheduled).toList();

      if (unreadItems.isEmpty && scheduledItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final isScheduledAlert = scheduledItems.isNotEmpty;
      final target = isScheduledAlert ? scheduledItems.first : unreadItems.first;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isScheduledAlert
                ? [const Color(0xff0B1E4D), const Color(0xff1E3A8A)]
                : [const Color(0xff064E3B), const Color(0xff047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isScheduledAlert ? const Color(0xff1E3A8A) : const Color(0xff047857)).withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isScheduledAlert ? Icons.event_available_rounded : Icons.notifications_active_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isScheduledAlert ? 'Upcoming Confirmed Consultation' : 'New Appointment Update',
                    style: sansproBold.copyWith(fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isScheduledAlert
                        ? '${target.recipient.name} (${target.schedule?.date ?? target.preferredDate})'
                        : '${target.recipient.name} has replied to request ${target.appointmentNo}',
                    style: sansproRegular.copyWith(fontSize: 11.5, color: Colors.white.withAlpha(220)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isScheduledAlert ? const Color(0xff0B1E4D) : const Color(0xff064E3B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                if (target.hasUpdate) {
                  apptCtrl.markAsRead(target.id);
                }
                _tabController.animateTo(1);
                _showAppointmentDetailsModal(target);
              },
              child: Text(
                'View',
                style: sansproBold.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Appointment Notifications Bottom Sheet ──
  void _showAppointmentNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xffF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xffCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 14, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff0B1E4D), Color(0xff1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: Color(0xffFBBF24), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointment Notifications',
                                style: sansproBold.copyWith(fontSize: 16.5, color: const Color(0xff0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Official consultation status, schedules & notes',
                                style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                              ),
                            ],
                          ),
                        ),
                        Obx(() {
                          final hasUnread = apptCtrl.appointmentsList.any((a) => a.hasUpdate);
                          if (!hasUnread) return const SizedBox.shrink();
                          return TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              apptCtrl.markAllAsRead();
                            },
                            child: Text(
                              'Mark all read',
                              style: sansproSemibold.copyWith(fontSize: 12, color: WireframeColor.appcolor),
                            ),
                          );
                        }),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xff64748B), size: 22),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xffE2E8F0)),

                  // Body
                  Expanded(
                    child: Obx(() {
                      final list = apptCtrl.appointmentsList;
                      if (list.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Color(0xffF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.notifications_none_rounded, size: 34, color: Color(0xff94A3B8)),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No Appointment Notifications',
                                  style: sansproBold.copyWith(fontSize: 15.5, color: const Color(0xff1E293B)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'You will receive notifications here when the Principal, Vice Principal, or Teachers approve, schedule, or respond to your consultations.',
                                  style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff64748B), height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: WireframeColor.appcolor,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                    _tabController.animateTo(0);
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                                  label: Text(
                                    'Book Appointment',
                                    style: sansproBold.copyWith(fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Summary chips bar
                      final scheduledCount = list.where((a) => a.isScheduled).length;
                      final requestedCount = list.where((a) => a.isRequested).length;
                      final completedCount = list.where((a) => a.isCompleted).length;

                      return ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        children: [
                          // Overview Stats Ribbon
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xffE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStatChip(
                                  label: 'Scheduled',
                                  count: scheduledCount,
                                  color: const Color(0xff15803D),
                                  bgColor: const Color(0xffDCFCE7),
                                  icon: Icons.event_available_rounded,
                                ),
                                Container(width: 1, height: 24, color: const Color(0xffE2E8F0)),
                                _buildMiniStatChip(
                                  label: 'Pending',
                                  count: requestedCount,
                                  color: const Color(0xffB45309),
                                  bgColor: const Color(0xffFEF3C7),
                                  icon: Icons.hourglass_top_rounded,
                                ),
                                Container(width: 1, height: 24, color: const Color(0xffE2E8F0)),
                                _buildMiniStatChip(
                                  label: 'Completed',
                                  count: completedCount,
                                  color: const Color(0xff0F766E),
                                  bgColor: const Color(0xffCCFBF1),
                                  icon: Icons.task_alt_rounded,
                                ),
                              ],
                            ),
                          ),

                          // Notification Items
                          ...list.map((item) => _buildNotificationSheetItem(item, sheetContext)),

                          const SizedBox(height: 12),

                          // Shortcut to general notifications
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: Color(0xffCBD5E1)),
                            ),
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              Get.to(() => const NotificationPage());
                            },
                            icon: const Icon(Icons.all_inbox_rounded, size: 17, color: Color(0xff475569)),
                            label: Text(
                              'Open All School Notifications',
                              style: sansproSemibold.copyWith(fontSize: 13, color: const Color(0xff334155)),
                            ),
                          ),
                        ],
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

  Widget _buildMiniStatChip({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: sansproBold.copyWith(fontSize: 13, color: color),
            ),
            Text(
              label,
              style: sansproRegular.copyWith(fontSize: 10.5, color: const Color(0xff64748B)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationSheetItem(AppointmentItem item, BuildContext sheetContext) {
    Color cardBorder = const Color(0xffE2E8F0);
    Color badgeBg = const Color(0xffFEF3C7);
    Color badgeFg = const Color(0xffB45309);
    IconData statusIcon = Icons.hourglass_top_rounded;
    String statusTitle = 'Appointment Requested';
    String statusDetail = 'Your request has been submitted and is in queue for review.';

    if (item.isScheduled) {
      cardBorder = const Color(0xff86EFAC);
      badgeBg = const Color(0xffDCFCE7);
      badgeFg = const Color(0xff15803D);
      statusIcon = Icons.event_available_rounded;
      statusTitle = 'Meeting Confirmed & Scheduled';
      statusDetail = 'Scheduled for ${item.schedule?.date ?? item.preferredDate} at ${_formatScheduleTime(item.schedule)}'
          '${item.schedule?.venue != null && item.schedule!.venue!.isNotEmpty ? " • Venue: ${item.schedule!.venue}" : ""}';
    } else if (item.teacherResponse != null && item.teacherResponse!.isNotEmpty) {
      cardBorder = const Color(0xffC7D2FE);
      badgeBg = const Color(0xffEEF2FF);
      badgeFg = const Color(0xff4338CA);
      statusIcon = Icons.mark_email_read_rounded;
      statusTitle = 'Official Response Received';
      statusDetail = '"${item.teacherResponse}"';
    } else if (item.isCompleted) {
      cardBorder = const Color(0xff99F6E4);
      badgeBg = const Color(0xffCCFBF1);
      badgeFg = const Color(0xff0F766E);
      statusIcon = Icons.task_alt_rounded;
      statusTitle = 'Consultation Completed';
      statusDetail = 'Meeting completed with ${item.recipient.name}.';
    } else if (item.isDeclined) {
      cardBorder = const Color(0xffFECDD3);
      badgeBg = const Color(0xffFFE4E6);
      badgeFg = const Color(0xffBE123C);
      statusIcon = Icons.block_rounded;
      statusTitle = 'Consultation Declined';
      statusDetail = item.teacherResponse ?? 'Scheduled consultation is unavailable at this time.';
    } else if (item.isCancelled) {
      cardBorder = const Color(0xffE2E8F0);
      badgeBg = const Color(0xffF1F5F9);
      badgeFg = const Color(0xff64748B);
      statusIcon = Icons.cancel_rounded;
      statusTitle = 'Request Cancelled';
      statusDetail = item.cancellationReason ?? 'Cancelled by parent/guardian.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.hasUpdate ? const Color(0xff0284C7) : cardBorder,
          width: item.hasUpdate ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (item.hasUpdate) {
              apptCtrl.markAsRead(item.id);
            }
            Navigator.pop(sheetContext);
            _tabController.animateTo(1);
            _showAppointmentDetailsModal(item);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(statusIcon, size: 16, color: badgeFg),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  statusTitle,
                                  style: sansproBold.copyWith(fontSize: 13, color: const Color(0xff0F172A)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.hasUpdate) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff0284C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: sansproBold.copyWith(fontSize: 9, color: Colors.white),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            item.recipient.name,
                            style: sansproSemibold.copyWith(fontSize: 12, color: WireframeColor.appcolor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.appointmentNo,
                        style: sansproBold.copyWith(fontSize: 10, color: const Color(0xff475569)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  statusDetail,
                  style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff334155), height: 1.35),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Requested: ${item.requestedAt}',
                      style: sansproRegular.copyWith(fontSize: 11, color: const Color(0xff94A3B8)),
                    ),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: sansproBold.copyWith(fontSize: 11.5, color: WireframeColor.appcolor),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: WireframeColor.appcolor),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── High-Resolution Appointment Details Modal ──
  void _showAppointmentDetailsModal(AppointmentItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff0B1E4D), WireframeColor.appcolor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Details',
                            style: sansproBold.copyWith(fontSize: 15.5, color: Colors.white),
                          ),
                          Text(
                            item.appointmentNo,
                            style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff93C5FD)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: item.isScheduled
                              ? const Color(0xffDCFCE7)
                              : item.isCompleted
                                  ? const Color(0xffCCFBF1)
                                  : item.isDeclined
                                      ? const Color(0xffFFE4E6)
                                      : const Color(0xffFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.isScheduled
                                  ? Icons.check_circle_rounded
                                  : item.isCompleted
                                      ? Icons.task_alt_rounded
                                      : item.isDeclined
                                          ? Icons.block_rounded
                                          : Icons.hourglass_top_rounded,
                              size: 16,
                              color: item.isScheduled
                                  ? const Color(0xff15803D)
                                  : item.isCompleted
                                      ? const Color(0xff0F766E)
                                      : item.isDeclined
                                          ? const Color(0xffBE123C)
                                          : const Color(0xffB45309),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${item.statusLabel}',
                              style: sansproBold.copyWith(
                                fontSize: 12.5,
                                color: item.isScheduled
                                    ? const Color(0xff15803D)
                                    : item.isCompleted
                                        ? const Color(0xff0F766E)
                                        : item.isDeclined
                                            ? const Color(0xffBE123C)
                                            : const Color(0xffB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildDetailRow(label: 'Official Staff', value: '${item.recipient.name} (${item.recipient.designation})', isBold: true),
                      _buildDetailRow(label: 'Department', value: item.recipient.department),
                      _buildDetailRow(label: 'Meeting Purpose', value: item.purposeLabel),
                      _buildDetailRow(label: 'Preferred Date', value: item.preferredDate),
                      if (item.preferredStartTime != null)
                        _buildDetailRow(label: 'Preferred Slot', value: item.preferredStartTime!),

                      if (item.schedule != null && item.schedule!.date != null) ...[
                        const Divider(color: Color(0xffE2E8F0)),
                        _buildDetailRow(
                          label: 'Confirmed Meeting',
                          value: '${item.schedule!.date} (${_formatScheduleTime(item.schedule)})',
                          valueColor: const Color(0xff15803D),
                          isBold: true,
                        ),
                        if (item.schedule!.venue != null && item.schedule!.venue!.isNotEmpty)
                          _buildDetailRow(label: 'Venue', value: item.schedule!.venue!, valueColor: const Color(0xff0369A1), isBold: true),
                        if (item.schedule!.meetingModeLabel.isNotEmpty)
                          _buildDetailRow(label: 'Meeting Mode', value: item.schedule!.meetingModeLabel),
                        if (item.schedule!.meetingLink != null && item.schedule!.meetingLink!.isNotEmpty)
                          _buildDetailRow(label: 'Meeting Link', value: item.schedule!.meetingLink!, valueColor: const Color(0xff0284C7), isBold: true),
                      ],

                      const Divider(color: Color(0xffE2E8F0)),
                      _buildDetailRow(label: 'Attendee Name', value: '${item.attendee.name} (${item.attendee.relationship})'),
                      _buildDetailRow(label: 'Contact Phone', value: item.attendee.phone),

                      if (item.details.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discussion Agenda / Details:',
                                style: sansproSemibold.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.details,
                                style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff0F172A), height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (item.teacherResponse != null && item.teacherResponse!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.isDeclined ? const Color(0xffFEF2F2) : const Color(0xffF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: item.isDeclined ? const Color(0xffFECACA) : const Color(0xffBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.isDeclined ? 'Decline Reason / Remarks:' : 'School Official Remarks:',
                                style: sansproBold.copyWith(
                                  fontSize: 11.5,
                                  color: item.isDeclined ? const Color(0xffB91C1C) : const Color(0xff15803D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.teacherResponse!,
                                style: sansproRegular.copyWith(
                                  fontSize: 12,
                                  color: item.isDeclined ? const Color(0xff7F1D1D) : const Color(0xff14532D),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer Action
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WireframeColor.appcolor,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Close',
                      style: sansproBold.copyWith(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
