import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// EVENT DETAILS PAGE — Modern Corporate Standard
// Displays complete event photo, schedule, description and highlights for
// Averroes International School Lalmatia.
// ════════════════════════════════════════════════════════════════════════════

class WireframeEventDetails extends StatelessWidget {
  final String? title;
  final String? date;
  final String? time;
  final String? location;
  final String? image;
  final String? category;
  final String? description;
  final List<String>? highlights;

  const WireframeEventDetails({
    super.key,
    this.title,
    this.date,
    this.time,
    this.location,
    this.image,
    this.category,
    this.description,
    this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Fallback defaults if opened directly
    final eventTitle = title ?? "Victory Day Activities";
    final eventDate = date ?? "16 Dec 2026";
    final eventTime = time ?? "09:00 AM - 01:30 PM";
    final eventLocation = location ?? "Averroes Main Campus, Lalmatia, Dhaka";
    final eventImage = image ?? WireframePngimage.eventVictoryDay;
    final eventCategory = category ?? "National Celebration";
    final eventDescription = description ??
        "Averroes International School Lalmatia cordially invites all students, parents, and faculty members to commemorate our glorious Victory Day with deep national pride and solemn reverence.\n\n"
        "The day begins with the ceremonial hoisting of the National Flag followed by Quran recitation and a special du'a for our heroic martyrs. Students from all branches will participate in patriotic cultural performances, national anthem recitations, and an inter-class art & poster exhibition celebrating our history. Special awards and certificates will be presented to student achievers.";

    final eventHighlights = highlights ?? [
      "09:00 AM: National Flag Hoisting & Special Du'a for Martyrs",
      "09:30 AM: Welcome Address by Honorable Principal & Faculty",
      "10:15 AM: Inter-Class Patriotic Art & Poster Exhibition",
      "11:15 AM: Cultural Program (Patriotic Songs & Poetry)",
      "12:30 PM: Prize Distribution & Certificate Awarding Ceremony",
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(
        title: 'Event Details',
      ),
      body: PageBackground(
        category: PageCategory.holiday,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.symmetric(
                    horizontal: width / 24,
                    vertical: height / 45,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Prominent Event Cover Picture (First at Top) ──
                      Container(
                        width: double.infinity,
                        height: height / 3.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xffE2E8F0), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(16),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                eventImage,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xff0B1E4D),
                                  child: const Center(
                                    child: Icon(Icons.event_note_rounded, color: Colors.white70, size: 48),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(160),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.stars_rounded, color: Color(0xffFBBF24), size: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        eventCategory,
                                        style: sansproBold.copyWith(fontSize: 11, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: height / 45),

                      // ── 2. Event Title ──
                      Text(
                        eventTitle,
                        style: sansproBold.copyWith(
                          fontSize: 20,
                          color: const Color(0xff0F172A),
                          height: 1.25,
                        ),
                      ),

                      SizedBox(height: height / 60),

                      // ── 3. Schedule & Meta Info Cards ──
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.calendar_month_rounded,
                              iconBg: const Color(0xffEFF6FF),
                              iconColor: const Color(0xff2563EB),
                              title: "Date & Time",
                              subtitle: "$eventDate • $eventTime",
                            ),
                            const Divider(height: 18, color: Color(0xffF1F5F9)),
                            _buildInfoRow(
                              icon: Icons.location_on_rounded,
                              iconBg: const Color(0xffFEF2F2),
                              iconColor: const Color(0xffDC2626),
                              title: "Location / Venue",
                              subtitle: eventLocation,
                            ),
                            const Divider(height: 18, color: Color(0xffF1F5F9)),
                            _buildInfoRow(
                              icon: Icons.school_rounded,
                              iconBg: const Color(0xffECFDF5),
                              iconColor: const Color(0xff059669),
                              title: "Institution & Campus",
                              subtitle: "Averroes International School Lalmatia",
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height / 40),

                      // ── 4. About the Event (Rich Corporate Content) ──
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: WireframeColor.appcolor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "About This Event",
                            style: sansproBold.copyWith(
                              fontSize: 16,
                              color: const Color(0xff0F172A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height / 80),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: Text(
                          eventDescription,
                          style: sansproRegular.copyWith(
                            fontSize: 13.5,
                            color: const Color(0xff334155),
                            height: 1.55,
                          ),
                        ),
                      ),

                      SizedBox(height: height / 40),

                      // ── 5. Program Highlights & Agenda ──
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xff059669),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Program Highlights & Schedule",
                            style: sansproBold.copyWith(
                              fontSize: 16,
                              color: const Color(0xff0F172A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height / 80),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffE2E8F0)),
                        ),
                        child: Column(
                          children: List.generate(eventHighlights.length, (idx) {
                            final item = eventHighlights[idx];
                            return Padding(
                              padding: EdgeInsets.only(bottom: idx == eventHighlights.length - 1 ? 0 : 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff059669).withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Color(0xff059669),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: sansproSemibold.copyWith(
                                        fontSize: 13,
                                        color: const Color(0xff1E293B),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: height / 35),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: sansproRegular.copyWith(
                  fontSize: 11.5,
                  color: WireframeColor.textgray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: sansproBold.copyWith(
                  fontSize: 13,
                  color: const Color(0xff0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}