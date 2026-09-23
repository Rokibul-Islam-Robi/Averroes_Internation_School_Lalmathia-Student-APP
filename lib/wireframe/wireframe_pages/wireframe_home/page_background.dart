import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PageBackground — category-aware modern decorative background
//
// Usage:
//   PageBackground(
//     category: PageCategory.examination,
//     child: YourScaffoldBody(),
//   )
//
// The widget paints a subtle hero-header gradient + floating geometric
// shapes that match the category's colour palette. The content (child)
// is layered on top at full opacity — this is purely a backdrop.
// ═══════════════════════════════════════════════════════════════════════════

enum PageCategory {
  attendance,   // teal / green  — calendar / presence
  examination,  // indigo/violet — academic test
  homework,     // blue/ocean    — assignments & tasks
  syllabus,     // teal/emerald  — study plan
  fees,         // amber/gold    — financial
  bus,          // deep-blue/sky — transport
  result,       // green/success — achievements & grade
  profile,      // purple/rose   — personal identity
  holiday,      // orange/coral  — celebration
  notification, // sky-blue      — alerts
  liveClass,    // indigo/violet — online class / video meet
  smartClassRoom, // indigo/blue — Smart Class Room (live Google Meet sessions)
  teachersMaterials, // teal/blue — Teachers Materials (classes/announcements/documents)
  complain,     // royal blue    — Complain Box (app theme color)
  appointment,  // executive navy / cyan — Appointment with School Officials
  general,      // neutral gray  — fallback
}

class PageBackground extends StatelessWidget {
  final PageCategory category;
  final Widget child;
  final bool showHeader;   // true  → paint full header band
  // false → light full-page tint only
  final double headerHeight; // fraction of screen height, default 0.28

  const PageBackground({
    super.key,
    required this.category,
    required this.child,
    this.showHeader = true,
    this.headerHeight = 0.28,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = _schemeFor(category);
    final size   = MediaQuery.of(context).size;

    return Stack(
      children: [
        // ── Full-page very-light tint ────────────────────────────────────
        Positioned.fill(
          child: Container(color: scheme.pageBg),
        ),

        // ── Decorative header band ───────────────────────────────────────
        if (showHeader)
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * headerHeight,
            child: CustomPaint(
              painter: _HeaderPainter(scheme: scheme),
            ),
          ),

        // ── Content ──────────────────────────────────────────────────────
        child,
      ],
    );
  }

  static _ColorScheme _schemeFor(PageCategory cat) {
    switch (cat) {
      case PageCategory.attendance:
        return const _ColorScheme(
          gradientA: Color(0xFF00B4D8),
          gradientB: Color(0xFF0077B6),
          accent:    Color(0xFF4CAF50),
          blob1:     Color(0xFF90E0EF),
          blob2:     Color(0xFF00B4D8),
          pageBg:    Color(0xFFF0FAFA),
        );
      case PageCategory.examination:
        return const _ColorScheme(
          gradientA: Color(0xFF5C35FF),
          gradientB: Color(0xFF9B5DE5),
          accent:    Color(0xFFFFA726),
          blob1:     Color(0xFFBB9EFF),
          blob2:     Color(0xFF7B61FF),
          pageBg:    Color(0xFFF5F3FF),
        );
      case PageCategory.homework:
        return const _ColorScheme(
          gradientA: Color(0xFF3D5AFE),
          gradientB: Color(0xFF1A237E),
          accent:    Color(0xFF40C4FF),
          blob1:     Color(0xFF82B1FF),
          blob2:     Color(0xFF3D5AFE),
          pageBg:    Color(0xFFF0F4FF),
        );
      case PageCategory.syllabus:
        return const _ColorScheme(
          gradientA: Color(0xFF00BFA5),
          gradientB: Color(0xFF00695C),
          accent:    Color(0xFF69F0AE),
          blob1:     Color(0xFF80CBC4),
          blob2:     Color(0xFF00BFA5),
          pageBg:    Color(0xFFF0FDF9),
        );
      case PageCategory.fees:
        return const _ColorScheme(
          gradientA: Color(0xFF0B1E4D),
          gradientB: Color(0xFF1E3A8A),
          accent:    Color(0xFF38BDF8),
          blob1:     Color(0xFF2563EB),
          blob2:     Color(0xFF1E40AF),
          pageBg:    Color(0xFFF5F6FC),
        );
      case PageCategory.bus:
        return const _ColorScheme(
          gradientA: Color(0xFF0B1E4D),
          gradientB: Color(0xFF1E3A8A),
          accent:    Color(0xFF38BDF8),
          blob1:     Color(0xFF2563EB),
          blob2:     Color(0xFF1E40AF),
          pageBg:    Color(0xFFF8FAFC),
        );
      case PageCategory.result:
        return const _ColorScheme(
          gradientA: Color(0xFF2E7D32),
          gradientB: Color(0xFF1B5E20),
          accent:    Color(0xFF69F0AE),
          blob1:     Color(0xFF81C784),
          blob2:     Color(0xFF43A047),
          pageBg:    Color(0xFFF1FDF1),
        );
      case PageCategory.profile:
        return const _ColorScheme(
          gradientA: Color(0xFF7C3AED),
          gradientB: Color(0xFFDB2777),
          accent:    Color(0xFFF9A8D4),
          blob1:     Color(0xFFC4B5FD),
          blob2:     Color(0xFF8B5CF6),
          pageBg:    Color(0xFFFDF4FF),
        );
      case PageCategory.holiday:
        return const _ColorScheme(
          gradientA: Color(0xFFEA580C),
          gradientB: Color(0xFFB91C1C),
          accent:    Color(0xFFFBBF24),
          blob1:     Color(0xFFFCA5A5),
          blob2:     Color(0xFFF97316),
          pageBg:    Color(0xFFFFF7F0),
        );
      case PageCategory.notification:
        return const _ColorScheme(
          gradientA: Color(0xFF0284C7),
          gradientB: Color(0xFF075985),
          accent:    Color(0xFF38BDF8),
          blob1:     Color(0xFF7DD3FC),
          blob2:     Color(0xFF0EA5E9),
          pageBg:    Color(0xFFF0F9FF),
        );
      case PageCategory.liveClass:
        return const _ColorScheme(
          gradientA: Color(0xFF4F46E5),
          gradientB: Color(0xFF3730A3),
          accent:    Color(0xFF818CF8),
          blob1:     Color(0xFFA5B4FC),
          blob2:     Color(0xFF6366F1),
          pageBg:    Color(0xFFF5F5FF),
        );
      case PageCategory.smartClassRoom:
        return const _ColorScheme(
          gradientA: Color(0xFF4338CA),
          gradientB: Color(0xFF1E1B4B),
          accent:    Color(0xFF22D3EE),
          blob1:     Color(0xFFA5B4FC),
          blob2:     Color(0xFF4F46E5),
          pageBg:    Color(0xFFF4F5FF),
        );
      case PageCategory.teachersMaterials:
        return const _ColorScheme(
          gradientA: Color(0xFF0D9488),
          gradientB: Color(0xFF115E59),
          accent:    Color(0xFF5EEAD4),
          blob1:     Color(0xFF99F6E4),
          blob2:     Color(0xFF14B8A6),
          pageBg:    Color(0xFFF0FDFA),
        );
      case PageCategory.complain:
        return const _ColorScheme(
          gradientA: Color(0xFF0B1E4D),
          gradientB: Color(0xFF1E3A8A),
          accent:    Color(0xFF38BDF8),
          blob1:     Color(0xFF2563EB),
          blob2:     Color(0xFF1E40AF),
          pageBg:    Color(0xFFF5F6FC),
        );
      case PageCategory.appointment:
        return const _ColorScheme(
          gradientA: Color(0xFF0F172A),
          gradientB: Color(0xFF1E3A8A),
          accent:    Color(0xFF38BDF8),
          blob1:     Color(0xFF0284C7),
          blob2:     Color(0xFF2563EB),
          pageBg:    Color(0xFFF0F7FF),
        );
      case PageCategory.general:
        return const _ColorScheme(
          gradientA: Color(0xFF475569),
          gradientB: Color(0xFF1E293B),
          accent:    Color(0xFF94A3B8),
          blob1:     Color(0xFFCBD5E1),
          blob2:     Color(0xFF64748B),
          pageBg:    Color(0xFFF8FAFC),
        );
    }
  }
}

// ── Internal colour bundle ────────────────────────────────────────────────
class _ColorScheme {
  final Color gradientA;
  final Color gradientB;
  final Color accent;
  final Color blob1;
  final Color blob2;
  final Color pageBg;

  const _ColorScheme({
    required this.gradientA,
    required this.gradientB,
    required this.accent,
    required this.blob1,
    required this.blob2,
    required this.pageBg,
  });
}

// ── Painter ───────────────────────────────────────────────────────────────
class _HeaderPainter extends CustomPainter {
  final _ColorScheme scheme;
  const _HeaderPainter({required this.scheme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Gradient fill
    final gradPaint = Paint()
      ..shader = LinearGradient(
        colors: [scheme.gradientA, scheme.gradientB],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.80)
      ..quadraticBezierTo(w * 0.75, h * 1.05, w * 0.5, h * 0.90)
      ..quadraticBezierTo(w * 0.25, h * 0.75, 0, h * 0.95)
      ..close();

    canvas.drawPath(path, gradPaint);

    // 2. Large soft blob — top-right
    final blob1Paint = Paint()
      ..color = scheme.blob1.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(Offset(w * 0.85, h * 0.15), w * 0.38, blob1Paint);

    // 3. Medium blob — bottom-left
    final blob2Paint = Paint()
      ..color = scheme.blob2.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(w * 0.12, h * 0.78), w * 0.26, blob2Paint);

    // 4. Accent small circle — mid
    final accentPaint = Paint()
      ..color = scheme.accent.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(w * 0.5, h * 0.55), w * 0.14, accentPaint);

    // 5. Thin decorative arcs
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final r = w * (0.18 + i * 0.12);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(w * 0.88, -h * 0.05), radius: r),
        math.pi * 0.5,
        math.pi * 0.65,
        false,
        arcPaint,
      );
    }

    // 6. Dot grid — lower-right corner
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    const cols = 5;
    const rows = 3;
    const gap  = 18.0;
    const r    = 2.5;
    for (var col = 0; col < cols; col++) {
      for (var row = 0; row < rows; row++) {
        canvas.drawCircle(
          Offset(w - 20 - col * gap, h * 0.60 - row * gap),
          r,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HeaderPainter old) => old.scheme != scheme;
}

// ═══════════════════════════════════════════════════════════════════════════
// PageAppBar — transparent AppBar that sits on top of the header gradient
// ═══════════════════════════════════════════════════════════════════════════
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool dark; // true for light-text on dark gradient

  const PageAppBar({
    super.key,
    required this.title,
    this.actions,
    this.dark = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : Colors.black87;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: fg,
      iconTheme: IconThemeData(color: fg),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: fg,
        ),
      ),
      actions: actions,
    );
  }
}
