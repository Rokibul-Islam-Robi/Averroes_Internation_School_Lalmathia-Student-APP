import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_Authentication/wireframe_splash.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/deep_link_handler.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_theme.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import 'package:averroes_student_app/wireframe/wireframe_translation/stringtranslation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themedata = Get.put(WireframeThemecontroler());

  @override
  void initState() {
    super.initState();
    // Deep link handler initialize করো — cold start + warm start দুটোই handle করবে
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkHandler.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themedata.isdark
          ? WireframeMythemes.darkTheme
          : WireframeMythemes.lightTheme,
      fallbackLocale: const Locale('en', 'US'),
      translations: WireframeApptranslation(),
      locale: const Locale('en', 'US'),
      home: const WireframeSplash(),
    );
  }
}
