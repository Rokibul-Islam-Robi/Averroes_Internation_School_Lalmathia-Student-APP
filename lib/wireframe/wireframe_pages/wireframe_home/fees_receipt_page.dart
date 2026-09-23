import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'fees_controller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart'; // কাস্টম ব্যাকগ্রাউন্ডের জন্য

class FeesReceiptPage extends StatefulWidget {
  final FeeInvoice invoice;
  const FeesReceiptPage({Key? key, required this.invoice}) : super(key: key);

  @override
  State<FeesReceiptPage> createState() => _FeesReceiptPageState();
}

class _FeesReceiptPageState extends State<FeesReceiptPage> {
  final FeesController feesCtrl = Get.find<FeesController>();

  @override
  void initState() {
    super.initState();
    // Synchronize live comprehensive payment invoice details from API
    feesCtrl.fetchInvoiceDetail(widget.invoice.invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(
        title: 'Fee Receipt',
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
                  final detail = feesCtrl.invoiceDetail.value;

                  final String invoiceNum = (detail?.invoiceNumber.isNotEmpty == true)
                      ? detail!.invoiceNumber
                      : widget.invoice.receiptNo;

                  final double displayAmount = (detail != null && detail.paidAmount > 0)
                      ? detail.paidAmount
                      : (widget.invoice.paidAmount > 0
                          ? widget.invoice.paidAmount
                          : (detail?.totalAmount ?? widget.invoice.amount));

                  final String rawPaid = (detail?.paidDate != null && detail!.paidDate!.trim().isNotEmpty)
                      ? detail.paidDate!
                      : (widget.invoice.paidAt != null && widget.invoice.paidAt!.trim().isNotEmpty
                          ? widget.invoice.paidAt!
                          : (widget.invoice.paidDate.isNotEmpty
                              ? widget.invoice.paidDate
                              : (detail?.issueDate ?? widget.invoice.issueDate ?? widget.invoice.dueDate)));

                  final String formattedPaidDateTime = formatPaymentDateTime(rawPaid);
                  final String feeHeadText = detail?.feeHeadWithType ?? widget.invoice.feeHeadWithType;
                  final String monthText = (detail?.billingMonth.isNotEmpty == true)
                      ? detail!.billingMonth
                      : widget.invoice.month;
                  final String payModeText = widget.invoice.payMode;
                  final String invoiceIdText = (detail?.id.isNotEmpty == true)
                      ? detail!.id
                      : widget.invoice.invoiceId;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: w / 18,
                      vertical: h / 36,
                    ),
                    child: Column(
                      children: [
                        // ── Success Badge ──────────────────────────────────────
                        Container(
                          padding: EdgeInsets.symmetric(vertical: h / 40),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xffE8F5E9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff4CD964).withAlpha(77),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Color(0xff2E7D32),
                                  size: 44,
                                ),
                              ),
                              SizedBox(height: h / 56),
                              Text(
                                'Payment Successful',
                                style: sansproSemibold.copyWith(
                                  fontSize: 20,
                                  color: const Color(0xff2E7D32),
                                ),
                              ),
                              SizedBox(height: h / 120),
                              Text(
                                formattedPaidDateTime.isNotEmpty
                                    ? 'Paid on $formattedPaidDateTime'
                                    : 'Payment Confirmed',
                                style: sansproRegular.copyWith(
                                  fontSize: 13,
                                  color: WireframeColor.textgray,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h / 46),

                        // ── Receipt Card ───────────────────────────────────────
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Receipt Header
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w / 18,
                                  vertical: h / 46,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      WireframeColor.appcolor,
                                      WireframeColor.lightappcolor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'RECEIPT',
                                            style: sansproSemibold.copyWith(
                                              fontSize: 11,
                                              color: Colors.white70,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            invoiceNum,
                                            style: sansproBold.copyWith(
                                              fontSize: 15.5,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '৳ ${displayAmount.toStringAsFixed(0)}',
                                      style: sansproBold.copyWith(
                                        fontSize: 26,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Receipt Rows
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w / 22,
                                  vertical: h / 56,
                                ),
                                child: Column(
                                  children: [
                                    _receiptRow('Fee Head', feeHeadText),
                                    _divider(),
                                    _receiptRow('Month', monthText),
                                    _divider(),
                                    _receiptRow(
                                      'Payment Date',
                                      formattedPaidDateTime.isNotEmpty
                                          ? formattedPaidDateTime
                                          : (rawPaid.isNotEmpty ? rawPaid : 'Confirmed'),
                                    ),
                                    _divider(),
                                    _receiptRow('Pay Mode', payModeText),
                                    _divider(),
                                    _receiptRow('Invoice ID', invoiceIdText),
                                  ],
                                ),
                              ),

                              // Bottom dashed line (receipt style)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: w / 22),
                                child: Row(
                                  children: List.generate(
                                    30,
                                    (i) => Expanded(
                                      child: Container(
                                        height: 1.5,
                                        color: i.isEven
                                            ? WireframeColor.bggray
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w / 22,
                                  vertical: h / 60,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.school_outlined,
                                      size: 16,
                                      color: WireframeColor.textgray,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Averroes International School Lalmatia',
                                      style: sansproRegular.copyWith(
                                        fontSize: 11,
                                        color: WireframeColor.textgray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h / 36),

                        // ── Download Button ────────────────────────────────────
                        Obx(() => InkWell(
                          onTap: feesCtrl.isDownloadingPdf.value
                              ? null
                              : () => feesCtrl.downloadInvoicePdf(widget.invoice.invoiceId),
                          child: Container(
                            width: double.infinity,
                            height: h / 14,
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
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                else ...[
                                  const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Download Official Receipt (PDF)',
                                    style: sansproSemibold.copyWith(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
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

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: sansproRegular.copyWith(
              fontSize: 13,
              color: WireframeColor.textgray,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: sansproSemibold.copyWith(
                fontSize: 13,
                color: WireframeColor.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: WireframeColor.bggray, height: 1);
}