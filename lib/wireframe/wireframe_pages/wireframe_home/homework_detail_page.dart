import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
// ── গ্লোবাল প্যাকেজ পাথ নিশ্চিত করা হলো ──
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/homework_controller.dart';
import 'page_background.dart';
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/teachers_materials_controller.dart';

class HomeworkDetailPage extends StatefulWidget {
  final String id;
  const HomeworkDetailPage({super.key, required this.id});

  @override
  State<HomeworkDetailPage> createState() => _HomeworkDetailPageState();
}

class _HomeworkDetailPageState extends State<HomeworkDetailPage> {
  final HomeworkController ctrl = Get.find<HomeworkController>();

  @override
  void initState() {
    super.initState();
    ctrl.fetchHomeworkDetail(widget.id);
  }

  Future<void> _openAttachment(HomeworkAttachment a) async {
    final url = ctrl.resolveAttachmentUrl(a);
    final materialsCtrl = Get.isRegistered<TeachersMaterialsController>()
        ? Get.find<TeachersMaterialsController>()
        : Get.put(TeachersMaterialsController());
    await materialsCtrl.downloadAndOpenDocument(
      title: a.fileName,
      fileUrl: url,
      fileName: a.fileName,
      category: 'Homework Attachment',
      description: 'Attachment for homework assignment: ${ctrl.detail.value?.title ?? ""}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topSpacing = kToolbarHeight + MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PageAppBar(
        title: 'Homework Detail',
      ),
      body: PageBackground(
        category: PageCategory.homework,
        child: Column(
          children: [
            SizedBox(height: topSpacing),
            Expanded(
              child: Obx(() {
                if (ctrl.isDetailLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ctrl.detailHasError.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        ctrl.detailErrorMessage.value,
                        textAlign: TextAlign.center,
                        style: sansproRegular,
                      ),
                    ),
                  );
                }

                final d = ctrl.detail.value;
                if (d == null) return const SizedBox.shrink();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: Text(d.type, style: sansproSemibold.copyWith(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      d.title,
                      style: sansproBold.copyWith(fontSize: 20, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'বিষয়: ${d.subject}   |   ক্লাস: ${d.className}-${d.section}',
                      style: sansproRegular.copyWith(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Assign: ${d.assignDate}   |   Due: ${d.dueDate}',
                      style: sansproRegular.copyWith(color: Colors.grey[700], fontSize: 13),
                    ),
                    const Divider(height: 32),

                    Text(
                      'বিস্তারিত',
                      style: sansproSemibold.copyWith(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      d.description.isEmpty ? 'কোনো বিবরণ দেওয়া হয়নি।' : d.description,
                      style: sansproRegular.copyWith(fontSize: 14, height: 1.4, color: Colors.black87),
                    ),

                    if (d.attachments.isNotEmpty) ...[
                      const Divider(height: 40),
                      Text(
                        'সংযুক্ত ফাইল',
                        style: sansproSemibold.copyWith(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      ...d.attachments.map(
                            (a) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 1,
                          child: ListTile(
                            leading: Icon(
                              a.fileType.toLowerCase().contains('image')
                                  ? Icons.image_outlined
                                  : Icons.insert_drive_file_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text(
                              a.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: sansproRegular.copyWith(fontSize: 14),
                            ),
                            trailing: const Icon(Icons.download_outlined),
                            onTap: () => _openAttachment(a),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}