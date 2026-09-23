import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_session.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../wireframe_home/wireframe_home.dart';
import '../wireframe_home/student_controller.dart';
import '../wireframe_home/routine_controller.dart';
import '../wireframe_home/live_class_controller.dart';
import '../wireframe_home/teachers_materials_controller.dart';
import '../wireframe_home/smart_classroom_controller.dart';
import '../wireframe_home/homework_controller.dart';
import '../wireframe_home/syllabus_controller.dart';
import '../wireframe_home/bus_controller.dart';
import '../wireframe_home/fees_controller.dart';
import '../wireframe_home/report_card_controller.dart';
import '../wireframe_home/attendance_controller.dart';
import '../wireframe_home/exam_controller.dart';
import '../wireframe_home/notification_controller.dart';
import '../wireframe_home/lookup_controller.dart';
import '../wireframe_driver/driver_controller.dart';
import '../wireframe_driver/driver_dashboard_page.dart';

class WireframeLogin extends StatefulWidget {
  const WireframeLogin({Key? key}) : super(key: key);

  @override
  State<WireframeLogin> createState() => _WireframeLoginState();

  // ── Student controller-gulo real token diye activate kora — login flow ar
  // splash-e (persistent session restore)
  // ekhane static kore rakha hoyeche jate duplicate kora na lage। ──
  static void activateStudentControllers(String token) {
    final studentCtrl = Get.put(StudentController());
    studentCtrl.setAuthToken(token);

    final routineCtrl = Get.put(RoutineController());
    routineCtrl.setAuthToken(token);

    final liveCtrl = Get.put(LiveClassController());
    liveCtrl.setAuthToken(token);

    final materialsCtrl = Get.put(TeachersMaterialsController());
    materialsCtrl.setAuthToken(token);

    final smartCtrl = Get.put(SmartClassroomController());
    smartCtrl.setAuthToken(token);

    final hwCtrl = Get.put(HomeworkController());
    hwCtrl.setAuthToken(token);

    final syCtrl = Get.put(SyllabusController());
    syCtrl.setAuthToken(token);

    final busCtrl = Get.put(BusController());
    busCtrl.setAuthToken(token);

    final feesCtrl = Get.put(FeesController());
    feesCtrl.setAuthToken(token);

    final rcCtrl = Get.put(ReportCardController());
    rcCtrl.setAuthToken(token);

    final attCtrl = Get.put(AttendanceController());
    attCtrl.setAuthToken(token);

    final examCtrl = Get.put(ExamController());
    examCtrl.setAuthToken(token);

    final notifCtrl = Get.put(NotificationController());
    notifCtrl.setAuthToken(token);

    final lookupCtrl = Get.put(LookupController());
    lookupCtrl.setAuthToken(token);

    // Initial pre-fetching
    studentCtrl.fetchProfile();
    routineCtrl.fetchRoutine();
    liveCtrl.fetchTodayLiveClasses();
    materialsCtrl.fetchClasses();
    materialsCtrl.fetchDocuments();
    materialsCtrl.fetchAnnouncements();
    smartCtrl.fetchSmartClassroom();
    hwCtrl.fetchHomeworkList();
    syCtrl.fetchSyllabusList();
    busCtrl.fetchSchedule();
    busCtrl.fetchBusLog();
    feesCtrl.fetchFeesData();
    rcCtrl.fetchExamList();
    rcCtrl.fetchAttendanceSummary();
    attCtrl.fetchMonthAttendance(DateTime.now());
    examCtrl.fetchExamList();
    notifCtrl.fetchDashboardSummary();
    notifCtrl.fetchNotifications();
    lookupCtrl.fetchAllLookups();
  }
}

class _WireframeLoginState extends State<WireframeLogin>
    with TickerProviderStateMixin {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(WireframeThemecontroler());
  bool _obscureText = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  static const String _baseUrl = 'https://averroesint.com/averroes_school_erp/api';
  static const String _loginEndpoint = '/login';

  late AnimationController _floatController;
  late AnimationController _starController;
  late AnimationController _formController;
  late AnimationController _logoController;

  late Animation<double> _floatAnimation;
  late Animation<double> _starAnimation;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  void _togglePasswordStatus() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _starAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _formSlideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.fastOutSlowIn),
    );
    _formFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeIn),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _starController.dispose();
    _formController.dispose();
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final emailOrPhone = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrPhone.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Phone/Email এবং Password দুটোই দাও।');
      return;
    }

    setState(() => _isLoggingIn = true);

    final isDriverLogin = emailOrPhone.toLowerCase().startsWith('driver');

    if (isDriverLogin) {
      await _loginAsDriver(emailOrPhone, password);
      return;
    }

    // Try student login first; if invalid credentials, seamlessly attempt driver login fallback
    await _loginAsStudent(emailOrPhone, password);
  }

  // ══════════════════════════════════════════════════════════════════════
  // DRIVER FLOW — REAL API (Transport Mobile API doc: POST
  // /api/v1/transport/login.php). Age backend broken bole bypass kora
  // hoyeche, kintu ekhon confirmed working spec + real test credential
  // (driver1/333333) paoya gecche — tai real call e restore kora holo।
  // Fail hole (invalid credential/server error) sposto error dekhiye login
  // page e e i rakha hobe, kono fake/demo dashboard access na diye।
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _loginAsDriver(String emailOrPhone, String password) async {
    final driverCtrl = Get.put(DriverController());

    final result = await driverCtrl.login(login: emailOrPhone, password: password);

    if (!mounted) return;

    if (result['success'] != true || driverCtrl.authToken == null) {
      setState(() => _isLoggingIn = false);
      Get.snackbar(
        'Login Failed',
        result['message']?.toString() ?? 'Invalid credentials. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: WireframeColor.white,
        margin: const EdgeInsets.all(14),
      );
      return;
    }

    // ── Real backend token diye e session save kora hocche — app abar
    // khule o driver login-e thakbe, sudhu manual Logout-e clear hobe ──
    await WireframeSession.saveSession(token: driverCtrl.authToken!, role: 'driver');

    if (!mounted) return;
    setState(() => _isLoggingIn = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DriverDashboardPage()),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STUDENT FLOW — REAL API ONLY (POST /login)
  //
  // Kono bypass/demo/local-session token nei. Dashboard e sudhu tokhoni
  // dhoka jabe jokhon backend theke real success response + real token
  // ashbe. API fail korle, timeout hole, ba invalid credential hole —
  // sposto error message dekhiye login page e e i atkiye rakha hobe.
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _loginAsStudent(String emailOrPhone, String password) async {
    String? token;
    String errorMessage = 'Invalid Phone/Email or Password. Please try again.';

    try {
      final uri = Uri.parse('$_baseUrl$_loginEndpoint');
      final response = await http
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': emailOrPhone,
          'password': password,
          // ── v1.1 Integration Guide onujayi optional but recommended ──
          'device_name': 'Android App',
        }),
      )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic>? decoded;
      try {
        decoded = json.decode(response.body) as Map<String, dynamic>?;
      } catch (_) {
        decoded = null;
      }

      // ── v1.1 Integration Guide: "Success data: access_token/token" —
      // the field name is left ambiguous in the doc, so both are checked
      // (whichever is present is used as the token) ──
      final data = decoded != null ? decoded['data'] as Map<String, dynamic>? : null;
      final rawToken = data?['access_token'] ?? data?['token'];

      if (response.statusCode == 200 &&
          decoded != null &&
          decoded['status'] == 'success' &&
          rawToken != null &&
          rawToken.toString().isNotEmpty) {
        token = rawToken.toString();
      } else if (response.statusCode == 500) {
        // HTTP 500 = a server-side crash on the backend, not something the
        // app can fix. Always show the raw response body (truncated) here —
        // whether or not it happens to be valid JSON with a "message" —
        // because that raw text usually contains the actual PHP
        // exception/error line the backend team needs. This is a
        // TEMPORARY debug aid; remove it once the backend issue is fixed.
        final requestId = decoded != null ? decoded['request_id']?.toString() : null;
        final rawBody = response.body.trim();
        if (rawBody.isNotEmpty) {
          final preview = rawBody.length > 400 ? '${rawBody.substring(0, 400)}...' : rawBody;
          errorMessage = 'Server error (500).\n\nRaw response:\n$preview';
        } else {
          errorMessage =
          'Server error (500) — backend returned an empty response.${requestId != null ? ' (ref: $requestId)' : ''}';
        }
      } else if (decoded != null && decoded['message'] != null) {
        errorMessage = decoded['message'].toString();
      } else if (response.statusCode != 200) {
        errorMessage = 'Server error (${response.statusCode}). Please try again.';
      }
    } on TimeoutException {
      errorMessage = 'Server response e deri hocche. Abar try koro.';
    } catch (_) {
      errorMessage = 'Server e connect kora jacche na. Internet connection check koro.';
    }

    // If student login failed, seamlessly check if user is a driver (e.g. driver using phone/email without 'driver' prefix)
    if (token == null || token.isEmpty) {
      final driverCtrl = Get.put(DriverController());
      final driverResult = await driverCtrl.login(login: emailOrPhone, password: password);
      if (driverResult['success'] == true && driverCtrl.authToken != null && driverCtrl.authToken!.isNotEmpty) {
        await WireframeSession.saveSession(token: driverCtrl.authToken!, role: 'driver');
        if (!mounted) return;
        setState(() => _isLoggingIn = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverDashboardPage()),
        );
        return;
      }

      if (!mounted) return;
      setState(() => _isLoggingIn = false);

      if (errorMessage.contains('Raw response:')) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Login Failed — Server Error (500)'),
            content: SingleChildScrollView(
              child: SelectableText(errorMessage, style: const TextStyle(fontSize: 13)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: errorMessage));
                  Get.snackbar('Copied', 'Error text copied — send this to the backend developer.',
                      snackPosition: SnackPosition.BOTTOM);
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'Login Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: WireframeColor.white,
          margin: const EdgeInsets.all(14),
          duration: const Duration(seconds: 8),
          isDismissible: true,
        );
      }
      return;
    }

    // ── Login session device-e save kora hocche — app abar khule o user
    // login-e i thakbe, sudhu manual "Logout" chaple e session clear hobe ──
    await WireframeSession.saveSession(token: token, role: 'student');

    WireframeLogin.activateStudentControllers(token);

    if (!mounted) return;
    setState(() => _isLoggingIn = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WireframeHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: WireframeColor.appcolor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    // Bright Vibrant App Theme Gradient Background (Matching Averroes project theme)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff2A55B8),
                              WireframeColor.appcolor,
                              Color(0xff4575DC),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),

                    // Twinkling stars
                    AnimatedBuilder(
                      animation: _starAnimation,
                      builder: (_, __) => Positioned.fill(
                        child: CustomPaint(
                          painter: _StarsPainter(opacity: _starAnimation.value),
                        ),
                      ),
                    ),

                    // Main Layout Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Header (Logo + School Name)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            width / 18,
                            MediaQuery.of(context).padding.top + 14,
                            width / 18,
                            0,
                          ),
                          child: AnimatedBuilder(
                            animation: _logoController,
                            builder: (_, __) {
                              return Opacity(
                                opacity: _logoFadeAnimation.value,
                                child: Transform.scale(
                                  scale: _logoScaleAnimation.value,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(30),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(3.5),
                                        child: ClipOval(
                                          child: Image.asset(
                                            WireframePngimage.averroesLogo,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width / 26),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Averroes International",
                                              style: sansproBold.copyWith(
                                                fontSize: 18,
                                                color: Colors.white,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "School Lalmatia",
                                              style: sansproBold.copyWith(
                                                fontSize: 18,
                                                color: Colors.white,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Greeting on Left + Floating Illustration on Right (Enlarged prominent size with guaranteed single-line text)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width / 18),
                          child: SizedBox(
                            height: 185,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              clipBehavior: Clip.none,
                              children: [
                                // Floating Illustration on Right (Large size)
                                Positioned(
                                  right: -6,
                                  top: 0,
                                  bottom: 0,
                                  child: AnimatedBuilder(
                                    animation: _floatAnimation,
                                    builder: (_, __) {
                                      return Transform.translate(
                                        offset: Offset(0, _floatAnimation.value),
                                        child: Image.asset(
                                          WireframePngimage.titlelogo,
                                          height: 185,
                                          width: 215,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Greeting on Left (Single line for both Hi Student and Sign in to continue)
                                Positioned(
                                  left: 0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Hi_Student".tr,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: sansproBold.copyWith(
                                          fontSize: 28,
                                          color: Colors.white,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Sign_in_to_continue".tr,
                                        maxLines: 1,
                                        softWrap: false,
                                        style: sansproRegular.copyWith(
                                          fontSize: 15,
                                          color: Colors.white.withAlpha(215),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── WHITE FORM CARD ──
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _formController,
                            builder: (_, child) {
                              return Transform.translate(
                                offset: Offset(0, _formSlideAnimation.value),
                                child: Opacity(
                                  opacity: _formFadeAnimation.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              width: width,
                              decoration: BoxDecoration(
                                color: themedata.isdark
                                    ? WireframeColor.black
                                    : WireframeColor.white,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(32),
                                  topLeft: Radius.circular(32),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 18,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width / 12,
                                  vertical: height / 52,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 38,
                                        height: 4,
                                        margin: EdgeInsets.only(bottom: height / 64),
                                        decoration: BoxDecoration(
                                          color: WireframeColor.bggray,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),

                                    Text(
                                      "Username",
                                      style: sansproRegular.copyWith(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: themedata.isdark
                                            ? WireframeColor.appgray
                                            : WireframeColor.textgray,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 42,
                                      child: TextField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        style: sansproRegular.copyWith(
                                          fontSize: 14.5,
                                          color: themedata.isdark
                                              ? WireframeColor.white
                                              : WireframeColor.black,
                                        ),
                                        cursorColor: WireframeColor.appcolor,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                                          isDense: true,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: WireframeColor.bggray),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: WireframeColor.appcolor, width: 1.8),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: height / 45),

                                    Text(
                                      "Password",
                                      style: sansproRegular.copyWith(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: themedata.isdark
                                            ? WireframeColor.appgray
                                            : WireframeColor.textgray,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 42,
                                      child: TextField(
                                        controller: _passwordController,
                                        obscureText: _obscureText,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _isLoggingIn ? null : _login(),
                                        style: sansproRegular.copyWith(
                                          fontSize: 14.5,
                                          color: themedata.isdark
                                              ? WireframeColor.white
                                              : WireframeColor.black,
                                        ),
                                        cursorColor: WireframeColor.appcolor,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                          isDense: true,
                                          suffixIcon: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: Icon(
                                              _obscureText ? Icons.visibility_off : Icons.visibility,
                                              color: WireframeColor.textgray,
                                              size: 19,
                                            ),
                                            onPressed: _togglePasswordStatus,
                                          ),
                                          enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(color: WireframeColor.bggray),
                                          ),
                                          focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(color: WireframeColor.appcolor, width: 1.8),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: height / 32),

                                    InkWell(
                                      highlightColor: WireframeColor.transparent,
                                      splashColor: WireframeColor.transparent,
                                      onTap: _isLoggingIn ? null : _login,
                                      child: Container(
                                        width: width,
                                        height: height / 17,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [WireframeColor.appcolor, WireframeColor.lightappcolor],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: WireframeColor.appcolor.withAlpha(90),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: _isLoggingIn
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.4,
                                                    color: WireframeColor.white,
                                                  ),
                                                )
                                              : Text(
                                                  "SIGN_IN".tr,
                                                  style: sansproSemibold.copyWith(
                                                    fontSize: 15.5,
                                                    color: WireframeColor.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── ORIGINAL SPACIOUS FOOTER WITH COPYRIGHT ONLY (NO PHONE NUMBERS) ──
                        Container(
                          width: width,
                          padding: EdgeInsets.fromLTRB(
                            width / 22,
                            height / 44,
                            width / 22,
                            height / 38,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xff1B3E8C), WireframeColor.appcolor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: Text(
                              "Copyright © 2026 Averroes International School Lalmatia.",
                              textAlign: TextAlign.center,
                              style: sansproRegular.copyWith(
                                fontSize: 11.5,
                                color: Colors.white.withAlpha(210),
                                letterSpacing: 0.2,
                              ),
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
        },
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double opacity;
  _StarsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha((opacity * 255).toInt());
    final positions = [
      Offset(size.width * 0.08, size.height * 0.04),
      Offset(size.width * 0.22, size.height * 0.11),
      Offset(size.width * 0.48, size.height * 0.06),
      Offset(size.width * 0.72, size.height * 0.09),
      Offset(size.width * 0.32, size.height * 0.15),
      Offset(size.width * 0.12, size.height * 0.20),
    ];
    for (var i = 0; i < positions.length; i++) {
      final r = (i % 2 == 0) ? 2.0 : 1.3;
      canvas.drawCircle(positions[i], r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.opacity != opacity;
}