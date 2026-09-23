import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_icons.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/wireframe_eventdetails.dart';
import 'package:averroes_student_app/wireframe/wireframe_theme/wireframe_themecontroller.dart';
import '../../wireframe_gloabelclass/wireframe_color.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// EVENTS & PROGRAMS — Modern Corporate Standard
// Averroes International School Lalmatia
// ════════════════════════════════════════════════════════════════════════════

class WireframeEvents extends StatelessWidget {
  const WireframeEvents({super.key});

  static final List<Map<String, dynamic>> _eventsList = [
    {
      'title': 'Victory Day Activities',
      'date': '16 Dec 2026',
      'time': '09:00 AM - 01:30 PM',
      'location': 'Averroes Main Campus, Lalmatia, Dhaka',
      'category': 'National Celebration',
      'badgeColor': const Color(0xff059669),
      'image': WireframePngimage.eventVictoryDay,
      'description':
          'Averroes International School Lalmatia cordially invites all students, parents, and faculty members to commemorate our glorious Victory Day with deep national pride and solemn reverence.\n\n'
          'The day begins with the ceremonial hoisting of the National Flag followed by Quran recitation and a special du\'a for our heroic martyrs. Students from all branches will participate in patriotic cultural performances, national anthem recitations, and an inter-class art & poster exhibition celebrating our history. Special awards and certificates will be presented to student achievers.',
      'highlights': [
        '09:00 AM: National Flag Hoisting & Special Du\'a for Martyrs',
        '09:30 AM: Welcome Address by Honorable Principal & Faculty',
        '10:15 AM: Inter-Class Patriotic Art & Poster Exhibition',
        '11:15 AM: Cultural Program (Patriotic Songs & Poetry)',
        '12:30 PM: Prize Distribution & Certificate Awarding Ceremony',
      ],
    },
    {
      'title': 'STEM Week 2025',
      'date': '12 Jan 2027',
      'time': '09:00 AM - 02:00 PM',
      'location': 'Lalmatia Campus STEM Labs & Auditorium',
      'category': 'Science & Technology',
      'badgeColor': const Color(0xffEA580C),
      'image': WireframePngimage.eventStemWeek,
      'description':
          'STEM Week at Averroes International School Lalmatia is a premier academic festival designed to inspire curiosity, creativity, and scientific inquiry among young learners.\n\n'
          'Throughout this week-long event, students engage in hands-on science experiments, robotics demonstrations, coding workshops, mathematical puzzle challenges, and sustainable environmental innovation models. Eminent guest educators and technology experts will conduct interactive keynote sessions, and students will present their team research projects to a panel of expert judges.',
      'highlights': [
        'Day 1: Interactive Chemistry & Physics Experiment Showcase',
        'Day 2: Junior Robotics & Coding Challenge (Scratch & Arduino)',
        'Day 3: Speed Math Olympiad & Logic Puzzle Championship',
        'Day 4: Eco-Innovations & Sustainable Technology Expo',
        'Day 5: Grand Project Judging & Young Scientist Award Ceremony',
      ],
    },
    {
      'title': 'Annual Educational Field Trip',
      'date': '02 Feb 2027',
      'time': '08:30 AM - 04:30 PM',
      'location': 'National Museum of Science & Technology, Dhaka',
      'category': 'Outdoor Study Tour',
      'badgeColor': const Color(0xff0284C7),
      'image': WireframePngimage.eventFieldTrip,
      'description':
          'The Annual Educational Field Trip of Averroes International School Lalmatia offers students an enriching experiential learning journey outside the traditional classroom.\n\n'
          'Guided by our experienced faculty members and safety supervisors, students will explore interactive science galleries, celestial observatory exhibits, and biodiversity parks. The trip includes guided museum tours, group scientific observation tasks, fun learning quizzes, and fully catered halal lunch and refreshments provided under comprehensive school supervision.',
      'highlights': [
        '08:30 AM: Student Assembly & Departure in AC School Buses',
        '09:45 AM: Guided Tour of Science & Space Innovation Galleries',
        '12:00 PM: 3D Planetarium & Space Exploration Show',
        '01:15 PM: Congregational Dhuhr Prayer & Catered Lunch',
        '02:30 PM: Team Quiz & Science Discovery Workshop',
        '04:00 PM: Safe Return & Disembarkation at Lalmatia Campus',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final themedata = Get.put(WireframeThemecontroler());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: PageAppBar(
        title: "Events_Programs".tr,
      ),
      body: PageBackground(
        category: PageCategory.holiday,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: themedata.isdark ? WireframeColor.black : const Color(0xffF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: width / 24,
                    vertical: height / 45,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: _eventsList.length,
                  separatorBuilder: (_, __) => SizedBox(height: height / 50),
                  itemBuilder: (context, index) {
                    final item = _eventsList[index];
                    final badgeColor = item['badgeColor'] as Color;

                    return Container(
                      decoration: BoxDecoration(
                        color: themedata.isdark ? WireframeColor.lightblack : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: themedata.isdark ? Colors.white12 : const Color(0xffE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WireframeEventDetails(
                                  title: item['title'] as String,
                                  date: item['date'] as String,
                                  time: item['time'] as String,
                                  location: item['location'] as String,
                                  category: item['category'] as String,
                                  image: item['image'] as String,
                                  description: item['description'] as String,
                                  highlights: item['highlights'] as List<String>,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── 1. Event Picture First (At Top of Card) ──
                              Container(
                                height: height / 4.8,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        item['image'] as String,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xff0B1E4D),
                                          child: const Icon(Icons.event, color: Colors.white, size: 40),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: badgeColor.withAlpha(220),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.white30),
                                          ),
                                          child: Text(
                                            item['category'] as String,
                                            style: sansproBold.copyWith(
                                              fontSize: 11,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ── 2. Card Content & Metadata ──
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: sansproBold.copyWith(
                                        fontSize: 16,
                                        color: themedata.isdark ? WireframeColor.white : const Color(0xff0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Date & Time Row
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 14, color: WireframeColor.appcolor),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${item['date']} • ${item['time']}",
                                          style: sansproSemibold.copyWith(
                                            fontSize: 12,
                                            color: WireframeColor.appcolor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Location Row
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 14, color: Color(0xffDC2626)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item['location'] as String,
                                            overflow: TextOverflow.ellipsis,
                                            style: sansproRegular.copyWith(
                                              fontSize: 12,
                                              color: WireframeColor.textgray,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Excerpt
                                    Text(
                                      item['description'] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: sansproRegular.copyWith(
                                        fontSize: 12.5,
                                        color: themedata.isdark ? Colors.white70 : const Color(0xff475569),
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // View Details Action Link
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "View Details",
                                          style: sansproBold.copyWith(
                                            fontSize: 12.5,
                                            color: WireframeColor.appcolor,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_rounded, size: 14, color: WireframeColor.appcolor),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}