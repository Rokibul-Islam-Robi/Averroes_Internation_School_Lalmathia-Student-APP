import 'package:flutter/material.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// একটি সম্পূর্ণ Reusable এবং Crash-Protected Dropdown Widget।
/// এটি Class, Section, Subject বা Session সব জায়গাতেই ব্যবহার করা যাবে।
/// ════════════════════════════════════════════════════════════════════════════
class LookupDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final bool enabled;

  const LookupDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.hintText = "Select",
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // সেফটি চেক: ভ্যালু যদি লিস্টে না থাকে তবে নাল করে দেওয়া, যাতে অ্যাপ ক্র্যাশ না করে
    final T? safeValue = items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ড্রপডাউন লেবেল
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: WireframeColor.textgray,
          ),
        ),
        const SizedBox(height: 6),

        // ড্রپডাউন কন্টেইনার
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: enabled ? WireframeColor.lightgray : WireframeColor.bggray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? WireframeColor.bggray : WireframeColor.lightgray,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: safeValue,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? WireframeColor.appcolor : WireframeColor.textgray,
                size: 22,
              ),
              hint: Text(
                hintText,
                style: const TextStyle(
                  fontSize: 14,
                  color: WireframeColor.textgray,
                ),
              ),
              // আইটেম ম্যাপিং
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    labelBuilder(item),
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled ? WireframeColor.black : WireframeColor.textgray,
                    ),
                  ),
                );
              }).toList(),
              // ডিজেবল থাকলে onChanged নাল থাকবে
              onChanged: enabled ? onChanged : null,

              // ড্রপডাউন মেনু ব্যাকগ্রাউন্ড কালার (অপশনাল, দেখতে সুন্দর লাগে)
              dropdownColor: WireframeColor.lightgray,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}