import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';
import 'teachers_materials_controller.dart';
import 'student_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// TEACHERS MATERIALS → CLASS MATERIALS
//
// Matched 1:1 to School ERP Portal Class Materials Specification (Image 3)
// Connected to real GET /student/teacher-materials/documents API.
// Top 3 Cards: 1. Class Materials | 2. Class Routines | 3. Official Documents
// ════════════════════════════════════════════════════════════════════════════

class TeachersMaterialsClassesPage extends StatefulWidget {
  const TeachersMaterialsClassesPage({Key? key}) : super(key: key);

  @override
  State<TeachersMaterialsClassesPage> createState() => _TeachersMaterialsClassesPageState();
}

class _TeachersMaterialsClassesPageState extends State<TeachersMaterialsClassesPage> {
  final materialsCtrl = Get.put(TeachersMaterialsController());
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory; // Default to null (All Documents)

  @override
  void initState() {
    super.initState();
    materialsCtrl.fetchDocuments();
    materialsCtrl.fetchAnnouncements();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        materialsCtrl.loadMoreDocuments();
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
      appBar: const PageAppBar(title: 'Assignment'),
      body: PageBackground(
        category: PageCategory.teachersMaterials,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "Official class study assignments, materials & academic documents.",
                style: sansproSemibold.copyWith(fontSize: 13, color: Colors.white, height: 1.35),
              ),
            ),
            SizedBox(height: height / 65),

            // ── Top 4 Stats Cards (1. Class Materials, 2. Class Routines, 3. Official Documents, 4. Announcements) ──
            Obx(() {
              final materialCount = materialsCtrl.documents.where((d) => d.category.toLowerCase().contains('material')).length;
              final routineCount = materialsCtrl.documents.where((d) => d.category.toLowerCase().contains('routine')).length;
              final officialCount = materialsCtrl.documents.where((d) => d.category.toLowerCase().contains('official')).length;
              final announceCount = materialsCtrl.announcements.length;

              return SizedBox(
                height: 74,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: width / 20),
                  children: [
                    // 1. Class Materials Card
                    _buildStatCard(
                      title: 'Assignment',
                      count: materialCount.toString(),
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xff0D9488),
                      isSelected: _selectedCategory == 'material',
                      onTap: () => setState(() => _selectedCategory = _selectedCategory == 'material' ? null : 'material'),
                    ),
                    const SizedBox(width: 10),

                    // 2. Class Routines Card
                    _buildStatCard(
                      title: 'Class Routines',
                      count: routineCount.toString(),
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xff0284C7),
                      isSelected: _selectedCategory == 'routine',
                      onTap: () => setState(() => _selectedCategory = _selectedCategory == 'routine' ? null : 'routine'),
                    ),
                    const SizedBox(width: 10),

                    // 3. Official Documents Card
                    _buildStatCard(
                      title: 'Official Documents',
                      count: officialCount.toString(),
                      icon: Icons.description_rounded,
                      color: const Color(0xffD97706),
                      isSelected: _selectedCategory == 'official',
                      onTap: () => setState(() => _selectedCategory = _selectedCategory == 'official' ? null : 'official'),
                    ),
                    const SizedBox(width: 10),

                    // 4. Notices Card (Added per user request)
                    _buildStatCard(
                      title: 'Notices',
                      count: announceCount.toString(),
                      icon: Icons.campaign_rounded,
                      color: const Color(0xff7C3AED),
                      isSelected: _selectedCategory == 'announcement',
                      onTap: () => setState(() => _selectedCategory = _selectedCategory == 'announcement' ? null : 'announcement'),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: height / 65),

            // ── Document List Container (Real Data from API without filter row) ──
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
                child: Obx(() {
                  if (materialsCtrl.isDocsLoading.value && materialsCtrl.documents.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: WireframeColor.appcolor));
                  }

                  if (materialsCtrl.docsHasError.value && materialsCtrl.documents.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 48, color: WireframeColor.appgray),
                            const SizedBox(height: 12),
                            Text(
                              materialsCtrl.docsErrorMessage.value,
                              textAlign: TextAlign.center,
                              style: sansproRegular.copyWith(fontSize: 14, color: WireframeColor.textgray),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WireframeColor.appcolor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => materialsCtrl.fetchDocuments(),
                              child: Text("Retry".tr, style: sansproSemibold.copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // If Notices category is selected from top card
                  if (_selectedCategory == 'announcement') {
                    final announcements = materialsCtrl.announcements;
                    if (announcements.isEmpty) {
                      return _buildEmptyState(
                        height: height,
                        width: width,
                        title: "No notices found.",
                        subtitle: "No notices currently available for this section.",
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        await materialsCtrl.fetchDocuments();
                        await materialsCtrl.fetchAnnouncements();
                      },
                      color: WireframeColor.appcolor,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 40),
                        itemCount: announcements.length,
                        separatorBuilder: (_, __) => SizedBox(height: height / 60),
                        itemBuilder: (context, index) {
                          final item = announcements[index];
                          return _AnnouncementTile(
                            item: item,
                            width: width,
                            height: height,
                            onTap: () {
                              if (item.hasAttachment) {
                                materialsCtrl.downloadAndOpenDocument(
                                  title: item.title,
                                  fileUrl: item.openableUrl,
                                  fileName: '${item.title.replaceAll(' ', '_')}.pdf',
                                  category: 'Announcement',
                                  description: item.message,
                                  publishedAt: item.publishedAt,
                                  className: item.className,
                                  sectionName: item.sectionName,
                                  teacherName: item.teacherName,
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  }

                  // Filter documents by selected category (or show all if null)
                  final allDocs = materialsCtrl.documents;
                  final filteredDocs = allDocs.where((d) {
                    if (_selectedCategory == null) return true;
                    return d.category.toLowerCase().contains(_selectedCategory!.toLowerCase());
                  }).toList();

                  // If empty, show clean corporate empty state
                  if (filteredDocs.isEmpty) {
                    return _buildEmptyState(
                      height: height,
                      width: width,
                      title: "No document found.",
                      subtitle: "No files currently available for this category.",
                    );
                  }

                  // Render Real Documents List
                  return RefreshIndicator(
                    onRefresh: () async {
                      await materialsCtrl.fetchDocuments();
                      await materialsCtrl.fetchAnnouncements();
                    },
                    color: WireframeColor.appcolor,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 40),
                      itemCount: filteredDocs.length + (materialsCtrl.isDocsLoadingMore.value ? 1 : 0),
                      separatorBuilder: (_, __) => SizedBox(height: height / 60),
                      itemBuilder: (context, index) {
                        if (index == filteredDocs.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: WireframeColor.appcolor),
                            ),
                          );
                        }

                        final doc = filteredDocs[index];
                        return _DocumentTile(
                          doc: doc,
                          width: width,
                          height: height,
                          onTap: () {
                            materialsCtrl.downloadAndOpenDocument(
                              title: doc.title,
                              fileUrl: doc.openableUrl,
                              fileName: '${doc.title}.pdf',
                              category: doc.category,
                              description: doc.description.isNotEmpty ? doc.description : doc.title,
                              publishedAt: doc.publishedAt,
                              className: doc.className,
                              sectionName: doc.sectionName,
                              teacherName: doc.teacherName,
                            );
                          },
                        );
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

  Widget _buildEmptyState({
    required double height,
    required double width,
    required String title,
    required String subtitle,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        await materialsCtrl.fetchDocuments();
        await materialsCtrl.fetchAnnouncements();
      },
      color: WireframeColor.appcolor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          SizedBox(height: height / 14),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: width / 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xffE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff64748B).withAlpha(15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xffE0F2FE),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xffBAE6FD),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      size: 38,
                      color: Color(0xff0284C7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: sansproBold.copyWith(
                      fontSize: 16,
                      color: const Color(0xff1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: sansproRegular.copyWith(
                      fontSize: 13,
                      color: const Color(0xff64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STAT CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xffE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withAlpha(45) : Colors.black.withAlpha(12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: sansproBold.copyWith(fontSize: 16, color: const Color(0xff0B1E4D)),
                ),
                Text(
                  title,
                  style: sansproSemibold.copyWith(fontSize: 11, color: const Color(0xff64748B)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ANNOUNCEMENT TILE CARD (FOR CLASS MATERIALS PAGE)
// ════════════════════════════════════════════════════════════════════════════
class _AnnouncementTile extends StatelessWidget {
  final MaterialAnnouncementItem item;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _AnnouncementTile({
    required this.item,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width / 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
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
          Text(
            item.title,
            style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff0B1E4D)),
          ),
          SizedBox(height: height / 120),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _tagBadge("Announcement", const Color(0xff7C3AED)),
              if (item.hasAttachment)
                _tagBadge(item.fileType ?? "PDF", const Color(0xff16A34A)),
            ],
          ),
          SizedBox(height: height / 100),
          Text(
            "${item.className.isNotEmpty ? item.className : 'Pre KG'} / ${normalizeSectionWithSession(item.sectionName.isNotEmpty ? item.sectionName : 'All Sections')}",
            style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
          ),
          SizedBox(height: height / 250),
          Text(
            "Published: ${item.publishedAt ?? 'Recent'}",
            style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff94A3B8)),
          ),
          if (item.message.isNotEmpty) ...[
            SizedBox(height: height / 100),
            Text(
              item.message,
              style: sansproRegular.copyWith(fontSize: 13, color: const Color(0xff334155), height: 1.35),
            ),
          ],
          if (item.hasAttachment) ...[
            SizedBox(height: height / 70),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
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
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      "Download Attachment (${item.fileSize ?? 'File'})",
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

  Widget _tagBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: sansproSemibold.copyWith(fontSize: 11, color: color),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DOCUMENT TILE CARD
// ════════════════════════════════════════════════════════════════════════════
class _DocumentTile extends StatelessWidget {
  final MaterialDocumentItem doc;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _DocumentTile({
    required this.doc,
    required this.width,
    required this.height,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (doc.category.toLowerCase()) {
      case "routine":
        return const Color(0xff0284C7);
      case "official":
        return const Color(0xff4F46E5);
      case "announcement":
        return const Color(0xff5C35FF);
      case "material":
      default:
        return const Color(0xff0D9488);
    }
  }

  String get _categoryLabel {
    switch (doc.category.toLowerCase()) {
      case "routine":
        return "Class Routine";
      case "official":
        return "Official Document";
      case "announcement":
        return "Announcement";
      case "material":
      default:
        return "Class Material";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width / 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE2E8F0)),
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
          // Title
          Text(
            doc.title,
            style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff0B1E4D)),
          ),
          SizedBox(height: height / 120),

          // Badges row: Category, Subject, File
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _tagBadge(_categoryLabel, _categoryColor),
              if (doc.subjectName.isNotEmpty && doc.subjectName != 'No Subject')
                _tagBadge(doc.subjectName, const Color(0xff64748B)),
              _tagBadge(doc.fileType ?? 'File', const Color(0xff16A34A)),
            ],
          ),
          SizedBox(height: height / 100),

          // Metadata row
          Text(
            "${doc.className.isNotEmpty ? doc.className : 'Pre KG'} / ${normalizeSectionWithSession(doc.sectionName.isNotEmpty ? doc.sectionName : 'All Sections')}  \u2022  Teacher: ${doc.teacherName.isNotEmpty ? doc.teacherName : 'Academic Faculty'}",
            style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
          ),
          SizedBox(height: height / 250),
          Text(
            "Published: ${doc.publishedAt ?? 'Recent'}",
            style: sansproRegular.copyWith(fontSize: 11.5, color: const Color(0xff94A3B8)),
          ),
          SizedBox(height: height / 70),

          // Download Action Button (Corporate green button)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
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
                    "Download (${doc.fileSize ?? '250 KB'})",
                    style: sansproSemibold.copyWith(fontSize: 13.5, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: sansproSemibold.copyWith(fontSize: 11, color: color),
      ),
    );
  }
}
