import 'package:flutter/material.dart';
import 'fees_overview_page.dart';

// এই class টা রাখা হয়েছে কারণ wireframe_home.dart এটাকে import করে।
// এটা এখন সরাসরি নতুন FeesOverviewPage-এ redirect করে।
class WireframeFeesDue extends StatelessWidget {
  const WireframeFeesDue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // আগের code replace করে নতুন page দেখাচ্ছি
    return const FeesOverviewPage();
  }
}