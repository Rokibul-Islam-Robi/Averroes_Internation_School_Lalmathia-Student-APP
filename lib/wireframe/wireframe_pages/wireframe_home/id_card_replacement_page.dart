import 'dart:math';
import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'page_background.dart';
import 'student_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// MODEL — ID Card Replacement Item
// ════════════════════════════════════════════════════════════════════════════
class IdCardItem {
  final String id;
  final String title;
  final double price;
  int quantity;

  IdCardItem({
    required this.id,
    required this.title,
    required this.price,
    this.quantity = 0,
  });

  bool get isSelected => quantity > 0;
  double get total => price * quantity;
}

// ════════════════════════════════════════════════════════════════════════════
// MODEL — Replacement Order
// Matches Averroes International School ERP Web Portal Specifications
// ════════════════════════════════════════════════════════════════════════════
class ReplacementOrder {
  final String requestId; // e.g. IDR-202609-000003
  final String date; // e.g. 06-Sep-2026 09:41 AM
  final List<String> items; // e.g. ["Student ID Card Only (without Ribbon/Holder) × 1 (Tk 100.00)"]
  final String invoiceNumber; // e.g. INV-202609-295878
  final String feeHead; // "ID Card Reissue Fee"
  final String feeType; // "One-time"
  final String monthYear; // "September 2026"
  final double subtotal; // 100.00
  final double totalPayable; // 100.00
  double paidAmount; // 0.00 or 100.00
  double dueAmount; // 100.00 or 0.00
  final double bankChargeRate; // 0.0101 (1.01%)
  final String reason;
  final String? note;
  String paymentStatus; // 'Unpaid' | 'Paid'
  String requestStatus; // 'Awaiting Payment' | 'Payment Verified / In Print Queue' | 'Printed' | 'Ready for Collection'
  String printedStatus; // 'Not yet' | 'In Print Queue' | 'Printed'
  String collectionLocation; // 'Not assigned yet' | 'IT Helpdesk, 2nd Floor (Admin Building)'
  String? transactionId; // e.g. TXN-EBL-202609-847291
  String? paymentMethod; // e.g. 'EBL SKY PAY (Visa/Mastercard)'
  String? paymentDate;

  ReplacementOrder({
    required this.requestId,
    required this.date,
    required this.items,
    required this.invoiceNumber,
    this.feeHead = 'ID Card Reissue Fee',
    this.feeType = 'One-time',
    required this.monthYear,
    required this.subtotal,
    required this.totalPayable,
    this.paidAmount = 0.0,
    required this.dueAmount,
    this.bankChargeRate = 0.0101,
    required this.reason,
    this.note,
    this.paymentStatus = 'Unpaid',
    this.requestStatus = 'Awaiting Payment',
    this.printedStatus = 'Not yet',
    this.collectionLocation = 'Not assigned yet',
    this.transactionId,
    this.paymentMethod,
    this.paymentDate,
  });

  double get bankChargeAmount {
    if (dueAmount <= 0) return 0.0;
    return double.parse((dueAmount * bankChargeRate).toStringAsFixed(2));
  }

  double get totalCardPayment {
    if (dueAmount <= 0) return 0.0;
    return double.parse((dueAmount + bankChargeAmount).toStringAsFixed(2));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PAGE — ID Card Replacement Order & Payment
// ════════════════════════════════════════════════════════════════════════════
class IdCardReplacementPage extends StatefulWidget {
  const IdCardReplacementPage({super.key});

  @override
  State<IdCardReplacementPage> createState() => _IdCardReplacementPageState();
}

class _IdCardReplacementPageState extends State<IdCardReplacementPage> {
  final StudentController studentCtrl = Get.isRegistered<StudentController>()
      ? Get.find<StudentController>()
      : Get.put(StudentController());

  // Available Replacement Items
  late List<IdCardItem> _items;

  // Form inputs
  String _selectedReason = 'Lost ID Card / Accessory';
  final TextEditingController _noteCtrl = TextEditingController();

  final List<String> _reasons = [
    'Lost ID Card / Accessory',
    'Damaged / Broken Card',
    'Information Correction / Update',
    'Faded Photo / Text',
    'Other Reason',
  ];

  // Submitted Orders list (in-session reactive state)
  final List<ReplacementOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _resetItems();
  }

  void _resetItems() {
    _items = [
      IdCardItem(
        id: 'std_with_ribbon',
        title: 'Student ID Card with Ribbon',
        price: 200.0,
      ),
      IdCardItem(
        id: 'std_card_only',
        title: 'Student ID Card Only (without Ribbon/Holder)',
        price: 100.0,
      ),
      IdCardItem(
        id: 'guardian_card_only',
        title: 'Guardian ID Card Only (without Ribbon/Holder)',
        price: 100.0,
      ),
      IdCardItem(
        id: 'ribbon_only',
        title: 'Ribbon Only',
        price: 70.0,
      ),
      IdCardItem(
        id: 'holder_only',
        title: 'Holder Only',
        price: 30.0,
      ),
    ];
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _orderTotal => _items.fold(0.0, (sum, item) => sum + item.total);

  String _getMonthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  String _getMonthFullName(int m) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[m - 1];
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _getMonthName(dt.month);
    final year = dt.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day-$month-$year $hour:$minute $ampm';
  }

  void _submitOrder() {
    if (_orderTotal <= 0) {
      Get.snackbar(
        'Select Item',
        'Please select at least one ID card or accessory item before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xffDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
      return;
    }

    final selectedItemsList = _items
        .where((i) => i.isSelected)
        .map((i) => '${i.title} × ${i.quantity} (Tk ${(i.price * i.quantity).toStringAsFixed(2)})')
        .toList();

    final now = DateTime.now();
    final dateStr = _formatDateTime(now);
    final count = _orders.length + 1;
    final reqId = 'IDR-${now.year}${now.month.toString().padLeft(2, '0')}-${count.toString().padLeft(6, '0')}';
    final invNumber = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}-${(295870 + count)}';
    final monthYearStr = '${_getMonthFullName(now.month)} ${now.year}';

    final newOrder = ReplacementOrder(
      requestId: reqId,
      date: dateStr,
      items: selectedItemsList,
      invoiceNumber: invNumber,
      feeHead: 'ID Card Reissue Fee',
      feeType: 'One-time',
      monthYear: monthYearStr,
      subtotal: _orderTotal,
      totalPayable: _orderTotal,
      paidAmount: 0.0,
      dueAmount: _orderTotal,
      reason: _selectedReason,
      note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      paymentStatus: 'Unpaid',
      requestStatus: 'Awaiting Payment',
      printedStatus: 'Not yet',
      collectionLocation: 'Not assigned yet',
    );

    setState(() {
      _orders.insert(0, newOrder);
      _noteCtrl.clear();
      _resetItems();
    });

    _showOrderCreatedBottomSheet(newOrder);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEET: ORDER CREATED & IMMEDIATE PAYMENT PROMPT
  // ══════════════════════════════════════════════════════════════════════════
  void _showOrderCreatedBottomSheet(ReplacementOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
          ),
          padding: const EdgeInsets.all(22),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xffCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffDCFCE7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xff86EFAC), width: 2),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xff16A34A), size: 36),
                ),
                const SizedBox(height: 14),
                Text(
                  "Order Submitted Successfully",
                  style: sansproBold.copyWith(fontSize: 18, color: const Color(0xff0F172A)),
                ),
                const SizedBox(height: 6),
                Text(
                  "Invoice #${order.invoiceNumber} has been generated.",
                  style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff64748B)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Request ID", style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B))),
                          Text(order.requestId, style: sansproBold.copyWith(fontSize: 13, color: const Color(0xff0F172A))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Fee Head", style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B))),
                          Text(order.feeHead, style: sansproSemibold.copyWith(fontSize: 12.5, color: const Color(0xff2563EB))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Invoice Due", style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B))),
                          Text("Tk ${order.dueAmount.toStringAsFixed(2)}", style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff16A34A))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xffCBD5E1)),
                        ),
                        child: Text("Track Order", style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff334155))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openOnlinePaymentModal(order);
                        },
                        icon: const Icon(Icons.payment_rounded, size: 16, color: Colors.white),
                        label: Text("Pay Online", style: sansproBold.copyWith(fontSize: 13.5, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff15803D),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ONLINE PAYMENT MODAL (Exact match to Web ERP Portal Screenshots)
  // ══════════════════════════════════════════════════════════════════════════
  void _openOnlinePaymentModal(ReplacementOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final student = studentCtrl.profile.value;
            final String studentName = student?.studentName.isNotEmpty == true ? student!.studentName : "Muaz Ibne Arif";
            final String studentId = student?.studentId.isNotEmpty == true ? student!.studentId : "2023300";
            final String className = student?.className.isNotEmpty == true ? student!.className : "Pre KG";
            final String section = student?.section.isNotEmpty == true ? student!.section : "Aqua";
            final String session = resolveCurrentAcademicSession(student?.academicYear);
            final photoUrl = student?.profilePhotoUrl ?? '';

            return Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: Color(0xffF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Modal Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(26),
                          topRight: Radius.circular(26),
                        ),
                        border: Border(bottom: BorderSide(color: Color(0xffE2E8F0))),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xffEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.credit_card_rounded, color: Color(0xff2563EB), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Online Payment",
                            style: sansproBold.copyWith(fontSize: 16.5, color: const Color(0xff0F172A)),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => Navigator.pop(modalCtx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xffF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 18, color: Color(0xff64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Payment Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Student Info Snapshot Card (Matches Screenshot 2)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xffE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xffCBD5E1), width: 1.5),
                                    ),
                                    child: ClipOval(
                                      child: photoUrl.isNotEmpty
                                          ? Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _avatarFallback(studentName),
                                            )
                                          : _avatarFallback(studentName),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: studentName,
                                                style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff0F172A)),
                                              ),
                                              TextSpan(
                                                text: " ($studentId)",
                                                style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff64748B)),
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$session | Class: $className | Section: $section",
                                          style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Pay Online Details Card (Matches Screenshot 2)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xffE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Text(
                                      "Pay Online",
                                      style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff0F172A)),
                                    ),
                                  ),
                                  const Divider(height: 1, color: Color(0xffE2E8F0)),
                                  _buildInvoiceDetailRow("Fee Head", order.feeHead),
                                  _buildInvoiceDetailRow("Fee Type", order.feeType),
                                  _buildInvoiceDetailRow("Invoice No", order.invoiceNumber),
                                  _buildInvoiceDetailRow("Month & Year", order.monthYear),
                                  _buildInvoiceDetailRow("Subtotal", "Tk ${order.subtotal.toStringAsFixed(2)}"),
                                  _buildInvoiceDetailRow("Total Payable", "Tk ${order.totalPayable.toStringAsFixed(2)}"),
                                  _buildInvoiceDetailRow("Paid", "Tk ${order.paidAmount.toStringAsFixed(2)}"),
                                  _buildInvoiceDetailRow("Due", "Tk ${order.dueAmount.toStringAsFixed(2)}", isBold: true),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. Pay by EBL SKY PAY Card (Matches Screenshot 2 & 3)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xff93C5FD), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff2563EB).withAlpha(12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffEFF6FF),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xffBFDBFE)),
                                        ),
                                        child: Text(
                                          "EBL SKY PAY",
                                          style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff1D4ED8)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Pay by EBL SKY PAY",
                                        style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0F172A)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Secure card payment through EBL SKY PAY / Visa CyberSource hosted checkout. A 1.01% bank card charge is added after the applicable late fine.",
                                    style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B), height: 1.35),
                                  ),
                                  const SizedBox(height: 14),

                                  Text(
                                    "Payment Breakdown",
                                    style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
                                  ),
                                  const SizedBox(height: 8),

                                  // Inner breakdown box
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xffE2E8F0)),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Invoice Due", style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff475569))),
                                            Text("Tk ${order.dueAmount.toStringAsFixed(2)}", style: sansproBold.copyWith(fontSize: 13, color: const Color(0xff0F172A))),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Bank Card Charge (1.01%)", style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff475569))),
                                            Text("+ Tk ${order.bankChargeAmount.toStringAsFixed(2)}", style: sansproBold.copyWith(fontSize: 13, color: const Color(0xffD97706))),
                                          ],
                                        ),
                                        const Divider(height: 16, color: Color(0xffE2E8F0)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Total Card Payment", style: sansproBold.copyWith(fontSize: 13, color: const Color(0xff0F172A))),
                                            Text("Tk ${order.totalCardPayment.toStringAsFixed(2)}", style: sansproBold.copyWith(fontSize: 16, color: const Color(0xff16A34A))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Pay by card button (Dark Blue corporate button)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _processCardPayment(modalCtx, order);
                                      },
                                      icon: const Icon(Icons.lock_rounded, size: 16, color: Colors.white),
                                      label: Text(
                                        "Pay by card",
                                        style: sansproBold.copyWith(fontSize: 14, color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xff0D3B66),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Back to Dues Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(modalCtx),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: const BorderSide(color: Color(0xffCBD5E1)),
                                ),
                                child: Text(
                                  "Back to Dues",
                                  style: sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff334155)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInvoiceDetailRow(String label, String value, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff64748B)),
          ),
          Text(
            value,
            style: isBold
                ? sansproBold.copyWith(fontSize: 13.5, color: const Color(0xff0F172A))
                : sansproSemibold.copyWith(fontSize: 13, color: const Color(0xff1E293B)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAYMENT PROCESSING & SUCCESS DIALOG
  // ══════════════════════════════════════════════════════════════════════════
  void _processCardPayment(BuildContext modalCtx, ReplacementOrder order) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final modalNavigator = Navigator.of(modalCtx);

    // Show Loading Gateway Simulator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loaderCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: Color(0xff0D3B66),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Connecting to EBL SKY PAY...",
                  style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff0F172A)),
                ),
                const SizedBox(height: 6),
                Text(
                  "Processing Visa/CyberSource secure token payment...",
                  textAlign: TextAlign.center,
                  style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate gateway roundtrip
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    // Close loader
    navigator.pop();

    // Close online payment modal
    modalNavigator.pop();

    final now = DateTime.now();
    final txnId = 'TXN-EBL-${now.year}${now.month.toString().padLeft(2, '0')}-${(348000 + Random().nextInt(9000))}';
    final paidDateStr = _formatDateTime(now);

    // Update the Order status to Paid & In Print Queue
    setState(() {
      order.paymentStatus = 'Paid';
      order.requestStatus = 'Payment Verified / In Print Queue';
      order.paidAmount = order.totalPayable;
      order.dueAmount = 0.0;
      order.printedStatus = 'In Print Queue';
      order.collectionLocation = 'IT Helpdesk, 2nd Floor (Admin Building)';
      order.transactionId = txnId;
      order.paymentMethod = 'EBL SKY PAY (Visa/Mastercard)';
      order.paymentDate = paidDateStr;
    });

    _showPaymentSuccessReceipt(order);
  }

  void _showPaymentSuccessReceipt(ReplacementOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xffCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffDCFCE7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xff86EFAC), width: 2),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xff16A34A), size: 40),
                ),
                const SizedBox(height: 14),
                Text(
                  "Payment Successful!",
                  style: sansproBold.copyWith(fontSize: 19, color: const Color(0xff0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tk ${(order.paidAmount * (1 + order.bankChargeRate)).toStringAsFixed(2)} paid via EBL SKY PAY",
                  style: sansproSemibold.copyWith(fontSize: 13.5, color: const Color(0xff16A34A)),
                ),
                const SizedBox(height: 16),

                // Transaction Receipt Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Transaction ID", style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B))),
                          Text(order.transactionId ?? '—', style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff0F172A))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Invoice No", style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B))),
                          Text(order.invoiceNumber, style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff2563EB))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Request Status", style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xffEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.requestStatus,
                              style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff1D4ED8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Collection Point", style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B))),
                          Flexible(
                            child: Text(
                              order.collectionLocation,
                              textAlign: TextAlign.right,
                              style: sansproSemibold.copyWith(fontSize: 11.5, color: const Color(0xff334155)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Info note
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xff2563EB)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Your ID card replacement request is now in the print queue. You will receive an SMS/notification once ready for pickup.",
                          style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff1E40AF), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WireframeColor.appcolor,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      "Done & View Orders",
                      style: sansproBold.copyWith(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final student = studentCtrl.profile.value;
    final String studentName = student?.studentName.isNotEmpty == true ? student!.studentName : "Muaz Ibne Arif";
    final String studentId = student?.studentId.isNotEmpty == true ? student!.studentId : "2023300";
    final String className = student?.className.isNotEmpty == true ? student!.className : "Pre KG";
    final String section = student?.section.isNotEmpty == true ? student!.section : "Aqua";
    final String session = resolveCurrentAcademicSession(student?.academicYear);

    return Scaffold(
      body: PageBackground(
        category: PageCategory.complain,
        showHeader: true,
        child: SafeArea(
          child: Column(
            children: [
              // Top Header Bar
              _buildTopBar(context),

              // Body Section Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xffF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: w / 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Student Profile Card
                        _buildStudentProfileCard(
                          student: student,
                          studentName: studentName,
                          studentId: studentId,
                          className: className,
                          section: section,
                          session: session,
                          width: w,
                          height: h,
                        ),
                        const SizedBox(height: 16),

                        // 2. New Replacement Request Card
                        _buildNewRequestCard(w),
                        const SizedBox(height: 20),

                        // 3. My Replacement Orders Card (Matches Web ERP Portal Image)
                        _buildMyOrdersCard(w),
                        SizedBox(height: h / 20),
                      ],
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

  // ══════════════════════════════════════════════════════════════════════════
  // TOP BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "ID Card Replacement Order",
                      style: sansproBold.copyWith(fontSize: 17, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Submit replacement request, pay invoice & track printing",
                  style: sansproRegular.copyWith(fontSize: 11.5, color: Colors.white.withAlpha(200)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _resetItems();
                _noteCtrl.clear();
              });
              Get.snackbar(
                'Refreshed',
                'ID card replacement form has been reset.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xff1E293B),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 10,
                duration: const Duration(seconds: 2),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STUDENT PROFILE CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStudentProfileCard({
    required StudentProfile? student,
    required String studentName,
    required String studentId,
    required String className,
    required String section,
    required String session,
    required double width,
    required double height,
  }) {
    final photoUrl = student?.profilePhotoUrl ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: WireframeColor.appcolor.withAlpha(140),
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: WireframeColor.appcolor.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(studentName),
                    )
                  : _avatarFallback(studentName),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: sansproBold.copyWith(
                    fontSize: 16.5,
                    color: const Color(0xff0F172A),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xffBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pin_rounded, size: 12, color: Color(0xff2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            "ID: $studentId",
                            style: sansproBold.copyWith(fontSize: 11.5, color: const Color(0xff1D4ED8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xffE2E8F0)),
                      ),
                      child: Text(
                        "Class: $className - $section",
                        style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff475569)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xffECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xffA7F3D0)),
                      ),
                      child: Text(
                        "Session: $session",
                        style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff059669)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    String initials = "ST";
    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0][0].toUpperCase();
    }

    return Container(
      color: const Color(0xff0284C7).withAlpha(25),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: sansproBold.copyWith(
          fontSize: 22,
          color: const Color(0xff0284C7),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NEW REPLACEMENT REQUEST CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildNewRequestCard(double width) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Replacement Request",
            style: sansproBold.copyWith(fontSize: 16.5, color: const Color(0xff0F172A)),
          ),
          const SizedBox(height: 12),

          // Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xff2563EB), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff1E40AF), height: 1.35),
                      children: [
                        TextSpan(
                          text: "Invoice Fee Head: ",
                          style: sansproBold.copyWith(color: const Color(0xff1E3A8A)),
                        ),
                        TextSpan(
                          text: "ID Card Reissue Fee. ",
                          style: sansproBold.copyWith(color: const Color(0xff2563EB)),
                        ),
                        const TextSpan(
                          text: "Select one or more items below. Prices are calculated from the approved replacement item setup.",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Replacement Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _items[index];
              return _buildItemRow(item);
            },
          ),
          const SizedBox(height: 18),

          // Replacement Reason Dropdown
          Text(
            "Replacement Reason",
            style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xffF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReason,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff64748B)),
                style: sansproSemibold.copyWith(fontSize: 13.5, color: const Color(0xff0F172A)),
                items: _reasons.map((r) {
                  return DropdownMenuItem<String>(
                    value: r,
                    child: Text(r),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedReason = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Student Note (Optional)
          Text(
            "Student Note (optional)",
            style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff334155)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff0F172A)),
            decoration: InputDecoration(
              hintText: "Add any useful details for the IT team",
              hintStyle: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff94A3B8)),
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              contentPadding: const EdgeInsets.all(12),
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
                borderSide: const BorderSide(color: Color(0xff2563EB), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Order Total & Submit Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Total",
                      style: sansproRegular.copyWith(fontSize: 11, color: const Color(0xff64748B)),
                    ),
                    Text(
                      "Tk ${_orderTotal.toStringAsFixed(2)}",
                      style: sansproBold.copyWith(fontSize: 18, color: const Color(0xff0F172A)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _submitOrder,
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 16, color: Colors.white),
                  label: Text(
                    "Submit & Pay Online",
                    style: sansproBold.copyWith(fontSize: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WireframeColor.appcolor,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ITEM ROW WITH CHECKBOX & STEPPER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildItemRow(IdCardItem item) {
    final isSelected = item.isSelected;

    return InkWell(
      onTap: () {
        setState(() {
          item.quantity = isSelected ? 0 : 1;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffEFF6FF) : const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xff3B82F6) : const Color(0xffE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? const Color(0xff2563EB) : const Color(0xffCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: sansproBold.copyWith(
                      fontSize: 13.5,
                      color: isSelected ? const Color(0xff1E40AF) : const Color(0xff0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Tk ${item.price.toStringAsFixed(2)}",
                    style: sansproBold.copyWith(
                      fontSize: 13,
                      color: const Color(0xff16A34A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      if (item.quantity > 0) {
                        setState(() => item.quantity--);
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.remove_rounded,
                        size: 16,
                        color: item.quantity > 0 ? const Color(0xff0F172A) : const Color(0xffCBD5E1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "${item.quantity}",
                      style: sansproBold.copyWith(
                        fontSize: 14,
                        color: item.quantity > 0 ? const Color(0xff0F172A) : const Color(0xff64748B),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => item.quantity++);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: Color(0xff0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MY REPLACEMENT ORDERS CARD (Matches Screenshot 1 Exactly)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMyOrdersCard(double width) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Replacement Orders",
                style: sansproBold.copyWith(fontSize: 16.5, color: const Color(0xff0F172A)),
              ),
              if (_orders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xffEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${_orders.length} ${_orders.length == 1 ? 'Order' : 'Orders'}",
                    style: sansproBold.copyWith(fontSize: 11, color: const Color(0xff2563EB)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_orders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xffF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: Color(0xff94A3B8), size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No replacement order has been submitted.",
                      style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final order = _orders[index];
                return _buildOrderCard(order);
              },
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ORDER CARD (Matches Columns in Screenshot 1)
  // REQUEST / DATE | ITEMS | INVOICE | PAYMENT | REQUEST STATUS | PRINT & COLLECTION | ACTION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildOrderCard(ReplacementOrder order) {
    final bool isPaid = order.paymentStatus == 'Paid';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid ? const Color(0xff86EFAC) : const Color(0xffE2E8F0),
          width: isPaid ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Request ID + Date + Status Badges
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPaid ? const Color(0xffF0FDF4) : const Color(0xffF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: const Border(bottom: BorderSide(color: Color(0xffE2E8F0))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.requestId,
                        style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.date,
                        style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    _buildPaymentBadge(order.paymentStatus),
                    _buildRequestStatusBadge(order.requestStatus, isPaid: isPaid),
                  ],
                ),
              ],
            ),
          ),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.layers_outlined, size: 16, color: Color(0xff64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.items.join(', '),
                        style: sansproSemibold.copyWith(fontSize: 13, color: const Color(0xff1E293B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Invoice & Amounts Row
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "INVOICE",
                              style: sansproBold.copyWith(fontSize: 10, color: const Color(0xff94A3B8), letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.invoiceNumber,
                              style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff0F172A)),
                            ),
                            Text(
                              "Total: Tk ${order.totalPayable.toStringAsFixed(2)}",
                              style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 36, width: 1, color: const Color(0xffCBD5E1)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPaid ? "PAID AMOUNT" : "AMOUNT DUE",
                              style: sansproBold.copyWith(
                                fontSize: 10,
                                color: isPaid ? const Color(0xff15803D) : const Color(0xffD97706),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPaid ? "Tk ${order.paidAmount.toStringAsFixed(2)}" : "Due: Tk ${order.dueAmount.toStringAsFixed(2)}",
                              style: sansproBold.copyWith(
                                fontSize: 13.5,
                                color: isPaid ? const Color(0xff16A34A) : const Color(0xffD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Print & Collection Info (Matches Screenshot 1)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isPaid ? Icons.print_rounded : Icons.print_disabled_rounded,
                                size: 14,
                                color: isPaid ? const Color(0xff2563EB) : const Color(0xff94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Printed: ${order.printedStatus}",
                                style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff475569)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: isPaid ? const Color(0xff16A34A) : const Color(0xff94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Collect from: ${order.collectionLocation}",
                                  style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff475569)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Action Button (Pay Online or View Receipt)
                    if (!isPaid)
                      ElevatedButton.icon(
                        onPressed: () => _openOnlinePaymentModal(order),
                        icon: const Icon(Icons.payment_rounded, size: 15, color: Colors.white),
                        label: Text(
                          "Pay Online",
                          style: sansproBold.copyWith(fontSize: 12.5, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff15803D), // Green Action button matching screenshot
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => _showPaymentSuccessReceipt(order),
                        icon: const Icon(Icons.receipt_long_rounded, size: 15, color: Color(0xff15803D)),
                        label: Text(
                          "Receipt",
                          style: sansproBold.copyWith(fontSize: 12, color: const Color(0xff15803D)),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xff86EFAC)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String status) {
    final bool isPaid = status == 'Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xffDCFCE7) : const Color(0xffFEF3C7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPaid ? const Color(0xff86EFAC) : const Color(0xffFDE68A),
        ),
      ),
      child: Text(
        status,
        style: sansproBold.copyWith(
          fontSize: 11,
          color: isPaid ? const Color(0xff15803D) : const Color(0xffB45309),
        ),
      ),
    );
  }

  Widget _buildRequestStatusBadge(String status, {bool isPaid = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xffEFF6FF) : const Color(0xffFEF3C7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPaid ? const Color(0xffBFDBFE) : const Color(0xffFDE68A),
        ),
      ),
      child: Text(
        status,
        style: sansproBold.copyWith(
          fontSize: 11,
          color: isPaid ? const Color(0xff1D4ED8) : const Color(0xffB45309),
        ),
      ),
    );
  }
}
