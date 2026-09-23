import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/page_background.dart';
import 'teachers_materials_controller.dart';
import 'student_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// TEACHERS MATERIALS → OFFICIAL DOCUMENTS
//
// Connected to real GET /student/teacher-materials/documents API (with pagination).
// ════════════════════════════════════════════════════════════════════════════

class TeachersMaterialsDocumentsPage extends StatefulWidget {
  const TeachersMaterialsDocumentsPage({Key? key}) : super(key: key);

  @override
  State<TeachersMaterialsDocumentsPage> createState() => _TeachersMaterialsDocumentsPageState();
}

class _TeachersMaterialsDocumentsPageState extends State<TeachersMaterialsDocumentsPage> {
  final materialsCtrl = Get.put(TeachersMaterialsController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    materialsCtrl.fetchDocuments();

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
      appBar: const PageAppBar(title: 'Official Documents'),
      body: PageBackground(
        category: PageCategory.teachersMaterials,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Text(
                "Official school circulars, academic documents & records shared by authority.",
                style: sansproSemibold.copyWith(fontSize: 13, color: Colors.white, height: 1.35),
              ),
            ),
            SizedBox(height: height / 65),

            // ── Top Single Card: Total Official Documents (Modern Full-Width Corporate Card) ──
            Obx(() {
              final officialDocs = materialsCtrl.documents.where((d) {
                final cat = d.category.toLowerCase();
                return !cat.contains('announce');
              }).toList();

              final totalOfficial = officialDocs.length;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width / 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xff4F46E5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff4F46E5).withAlpha(20),
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
                          color: const Color(0xffEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffC7D2FE), width: 1),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          size: 24,
                          color: Color(0xff4338CA),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$totalOfficial",
                              style: sansproBold.copyWith(
                                fontSize: 22,
                                color: const Color(0xff0B1E4D),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Total Official Documents",
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

            // ── Category Filter (Single Light Corporate Chip) ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _OfficialDocFilterChip(
                  label: "All Official Documents",
                  selected: true,
                  onTap: () {},
                ),
              ),
            ),
            SizedBox(height: height / 65),

            // ── Official Documents List Container ──
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
                    return const Center(
                      child: CircularProgressIndicator(color: WireframeColor.appcolor),
                    );
                  }

                  if (materialsCtrl.docsHasError.value && materialsCtrl.documents.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder_off_outlined, size: 48, color: WireframeColor.appgray),
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

                  // Strictly filter for official documents (Exclude announcements)
                  final officialDocs = materialsCtrl.documents.where((d) {
                    final cat = d.category.toLowerCase();
                    return !cat.contains('announce');
                  }).toList();

                  if (officialDocs.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: materialsCtrl.fetchDocuments,
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
                                      color: const Color(0xffEEF2FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xffC7D2FE),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      size: 38,
                                      color: Color(0xff4F46E5),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No official documents found.",
                                    style: sansproBold.copyWith(
                                      fontSize: 16,
                                      color: const Color(0xff1E293B),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "No official documents currently available.",
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

                  return RefreshIndicator(
                    onRefresh: materialsCtrl.fetchDocuments,
                    color: WireframeColor.appcolor,
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: width / 24, vertical: height / 40),
                      itemCount: officialDocs.length + (materialsCtrl.isDocsLoadingMore.value ? 1 : 0),
                      separatorBuilder: (_, __) => SizedBox(height: height / 65),
                      itemBuilder: (context, index) {
                        if (index == officialDocs.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: WireframeColor.appcolor),
                            ),
                          );
                        }

                        final doc = officialDocs[index];
                        return _DocumentTile(
                          doc: doc,
                          width: width,
                          height: height,
                          onTap: () {
                            materialsCtrl.downloadAndOpenDocument(
                              title: doc.title,
                              fileUrl: doc.openableUrl,
                              fileName: '${doc.title}.pdf',
                              category: 'Official Document',
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
}

class _OfficialDocFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OfficialDocFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const lightBg = Color(0xffF3E8FF); // Soft elegant light lavender background
    const border = Color(0xffDDD6FE); // Soft corporate border
    const textColor = Color(0xff6D28D9); // High-contrast purple corporate text
    const dotColor = Color(0xff7C3AED); // Live indicator dot

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: lightBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: dotColor.withAlpha(18),
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
                color: dotColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: sansproBold.copyWith(
                fontSize: 12.5,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final MaterialDocumentItem doc;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _DocumentTile({required this.doc, required this.width, required this.height, required this.onTap});

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
              _tagBadge("Official Document", const Color(0xff4F46E5)),
              if (doc.subjectName.isNotEmpty && doc.subjectName != 'No Subject')
                _tagBadge(doc.subjectName, const Color(0xff64748B)),
              _tagBadge(doc.fileType ?? 'PDF', const Color(0xff16A34A)),
            ],
          ),
          SizedBox(height: height / 100),

          // Metadata row
          Text(
            "${doc.className.isNotEmpty ? doc.className : 'Pre KG'} / ${normalizeSectionWithSession(doc.sectionName.isNotEmpty ? doc.sectionName : 'All Sections')}  \u2022  Teacher: ${doc.teacherName.isNotEmpty ? doc.teacherName : 'Academic Authority'}",
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
                    "Download (${doc.fileSize ?? '252.1 KB'})",
                    style: sansproBold.copyWith(fontSize: 13.5, color: Colors.white),
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
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label,
        style: sansproBold.copyWith(fontSize: 10.5, color: color),
      ),
    );
  }
}
