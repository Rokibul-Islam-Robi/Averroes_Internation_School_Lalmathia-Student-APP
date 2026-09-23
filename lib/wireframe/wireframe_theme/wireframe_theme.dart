import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';

// আপনার নতুন প্রজেক্টের নাম অনুযায়ী যদি এই পাথগুলো পরিবর্তন করতে হয়, তবে '../' এর জায়গায় সঠিক পাথ দিন।
import '../wireframe_gloabelclass/wireframe_color.dart';

class WireframeMythemes {
  // ── Light Theme ──
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: WireframeColor.appcolor,
    fontFamily: 'SourceSansProRegular',
    scaffoldBackgroundColor: WireframeColor.white,
    colorScheme: const ColorScheme.light(
      primary: WireframeColor.appcolor,
    ),
    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(color: WireframeColor.black),
      centerTitle: true,
      elevation: 0,
      titleTextStyle: sansproRegular.copyWith(
        color: WireframeColor.black,
        fontSize: 16,
      ),
      backgroundColor: WireframeColor.transparent, // ২য় কোডের 'color' পরিবর্তন করে আধুনিক 'backgroundColor' রাখা হলো
    ),
  );

  // ── Dark Theme ──
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: WireframeColor.appcolor,
    fontFamily: 'SourceSansProRegular',
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: WireframeColor.appcolor,
    ),
    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(color: WireframeColor.white),
      centerTitle: true,
      elevation: 0,
      titleTextStyle: sansproRegular.copyWith(
        color: WireframeColor.white,
        fontSize: 15, // আপনি চাইলে এটিকে ১৬ করে দিতে পারেন
      ),
      backgroundColor: WireframeColor.transparent, // এখানেও 'backgroundColor' ব্যবহার করা হয়েছে
    ),
  );
}