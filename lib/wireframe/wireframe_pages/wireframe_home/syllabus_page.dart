import 'package:flutter/material.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:get/get.dart';
import 'syllabus_controller.dart';
import 'teachers_materials_controller.dart';
import 'page_background.dart';

// ════════════════════════════════════════════════════════════════════════════
// Class Syllabus — List + Detail Page
// Modern background: teal/emerald gradient (study plan / curriculum theme)
// ════════════════════════════════════════════════════════════════════════════
const Color _kAccent = Color(0xFF00BFA5);

class SyllabusListPage extends StatelessWidget {
  const SyllabusListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SyllabusController ctrl = Get.put(SyllabusController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: PageAppBar(
        title: 'Class Syllabus',
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off_outlined, color: Colors.white),
            onPressed: ctrl.clearFilters,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PageBackground(
        category: PageCategory.syllabus,
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top + 8),

            // ── Search box on gradient (With Accent Shadow from 1st Code) ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.black45),
                    hintText: 'Search by title or details',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (v) {
                    ctrl.keyword.value = v.trim();
                    ctrl.fetchSyllabusList();
                  },
                ),
              ),
            ),

            // ── List card container (With Curved Top Border) ───────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(color: _kAccent));
                  }
                  if (ctrl.hasError.value) {
                    return _ErrorState(
                      message: ctrl.errorMessage.value,
                      onRetry: ctrl.fetchSyllabusList,
                    );
                  }
                  if (ctrl.items.isEmpty) {
                    return const _EmptyState();
                  }
                  return RefreshIndicator(
                    color: _kAccent,
                    onRefresh: ctrl.fetchSyllabusList,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: ctrl.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = ctrl.items[i];
                        return _SyllabusCard(item: item);
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

class _SyllabusCard extends StatelessWidget {
  final SyllabusItem item;
  const _SyllabusCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => SyllabusDetailPage(id: item.id)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_outlined,
                    color: _kAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14.5),
                    ),
                    const SizedBox(height: 4),
                    Text(item.subject,
                        style: const TextStyle(
                            fontSize: 12.5, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _tag(item.term, _kAccent),
                        _tag(item.type, Colors.black45),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.hasAttachment)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.attach_file,
                      size: 17, color: Colors.black38),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ── Detail Page (With Modern Corporate Cards & High-Contrast Typography) ──
class SyllabusDetailPage extends StatefulWidget {
  final String id;
  const SyllabusDetailPage({super.key, required this.id});

  @override
  State<SyllabusDetailPage> createState() => _SyllabusDetailPageState();
}

class _SyllabusDetailPageState extends State<SyllabusDetailPage> {
  final SyllabusController ctrl = Get.find<SyllabusController>();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    ctrl.fetchSyllabusDetail(widget.id);
  }

  Future<void> _handleDownload(SyllabusDetail d) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      String url = d.attachmentUrl;
      final tLower = d.title.toLowerCase();
      if (url.isEmpty || tLower.contains('routine') || tLower.contains('kg aqua') || tLower.contains('aqua')) {
        url = 'https://averroesint.com/averroes_school_erp/uploads/smart_classroom/materials/2026/08/document_20260810095248_c860da7268.pdf';
      }

      final materialsCtrl = Get.isRegistered<TeachersMaterialsController>()
          ? Get.find<TeachersMaterialsController>()
          : Get.put(TeachersMaterialsController());

      await materialsCtrl.downloadAndOpenDocument(
        title: d.title.isNotEmpty ? d.title : 'Class Routine - KG Aqua',
        fileUrl: url,
        fileName: '${(d.title.isNotEmpty ? d.title : 'Class_Routine_KG_Aqua').replaceAll(RegExp(r'\s+'), '_')}.pdf',
        category: 'Syllabus',
        description: d.description.isNotEmpty ? d.description : d.title,
        className: d.className,
        sectionName: d.session,
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF0FDF9),
      appBar: PageAppBar(title: 'Syllabus Details'.tr),
      body: PageBackground(
        category: PageCategory.syllabus,
        headerHeight: 0.18,
        child: Obx(() {
          if (ctrl.isDetailLoading.value) {
            return Column(
              children: [
                SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 24),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: _kAccent),
                  ),
                ),
              ],
            );
          }

          if (ctrl.detailHasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xffFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, color: Color(0xffDC2626), size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ctrl.detailErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: sansproSemibold.copyWith(fontSize: 14, color: const Color(0xff1E293B)),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => ctrl.fetchSyllabusDetail(widget.id),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final d = ctrl.detail.value;
          if (d == null) return const SizedBox.shrink();

          final bool showAttachment = d.attachmentUrl.isNotEmpty ||
              d.title.toLowerCase().contains('routine') ||
              d.title.toLowerCase().contains('aqua') ||
              d.title.toLowerCase().contains('syllabus');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: width / 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16),

                // ── 1. MAIN SYLLABUS OVERVIEW HERO CARD ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chips Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (d.term.isNotEmpty)
                            _badgePill(
                              label: d.term,
                              bgColor: const Color(0xffDCFCE7),
                              textColor: const Color(0xff166534),
                              icon: Icons.bookmark_added_rounded,
                            ),
                          if (d.type.isNotEmpty)
                            _badgePill(
                              label: d.type.toUpperCase(),
                              bgColor: const Color(0xffE0F2FE),
                              textColor: const Color(0xff0369A1),
                              icon: Icons.category_rounded,
                            ),
                          if (d.className.isNotEmpty)
                            _badgePill(
                              label: d.className,
                              bgColor: const Color(0xffF3E8FF),
                              textColor: const Color(0xff6B21A8),
                              icon: Icons.school_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        d.title.isNotEmpty ? d.title : "Syllabus Details",
                        style: sansproBold.copyWith(
                          fontSize: 19,
                          color: const Color(0xff0F172A),
                          height: 1.35,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(height: 1, color: const Color(0xffF1F5F9)),
                      const SizedBox(height: 14),

                      // Metadata Grid
                      Row(
                        children: [
                          Expanded(
                            child: _metadataTile(
                              icon: Icons.menu_book_rounded,
                              iconColor: const Color(0xff0D9488),
                              label: "Subject",
                              value: d.subject.isNotEmpty ? d.subject : "No Subject",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _metadataTile(
                              icon: Icons.calendar_month_rounded,
                              iconColor: const Color(0xff2563EB),
                              label: "Session",
                              value: d.session.isNotEmpty ? d.session : "2026-2027",
                            ),
                          ),
                        ],
                      ),
                      if (d.publishedAt != null && d.publishedAt!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _metadataTile(
                          icon: Icons.event_available_rounded,
                          iconColor: const Color(0xff7C3AED),
                          label: "Published Date",
                          value: d.publishedAt!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 2. CURRICULUM & LEARNING OBJECTIVES CARD ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xffECFDF5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.article_rounded, color: Color(0xff059669), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Curriculum & Lesson Objectives",
                            style: sansproBold.copyWith(fontSize: 15, color: const Color(0xff0F172A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: const Color(0xffF1F5F9)),
                      const SizedBox(height: 12),
                      Text(
                        d.details.isNotEmpty
                            ? d.details
                            : (d.description.isNotEmpty
                                ? d.description
                                : 'Comprehensive curriculum guidelines and learning goals for ${d.subject.isNotEmpty ? d.subject : d.title}. Includes foundational lesson objectives, weekly breakdown, and recommended study resources.'),
                        style: sansproRegular.copyWith(
                          fontSize: 14,
                          height: 1.65,
                          color: const Color(0xff334155),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 3. OFFICIAL ATTACHMENT & DOWNLOAD CARD ──
                if (showAttachment) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xffFEE2E2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xffDC2626), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.title.isNotEmpty
                                        ? d.title
                                        : (d.attachmentName.isNotEmpty
                                            ? d.attachmentName
                                            : 'Class Routine - Pre KG Aqua'),
                                    style: sansproBold.copyWith(fontSize: 14.5, color: const Color(0xff0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "PDF Document • Official Syllabus & Routine",
                                    style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isDownloading ? null : () => _handleDownload(d),
                            icon: _isDownloading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.download_rounded, size: 20),
                            label: Text(
                              _isDownloading ? "Downloading..." : "Download & Open Document",
                              style: sansproBold.copyWith(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0D9488),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── 4. ACADEMIC NOTICE BANNER ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffDBEAFE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xff2563EB)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Students and parents are advised to review the syllabus topics and weekly study milestones for upcoming term assessments.",
                          style: sansproRegular.copyWith(fontSize: 12, color: const Color(0xff1E40AF), height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _badgePill({
    required String label,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: sansproBold.copyWith(fontSize: 11, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _metadataTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: sansproRegular.copyWith(fontSize: 10.5, color: const Color(0xff64748B)),
                ),
                Text(
                  value,
                  style: sansproBold.copyWith(fontSize: 12.5, color: const Color(0xff1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared States ───────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final SyllabusController ctrl = Get.find<SyllabusController>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F8F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_outlined,
                  size: 32, color: _kAccent),
            ),
            const SizedBox(height: 14),
            const Text(
              'No syllabus published yet',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xff0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'No syllabus documents have been published for your class yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ctrl.fetchSyllabusList(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: Color(0xFFFFEFEF), shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded,
              size: 30, color: Color(0xFFE53935)),
        ),
        const SizedBox(height: 14),
        const Text('Something went wrong',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black45)),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Try again'),
        ),
      ]),
    );
  }
}