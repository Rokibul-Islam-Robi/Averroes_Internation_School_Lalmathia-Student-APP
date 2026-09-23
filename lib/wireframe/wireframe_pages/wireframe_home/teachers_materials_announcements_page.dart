import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';
import 'teachers_materials_controller.dart';
import 'student_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// TEACHERS MATERIALS → ANNOUNCEMENTS & NOTICES
//
// Connected to real GET /student/teacher-materials/announcements API (with pagination).
// Includes top summary metrics, dynamic filtering, attachments download & open.
// ════════════════════════════════════════════════════════════════════════════

class TeachersMaterialsAnnouncementsPage extends StatefulWidget {
  const TeachersMaterialsAnnouncementsPage({Key? key}) : super(key: key);

  @override
  State<TeachersMaterialsAnnouncementsPage> createState() => _TeachersMaterialsAnnouncementsPageState();
}

class _TeachersMaterialsAnnouncementsPageState extends State<TeachersMaterialsAnnouncementsPage> {
  final materialsCtrl = Get.put(TeachersMaterialsController());
  final ScrollController _scrollController = ScrollController();
  String? _selectedFilter; // null (All), 'files', 'subject', 'general'

  @override
  void initState() {
    super.initState();
    materialsCtrl.fetchAnnouncements();
    materialsCtrl.fetchDocuments();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        materialsCtrl.loadMoreAnnouncements();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: WireframeColor.appcolor,
      appBar: const PageAppBar(title: 'Notice'),
      body: PageBackground(
        category: PageCategory.teachersMaterials,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "Important academic circulars, notices & updates shared by teachers.",
                style: sansproSemibold.copyWith(fontSize: 13, color: Colors.white, height: 1.35),
              ),
            ),
            SizedBox(height: height / 65),

            // ── Top Single Card: Total Notices (Full Width Modern Corporate Card) ──
            Obx(() {
              final totalAnnounce = materialsCtrl.announcements.length;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedFilter == null ? const Color(0xff7C3AED) : const Color(0xffE2E8F0),
                      width: _selectedFilter == null ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff7C3AED).withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffEDE9FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffDDD6FE), width: 1),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          size: 24,
                          color: Color(0xff6D28D9),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$totalAnnounce",
                              style: sansproBold.copyWith(
                                fontSize: 22,
                                color: const Color(0xff0B1E4D),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Total Notices",
                              style: sansproSemibold.copyWith(
                                fontSize: 13,
                                color: const Color(0xff64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xffF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffE2E8F0), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff10B981),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Real-time",
                              style: sansproBold.copyWith(
                                fontSize: 11,
                                color: const Color(0xff475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: height / 65),

            // ── Category Filter (Modern Light Corporate Chip) ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _AnnounceFilterChip(
                  label: "All Notices",
                  selected: true,
                  onTap: () => setState(() => _selectedFilter = null),
                ),
              ),
            ),
            SizedBox(height: height / 65),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: WireframeColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Obx(() {
                  if (materialsCtrl.isAnnounceLoading.value && materialsCtrl.announcements.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (materialsCtrl.announceHasError.value && materialsCtrl.announcements.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.campaign_outlined, size: 48, color: WireframeColor.appgray),
                            const SizedBox(height: 12),
                            Text(
                              materialsCtrl.announceErrorMessage.value,
                              textAlign: TextAlign.center,
                              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.textgray),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WireframeColor.appcolor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => materialsCtrl.fetchAnnouncements(),
                              child: Text("Retry".tr, style: sansproSemibold.copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allAnnounce = materialsCtrl.announcements;
                  final filtered = allAnnounce.where((a) {
                    if (_selectedFilter == 'files') return a.hasAttachment;
                    if (_selectedFilter == 'subject') return a.subjectName.isNotEmpty && a.subjectName != 'No Subject';
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No notices found for current filter.".tr,
                        style: sansproRegular.copyWith(fontSize: 13, color: WireframeColor.textgray),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: materialsCtrl.fetchAnnouncements,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 40),
                      itemCount: filtered.length + (materialsCtrl.isAnnounceLoadingMore.value ? 1 : 0),
                      separatorBuilder: (_, __) => SizedBox(height: height / 60),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final item = filtered[index];
                        return _AnnouncementCard(item: item, width: width, height: height);
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnounceFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AnnounceFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const purpleLightBg = Color(0xffF3E8FF); // Soft elegant light lavender background
    const purpleBorder = Color(0xffDDD6FE); // Soft corporate border
    const purpleText = Color(0xff6D28D9); // High-contrast purple corporate text
    const purpleDot = Color(0xff7C3AED); // Live indicator dot

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: purpleLightBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: purpleBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7C3AED).withAlpha(18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: purpleDot,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: sansproBold.copyWith(
                fontSize: 12.5,
                color: purpleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final MaterialAnnouncementItem item;
  final double width;
  final double height;
  const _AnnouncementCard({required this.item, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final materialsCtrl = Get.find<TeachersMaterialsController>();

    return Container(
      padding: EdgeInsets.all(width / 24),
      decoration: BoxDecoration(
        color: WireframeColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isImportant ? const Color(0xffFCD34D) : const Color(0xffE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Text(
            item.title,
            style: sansproBold.copyWith(fontSize: 15, color: WireframeColor.black, height: 1.3),
          ),
          SizedBox(height: height / 110),

          // ── Badges: Announcement, Subject, File ──
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _badge("Notice", const Color(0xffFEF3C7), const Color(0xffB45309)),
              if (item.subjectName.isNotEmpty && item.subjectName != "No Subject")
                _badge(item.subjectName, const Color(0xffF1F5F9), const Color(0xff475569)),
              if (item.fileType != null && item.fileType!.isNotEmpty)
                _badge(item.fileType!, const Color(0xffDCFCE7), const Color(0xff15803D)),
            ],
          ),
          SizedBox(height: height / 100),

          // ── Metadata: Class / Section / Teacher ──
          Row(
            children: [
              const Icon(Icons.apartment_rounded, size: 14, color: Color(0xff64748B)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  "${item.className.isNotEmpty ? item.className : 'Pre KG'} / ${normalizeSectionWithSession(item.sectionName.isNotEmpty ? item.sectionName : 'All Sections')}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                ),
              ),
            ],
          ),
          if (item.teacherName.isNotEmpty && item.teacherName != 'No Teacher') ...[
            SizedBox(height: height / 250),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xff64748B)),
                const SizedBox(width: 5),
                Text(
                  "Teacher: ${item.teacherName}",
                  style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                ),
              ],
            ),
          ],
          SizedBox(height: height / 250),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 13, color: Color(0xff94A3B8)),
              const SizedBox(width: 5),
              Text(
                "Published: ${item.publishedAt ?? 'Recent'}",
                style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff94A3B8)),
              ),
            ],
          ),

          if (item.message.isNotEmpty && item.message != item.title) ...[
            SizedBox(height: height / 120),
            Text(
              item.message,
              style: sansproRegular.copyWith(fontSize: 12.5, color: const Color(0xff475569)),
            ),
          ],

          if (item.hasAttachment) ...[
            SizedBox(height: height / 70),
            // ── Download Action Button ──
            InkWell(
              onTap: () => materialsCtrl.downloadAndOpenDocument(
                title: item.title,
                fileUrl: item.fileUrl,
                fileName: '${item.title}.pdf',
                category: 'Announcement',
                description: item.message.isNotEmpty ? item.message : item.title,
                publishedAt: item.publishedAt,
                className: item.className,
                sectionName: item.sectionName,
                teacherName: item.teacherName,
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xff16A34A),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff16A34A).withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      "Download Attachment (${item.fileSize ?? 'Document'})",
                      style: sansproSemibold.copyWith(fontSize: 13.5, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Text(
        text,
        style: sansproSemibold.copyWith(fontSize: 10.5, color: textColor),
      ),
    );
  }
}
