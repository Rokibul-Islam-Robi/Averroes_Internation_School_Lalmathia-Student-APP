import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'fees_controller.dart';
import 'student_controller.dart';
import 'page_background.dart';

class FeesInvoiceDetailPage extends StatefulWidget {
  final FeeInvoice invoice;
  const FeesInvoiceDetailPage({Key? key, required this.invoice}) : super(key: key);

  @override
  State<FeesInvoiceDetailPage> createState() => _FeesInvoiceDetailPageState();
}

class _FeesInvoiceDetailPageState extends State<FeesInvoiceDetailPage> {
  final FeesController feesCtrl = Get.find<FeesController>();

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

    if (Get.isRegistered<StudentController>()) {
      final p = Get.find<StudentController>().profile.value;
      if (p != null && p.academicYear.isNotEmpty) {
        final ay = p.academicYear.trim();
        if (ay.contains('$currentYear') && ay.contains('${currentYear + 1}')) {
          return ay;
        }
      }
    }

    return fallbackSession; // "2026-2027"
  }

  @override
  void initState() {
    super.initState();
    feesCtrl.fetchInvoiceDetail(widget.invoice.invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(
        title: 'Invoice Details',
      ),
      backgroundColor: WireframeColor.appcolor,
      body: PageBackground(
        category: PageCategory.fees,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffF5F6FC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Obx(() {
                  if (feesCtrl.isDetailLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: WireframeColor.appcolor),
                    );
                  }

                  final detail = feesCtrl.invoiceDetail.value;
                  final isPaid = (detail?.status.toLowerCase() == 'paid') || widget.invoice.isPaid;
                  
                  final double rawSub = (detail != null && detail.subTotal > 0)
                      ? detail.subTotal
                      : (widget.invoice.subTotal > 0 ? widget.invoice.subTotal : 0.0);
                  final double discount = detail?.discount ?? widget.invoice.discount;
                  final double penalty = detail?.fine ?? widget.invoice.fine;
                  final double rawTot = (detail != null && detail.totalAmount > 0)
                      ? detail.totalAmount
                      : (widget.invoice.amount > 0 ? widget.invoice.amount : 0.0);
                  
                  final double subTotal = rawSub > 0 ? rawSub : (rawTot > 0 ? (rawTot + discount - penalty) : 0.0);
                  final double total = rawTot > 0 ? rawTot : (subTotal > 0 ? (subTotal - discount + penalty) : 0.0);
                  final double paid = (detail != null && detail.paidAmount > 0)
                      ? detail.paidAmount
                      : (widget.invoice.paidAmount > 0 ? widget.invoice.paidAmount : (isPaid ? total : 0.0));
                  final double due = (detail != null && detail.dueAmount > 0)
                      ? detail.dueAmount
                      : (widget.invoice.dueAmount > 0 ? widget.invoice.dueAmount : (isPaid ? 0.0 : (total > paid ? total - paid : 0.0)));

                  final String invoiceNum = (detail?.invoiceNumber.isNotEmpty == true)
                      ? detail!.invoiceNumber
                      : widget.invoice.invoiceNumber;
                  final String invoiceDate = (detail?.issueDate.isNotEmpty == true)
                      ? detail!.issueDate
                      : widget.invoice.displayInvoiceDate;
                  final String feeHeadText = detail?.feeHeadWithType ?? widget.invoice.feeHeadWithType;
                  final String billingMonthText = (detail?.billingMonth.isNotEmpty == true)
                      ? detail!.billingMonth
                      : widget.invoice.month;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: w / 20,
                      vertical: h / 36,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Status Banner ──
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: h / 65, horizontal: w / 24),
                          decoration: BoxDecoration(
                            color: isPaid ? const Color(0xffE8F5E9) : const Color(0xffFFF3E0),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isPaid ? const Color(0xff4CAF50).withAlpha(100) : const Color(0xffFF9800).withAlpha(100),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                color: isPaid ? const Color(0xff2E7D32) : const Color(0xffE65100),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPaid
                                    ? 'Payment Cleared'
                                    : 'Payment Pending · Due Date: ${detail?.dueDate ?? widget.invoice.dueDate}',
                                style: sansproSemibold.copyWith(
                                  fontSize: 13.5,
                                  color: isPaid ? const Color(0xff2E7D32) : const Color(0xffE65100),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h / 45),

                        // ── 2. Student Scope Card ──
                        _buildSectionCard(
                          title: 'Student Information',
                          icon: Icons.person_outline_rounded,
                          children: [
                            _infoRow(
                              'Student Name',
                              detail?.studentName.isNotEmpty == true && detail!.studentName.toLowerCase() != 'student'
                                  ? detail.studentName
                                  : (Get.isRegistered<StudentController>() && Get.find<StudentController>().profile.value?.studentName.isNotEmpty == true
                                      ? Get.find<StudentController>().profile.value!.studentName
                                      : (detail?.studentName.isNotEmpty == true ? detail!.studentName : 'Muaz Ibne Arif')),
                            ),
                            _divider(),
                            _infoRow(
                              'Student ID / UID',
                              detail?.studentUid.isNotEmpty == true
                                  ? detail!.studentUid
                                  : (Get.isRegistered<StudentController>() && Get.find<StudentController>().profile.value?.studentId.isNotEmpty == true
                                      ? Get.find<StudentController>().profile.value!.studentId
                                      : '2023300'),
                            ),
                            _divider(),
                            _infoRow(
                              'Class & Section',
                              Get.isRegistered<StudentController>() && Get.find<StudentController>().profile.value != null
                                  ? '${Get.find<StudentController>().profile.value!.className} - ${Get.find<StudentController>().profile.value!.section}'
                                  : '${detail?.className.isNotEmpty == true ? detail!.className : "Pre KG"} - ${detail?.sectionName.isNotEmpty == true ? detail!.sectionName : "Aqua"}',
                            ),
                            _divider(),
                            _infoRow(
                              'Academic Session',
                              _getCurrentAcademicSession(detail?.sessionName),
                            ),
                          ],
                        ),
                        SizedBox(height: h / 45),

                        // ── 3. Invoice Overview (Complete & Unified with Highlights) ──
                        _buildSectionCard(
                          title: 'Invoice Overview',
                          icon: Icons.receipt_outlined,
                          children: [
                            _infoRow('Invoice Number', invoiceNum),
                            _divider(),
                            _infoRow('Invoice Date', invoiceDate),
                            _divider(),
                            _infoRow('Fee Head', feeHeadText),
                            _divider(),
                            _infoRow('Billing Month', billingMonthText),
                            _divider(),
                            _infoRow('Subtotal', '৳ ${subTotal.toStringAsFixed(2)}'),
                            _divider(),
                            _infoRow('Discount', discount > 0 ? '(-) ৳ ${discount.toStringAsFixed(2)}' : '৳ 0.00'),
                            _divider(),
                            _infoRow('Late Fine', penalty > 0 ? '(+) ৳ ${penalty.toStringAsFixed(2)}' : '৳ 0.00'),
                            _divider(),

                            // Total Payable (Bold & Highlighted)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: h / 100),
                              child: Row(
                                children: [
                                  Text(
                                    'Total Payable',
                                    style: sansproBold.copyWith(fontSize: 14.5, color: WireframeColor.black),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '৳ ${total.toStringAsFixed(2)}',
                                    style: sansproBold.copyWith(fontSize: 15.5, color: WireframeColor.black),
                                  ),
                                ],
                              ),
                            ),

                            if (paid > 0) ...[
                              _divider(),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: h / 140),
                                child: Row(
                                  children: [
                                    Text(
                                      'Amount Paid',
                                      style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff2E7D32)),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '(-) ৳ ${paid.toStringAsFixed(2)}',
                                      style: sansproSemibold.copyWith(fontSize: 13, color: const Color(0xff2E7D32)),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: h / 140),

                            // Outstanding Balance Due Highlight Container
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isPaid ? const Color(0xffE8F5E9) : const Color(0xffFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isPaid ? const Color(0xffA7F3D0) : const Color(0xffFDE68A),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    isPaid ? 'Balance Paid' : 'Outstanding Balance Due',
                                    style: sansproBold.copyWith(
                                      fontSize: 13.5,
                                      color: isPaid ? const Color(0xff15803D) : const Color(0xffB45309),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '৳ ${due.toStringAsFixed(2)}',
                                    style: sansproBold.copyWith(
                                      fontSize: 16.5,
                                      color: isPaid ? const Color(0xff15803D) : const Color(0xffB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: h / 36),

                        // ── 5. PDF Download Action Button ──
                        Obx(() => InkWell(
                          onTap: feesCtrl.isDownloadingPdf.value
                              ? null
                              : () => feesCtrl.downloadInvoicePdf(detail?.id ?? widget.invoice.invoiceId),
                          child: Container(
                            width: double.infinity,
                            height: h / 15,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: WireframeColor.appcolor.withAlpha(80),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (feesCtrl.isDownloadingPdf.value)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                  )
                                else ...[
                                  const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Download Official PDF Invoice',
                                    style: sansproSemibold.copyWith(fontSize: 15, color: Colors.white),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: WireframeColor.appcolor),
              const SizedBox(width: 8),
              Text(
                title,
                style: sansproSemibold.copyWith(fontSize: 14, color: WireframeColor.black),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray)),
          const Spacer(),
          Text(value, style: sansproSemibold.copyWith(fontSize: 13, color: WireframeColor.black)),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Color(0xffEEF0F6), height: 1);
}