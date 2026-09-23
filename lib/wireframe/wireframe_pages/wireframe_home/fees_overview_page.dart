import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:get/get.dart';
import 'fees_controller.dart';
import 'student_controller.dart';
import 'fees_invoice_detail_page.dart';
import 'fees_receipt_page.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';

class FeesOverviewPage extends StatefulWidget {
  const FeesOverviewPage({Key? key}) : super(key: key);

  @override
  State<FeesOverviewPage> createState() => _FeesOverviewPageState();
}

class _FeesOverviewPageState extends State<FeesOverviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FeesController feesCtrl = Get.put(FeesController());
  final StudentController studentCtrl = Get.put(StudentController());

  String _getCurrentAcademicSession([String? rawSession]) {
    final now = DateTime.now();
    final currentYear = now.year;
    final fallbackSession = "$currentYear-${currentYear + 1}";

    if (rawSession != null && rawSession.trim().isNotEmpty) {
      final s = rawSession.trim();
      if (s.contains('$currentYear') && s.contains('${currentYear + 1}')) {
        return s;
      }
    }

    if (studentCtrl.profile.value != null && studentCtrl.profile.value!.academicYear.isNotEmpty) {
      final ay = studentCtrl.profile.value!.academicYear.trim();
      if (ay.contains('$currentYear') && ay.contains('${currentYear + 1}')) {
        return ay;
      }
    }

    return fallbackSession; // "2026-2027"
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PageAppBar(
        title: 'Fees & Payments',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => feesCtrl.refreshFees(),
          ),
        ],
      ),
      backgroundColor: WireframeColor.appcolor,
      body: PageBackground(
        category: PageCategory.fees,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // ── Top Summary & Info Section ─────────────────────────────
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // 1. Total Outstanding Dues Summary Card
                        Obx(() => feesCtrl.isLoading.value
                            ? const SizedBox()
                            : Padding(
                          padding: EdgeInsets.symmetric(horizontal: w / 26),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff0B1E4D), Color(0xff1E3A8A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: Colors.white.withAlpha(35), width: 1.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff0B1E4D).withAlpha(30),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: w / 18, vertical: h / 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Outstanding Dues (${_getCurrentAcademicSession()})',
                                  style: sansproRegular.copyWith(
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(210)),
                                ),
                                SizedBox(height: h / 180),
                                Text(
                                  feesCtrl.formatAmount(feesCtrl.totalOutstandingDueSum),
                                  style: sansproBold.copyWith(
                                      fontSize: 30,
                                      color: Colors.white,
                                      letterSpacing: 0.5),
                                ),
                                SizedBox(height: h / 100),
                                Container(
                                  height: 1,
                                  color: Colors.white.withAlpha(30),
                                ),
                                SizedBox(height: h / 100),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    _summaryChip(
                                      Icons.pending_actions_rounded,
                                      '${feesCtrl.pendingInvoices.length} Pending',
                                      const Color(0xff93C5FD),
                                    ),
                                    _summaryChip(
                                      Icons.calendar_month_rounded,
                                      'Current Month Dues: ${feesCtrl.formatAmount(feesCtrl.currentMonthDueAmount)}',
                                      const Color(0xffFDE047),
                                    ),
                                    _summaryChip(
                                      Icons.check_circle_outline_rounded,
                                      '${feesCtrl.paidInvoices.length} Paid',
                                      const Color(0xff86EFAC),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),

                        SizedBox(height: h / 75),

                        // 2. Student Information Card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: w / 26),
                          child: _buildStudentInfoCard(context, w, h),
                        ),

                        SizedBox(height: h / 75),

                        // 3. Late Fine Notice Card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: w / 26),
                          child: _buildLateFineNoticeCard(context, w, h),
                        ),

                        SizedBox(height: h / 45),
                      ],
                    ),
                  ),

                  // ── Tab Bar (Modern Corporate Segmented Capsule) ────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      controller: _tabController,
                      color: WireframeColor.appcolor,
                    ),
                  ),
                ],

                // ── Tab Body ────────────────────────────────────────────────────────
                body: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffF5F6FC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DuesTab(feesCtrl: feesCtrl),
                      _HistoryTab(feesCtrl: feesCtrl),
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

  Widget _buildStudentInfoCard(BuildContext context, double w, double h) {
    return Obx(() {
      final p = studentCtrl.profile.value;
      final name = p?.studentName.isNotEmpty == true ? p!.studentName : 'Muaz Ibne Arif';
      final roll = p?.rollNo.isNotEmpty == true ? p!.rollNo : (p?.studentId ?? '2023300');
      final session = _getCurrentAcademicSession(p?.academicYear);
      final className = p?.className.isNotEmpty == true ? p!.className : 'Pre KG';
      final section = p?.section.isNotEmpty == true ? p!.section : 'Aqua';
      final photoUrl = p?.profilePhotoUrl ?? '';

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(14),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: w / 24, vertical: h / 70),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: WireframeColor.appcolor.withAlpha(35), width: 1.5),
              ),
              child: ClipOval(
                child: photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
                      )
                    : Image.asset(WireframePngimage.dp, fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: w / 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: name,
                          style: sansproBold.copyWith(
                            fontSize: 14.5,
                            color: WireframeColor.black,
                          ),
                        ),
                        TextSpan(
                          text: ' ($roll)',
                          style: sansproRegular.copyWith(
                            fontSize: 13,
                            color: WireframeColor.textgray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$session | Class: $className | Section: $section',
                    style: sansproRegular.copyWith(
                      fontSize: 12,
                      color: WireframeColor.textgray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLateFineNoticeCard(BuildContext context, double w, double h) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 65),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Late Fine Notice: ',
              style: sansproBold.copyWith(
                fontSize: 12.5,
                color: WireframeColor.black,
                height: 1.45,
              ),
            ),
            TextSpan(
              text:
                  'Late fine is applicable to overdue monthly tuition fees only. Tk 200 is charged when payment is made from the 11th day through the end of the due month. If payment is made in a later month, the late fine is Tk 500. Annual fees are not subject to a late fine.',
              style: sansproRegular.copyWith(
                fontSize: 12,
                color: const Color(0xff4B5563),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: sansproRegular.copyWith(
              fontSize: 13, color: Colors.white.withAlpha(230)),
        ),
      ],
    );
  }
}

// ── Tab 1: Dues & Invoices ────────────────────────────────────────────────────
class _DuesTab extends StatelessWidget {
  final FeesController feesCtrl;
  const _DuesTab({required this.feesCtrl});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      if (feesCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: WireframeColor.appcolor),
        );
      }

      if (feesCtrl.hasError.value) {
        return _ErrorWidget(
          message: feesCtrl.errorMessage.value,
          onRetry: feesCtrl.refreshFees,
        );
      }

      if (feesCtrl.pendingInvoices.isEmpty) {
        return const _EmptyWidget(
          icon: Icons.check_circle_outline,
          message: 'No pending dues!\nAll fees are cleared.',
          iconColor: Color(0xff4CD964),
        );
      }

      final sortedList = feesCtrl.sortedPendingInvoices;

      return RefreshIndicator(
        color: WireframeColor.appcolor,
        onRefresh: feesCtrl.refreshFees,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(w / 26, h / 60, w / 26, h / 36),
          itemCount: sortedList.length,
          itemBuilder: (context, index) {
            final inv = sortedList[index];
            return _DueInvoiceCard(
              invoice: inv,
              onTap: () async {
                // ইউজার ডিটেইল পেজে যাওয়ার পর পেমেন্ট শেষ করে ব্যাক আসলে অটো-রিফ্রেশ হবে
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeesInvoiceDetailPage(invoice: inv),
                  ),
                );
                feesCtrl.refreshFees(); // ব্যাক আসার সাথে সাথে কন্ট্রোলার আপডেট করবে
              },
            );
          },
        ),
      );
    });
  }
}

// ── Tab 2: Payment History ────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final FeesController feesCtrl;
  const _HistoryTab({required this.feesCtrl});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Obx(() {
      if (feesCtrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: WireframeColor.appcolor),
        );
      }

      if (feesCtrl.paidInvoices.isEmpty) {
        return const _EmptyWidget(
          icon: Icons.receipt_long_outlined,
          message: 'No payment history found.',
          iconColor: WireframeColor.textgray,
        );
      }

      return RefreshIndicator(
        color: WireframeColor.appcolor,
        onRefresh: feesCtrl.refreshFees,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(w / 26, h / 60, w / 26, h / 36),
          itemCount: feesCtrl.paidInvoices.length,
          itemBuilder: (context, index) {
            final inv = feesCtrl.paidInvoices[index];
            return _PaidReceiptCard(
              invoice: inv,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeesReceiptPage(invoice: inv),
                  ),
                );
                feesCtrl.refreshFees();
              },
            );
          },
        ),
      );
    });
  }
}

// ── Due Invoice Card ──────────────────────────────────────────────────────────
class _DueInvoiceCard extends StatelessWidget {
  final FeeInvoice invoice;
  final VoidCallback onTap;
  const _DueInvoiceCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final double displayAmount = invoice.dueAmount > 0 ? invoice.dueAmount : invoice.amount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: h / 56),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 60),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long_rounded,
                            color: Color(0xff1E40AF), size: 22),
                      ),
                      SizedBox(width: w / 26),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.feeHead,
                              style: sansproSemibold.copyWith(
                                  fontSize: 15, color: WireframeColor.black),
                            ),
                            Text(
                              invoice.month,
                              style: sansproRegular.copyWith(
                                  fontSize: 12, color: WireframeColor.textgray),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '৳ ${displayAmount.toStringAsFixed(0)}',
                            style: sansproBold.copyWith(
                                fontSize: 18, color: WireframeColor.appcolor),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xffFFF3CD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PENDING',
                              style: sansproSemibold.copyWith(
                                  fontSize: 10, color: const Color(0xffD97706)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: h / 80),
                  const Divider(color: WireframeColor.bggray, height: 1),
                  SizedBox(height: h / 80),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: WireframeColor.textgray),
                      const SizedBox(width: 4),
                      Text(
                        'Date: ${invoice.displayInvoiceDate}',
                        style: sansproRegular.copyWith(
                            fontSize: 12, color: WireframeColor.textgray),
                      ),
                      const Spacer(),
                      Text(
                        'View Details →',
                        style: sansproSemibold.copyWith(
                            fontSize: 12, color: WireframeColor.appcolor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Paid Receipt Card ─────────────────────────────────────────────────────────
class _PaidReceiptCard extends StatelessWidget {
  final FeeInvoice invoice;
  final VoidCallback onTap;
  const _PaidReceiptCard({required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final double displayAmount = invoice.paidAmount > 0 ? invoice.paidAmount : invoice.amount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: h / 56),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w / 22, vertical: h / 60),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Color(0xff2E7D32), size: 22),
                  ),
                  SizedBox(width: w / 26),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.feeHead,
                          style: sansproSemibold.copyWith(
                              fontSize: 15, color: WireframeColor.black),
                        ),
                        Text(
                          invoice.month,
                          style: sansproRegular.copyWith(
                              fontSize: 12, color: WireframeColor.textgray),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳ ${displayAmount.toStringAsFixed(0)}',
                        style: sansproBold.copyWith(
                            fontSize: 18, color: const Color(0xff2E7D32)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PAID',
                          style: sansproSemibold.copyWith(
                              fontSize: 10, color: const Color(0xff2E7D32)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: h / 80),
              const Divider(color: WireframeColor.bggray, height: 1),
              SizedBox(height: h / 80),
              Row(
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 13, color: WireframeColor.textgray),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      invoice.receiptNo,
                      style: sansproRegular.copyWith(
                          fontSize: 12, color: WireframeColor.textgray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.payment_outlined,
                      size: 13, color: WireframeColor.textgray),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      invoice.payMode,
                      style: sansproRegular.copyWith(
                          fontSize: 12, color: WireframeColor.textgray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'View Receipt →',
                    style: sansproSemibold.copyWith(
                        fontSize: 12, color: WireframeColor.appcolor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────
class _EmptyWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color iconColor;
  const _EmptyWidget(
      {required this.icon, required this.message, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: sansproRegular.copyWith(
                fontSize: 16, color: WireframeColor.textgray),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(
                  fontSize: 15, color: WireframeColor.textgray)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WireframeColor.appcolor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SliverPersistentHeader Delegate (Corporate Segmented Capsule) ─────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;
  final Color color;

  const _TabBarDelegate({
    required this.controller,
    required this.color,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: color,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      alignment: Alignment.center,
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(50), width: 1.2),
        ),
        child: TabBar(
          controller: controller,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: WireframeColor.appcolor,
          unselectedLabelColor: Colors.white,
          labelStyle: sansproBold.copyWith(fontSize: 13.5, letterSpacing: 0.2),
          unselectedLabelStyle: sansproSemibold.copyWith(fontSize: 13.5),
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Dues & Invoices'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 17),
                  SizedBox(width: 6),
                  Text('Payment History'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}