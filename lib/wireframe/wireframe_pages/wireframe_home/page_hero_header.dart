import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// PAGE HERO HEADER — Shared themed header used across all module pages
//
// তোমার screenshot-এ Result page-এ যে curved wave background দেখেছো, এটা
// সেই একই look সব module page-এ consistently দেওয়ার জন্য একটাই shared widget।
//
// Usage:
// PageHeroHeader(
//   theme: PageHeroTheme.attendance,
//   title: 'Attendance',
//   subtitle: 'Track your presence',
//   onBack: () => Navigator.pop(context),
//   actions: [IconButton(...)],   // optional
//   child: YourSummaryCard(),     // optional floating card at bottom of hero
// )
// ════════════════════════════════════════════════════════════════════════════

// ── Theme tokens — প্রতিটা module-এর নিজস্ব রঙ ও আইকন ─────────────────────
enum PageHeroTheme {
  homework,
  syllabus,
  fees,
  attendance,
  examination,
  bus,
  notifications,
  profile,
  reportCard,
  result,
}

class PageHeroThemeData {
  final List<Color> gradientColors;
  final IconData icon;
  final String? decorIcon2; // ২য় ছোট সাজসজ্জার আইকন (optional)

  const PageHeroThemeData({
    required this.gradientColors,
    required this.icon,
    this.decorIcon2,
  });
}

const Map<PageHeroTheme, PageHeroThemeData> _kThemes = {
  PageHeroTheme.homework: PageHeroThemeData(
    gradientColors: [Color(0xFF3D5AFE), Color(0xFF536DFE)],
    icon: Icons.menu_book_outlined,
  ),
  PageHeroTheme.syllabus: PageHeroThemeData(
    gradientColors: [Color(0xFF00897B), Color(0xFF00BFA5)],
    icon: Icons.list_alt_outlined,
  ),
  PageHeroTheme.fees: PageHeroThemeData(
    gradientColors: [Color(0xFFE2136E), Color(0xFFF06292)],
    icon: Icons.account_balance_wallet_outlined,
  ),
  PageHeroTheme.attendance: PageHeroThemeData(
    gradientColors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    icon: Icons.calendar_month_outlined,
  ),
  PageHeroTheme.examination: PageHeroThemeData(
    gradientColors: [Color(0xFF5C35FF), Color(0xFF9575CD)],
    icon: Icons.school_outlined,
  ),
  PageHeroTheme.bus: PageHeroThemeData(
    gradientColors: [Color(0xFF0097A7), Color(0xFF26C6DA)],
    icon: Icons.directions_bus_filled,
  ),
  PageHeroTheme.notifications: PageHeroThemeData(
    gradientColors: [Color(0xFFF57C00), Color(0xFFFFB300)],
    icon: Icons.notifications_outlined,
  ),
  PageHeroTheme.profile: PageHeroThemeData(
    gradientColors: [Color(0xFF345FB4), Color(0xFF6789CA)],
    icon: Icons.person_outline,
  ),
  PageHeroTheme.reportCard: PageHeroThemeData(
    gradientColors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    icon: Icons.bar_chart_outlined,
  ),
  PageHeroTheme.result: PageHeroThemeData(
    gradientColors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    icon: Icons.emoji_events_outlined,
  ),
};

// ── Wave Clipper ─────────────────────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5, size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 40,
      size.width, size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Main Hero Header Widget ───────────────────────────────────────────────────
class PageHeroHeader extends StatelessWidget {
  final PageHeroTheme theme;
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions; // top-right buttons (optional)
  final Widget? child; // floating card or summary widget below the wave

  const PageHeroHeader({
    Key? key,
    required this.theme,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final td = _kThemes[theme]!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Gradient background with wave clip ──────────────────────────────
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: child != null ? 210 + topPadding : 160 + topPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: td.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // ── Decorative large icon (top-right, low opacity) ───────────
                Positioned(
                  top: topPadding + 8,
                  right: -16,
                  child: Icon(
                    td.icon,
                    size: 110,
                    color: Colors.white.withAlpha(25),
                  ),
                ),
                // ── Decorative small circle top-left ─────────────────────────
                Positioned(
                  top: topPadding - 30,
                  left: -30,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(15),
                    ),
                  ),
                ),
                // ── Back button + Title row ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 12,
                    left: 8,
                    right: 8,
                  ),
                  child: Row(
                    children: [
                      if (onBack != null)
                        IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 20),
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Floating child card (positioned at wave overlap area) ────────────
        if (child != null)
          Positioned(
            bottom: -40,
            left: 16,
            right: 16,
            child: child!,
          ),
      ],
    );
  }
}

// ── Helper: wrap any Scaffold body with this so the hero + scrollable content
// sit together correctly with the floating card offset accounted for.
// Use like:
//   HeroScaffold(
//     hero: PageHeroHeader(..., child: SummaryCard()),
//     body: ListView(...),
//   )
class HeroScaffold extends StatelessWidget {
  final PageHeroHeader hero;
  final Widget body;
  final Color backgroundColor;
  final Widget? floatingActionButton;

  const HeroScaffold({
    Key? key,
    required this.hero,
    required this.body,
    this.backgroundColor = const Color(0xFFF6F7FB),
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasChild = hero.child != null;
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          // Hero with wave takes its natural height
          SizedBox(
            height: hasChild
                ? 210 + MediaQuery.of(context).padding.top + 40
                : 160 + MediaQuery.of(context).padding.top,
            child: hero,
          ),
          // Extra space below wave for floating card overlap
          if (hasChild) const SizedBox(height: 40),
          // Scrollable body
          Expanded(child: body),
        ],
      ),
    );
  }
}

// ── Convenience: a standard summary chip shown in the floating child card ─────
class HeroSummaryChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const HeroSummaryChip({
    Key? key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF888888))),
      ],
    );
  }
}
