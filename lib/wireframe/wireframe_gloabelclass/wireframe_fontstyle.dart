import 'package:flutter/material.dart';

// ── গলোবাল ভেরিয়েবল (পুরো প্রজেক্টের সব পেজ সরাসরি এটি ব্যবহার করবে) ──
const TextStyle sansproBold = TextStyle(
  fontFamily: "SourceSansProBold",
  fontWeight: FontWeight.bold,
);

const TextStyle sansproRegular = TextStyle(
  fontFamily: "SourceSansProRegular",
  fontWeight: FontWeight.normal,
);

const TextStyle sansproSemibold = TextStyle(
  fontFamily: "SourceSansProSemibold",
  fontWeight: FontWeight.w600,
);

// ── ক্লাস ভিত্তিক ব্যাকআপ (যদি কোনো ফাইলে ক্লাসের নাম দিয়েও কল করা থাকে) ──
class WireframeTextStyle {
  WireframeTextStyle._();

  static const TextStyle sansproBold = TextStyle(
    fontFamily: "SourceSansProBold",
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sansproRegular = TextStyle(
    fontFamily: "SourceSansProRegular",
    fontWeight: FontWeight.normal,
  );

  static const TextStyle sansproSemibold = TextStyle(
    fontFamily: "SourceSansProSemibold",
    fontWeight: FontWeight.w600,
  );
}