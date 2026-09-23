import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
// ── গ্লোবাল প্যাকেজ পাথ নিশ্চিত করা হলো ──
import 'package:averroes_student_app/wireframe/wireframe_pages/wireframe_home/homework_controller.dart';
import 'homework_detail_page.dart';
import 'page_hero_header.dart';

class HomeworkListPage extends StatelessWidget {
  // ── lockedType দিলে এই page টা শুধু ওই type (Homework/Classwork) এর জন্য
  // fix হয়ে যায় — Type chip filter সরিয়ে ফেলা হয়, title/subtitle ও আলাদা
  // হয়, এবং GetX controller instance-ও আলাদা tag দিয়ে রাখা হয় যাতে
  // Homework পেজ আর Classwork পেজ একে অপরের state/list শেয়ার না করে। ──
  final String? lockedType; // null = পুরনো "সব একসাথে" ভিউ (backward compatible)

  const HomeworkListPage({super.key, this.lockedType});

  static const Color _accent = Color(0xFF3D5AFE);

  bool get _isClasswork => lockedType == 'Classwork';

  @override
  Widget build(BuildContext context) {
    final tag = lockedType; // null হলে ডিফল্ট (untagged) controller
    final HomeworkController ctrl = Get.put(HomeworkController(), tag: tag);

    if (lockedType != null && ctrl.selectedType.value != lockedType) {
      // পেজ প্রথমবার খোলার সময় type টা লক করে দেওয়া হচ্ছে
      ctrl.selectedType.value = lockedType!;
    }

    final pageTitle = lockedType == null
        ? 'Homework & Classwork'
        : (_isClasswork ? 'Classwork' : 'Homework');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          PageHeroHeader(
            theme: PageHeroTheme.homework,
            title: pageTitle,
            subtitle: 'Session · Class · Section · Subject',
            onBack: () => Navigator.pop(context),
            actions: [
              IconButton(
                tooltip: 'Clear filters',
                icon: const Icon(Icons.filter_alt_off_outlined, color: Colors.white),
                onPressed: () {
                  ctrl.clearFilters();
                  if (lockedType != null) ctrl.selectedType.value = lockedType!;
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
          _FilterBar(ctrl: ctrl, accent: _accent, showTypeChips: lockedType == null),
          _AdvancedFilterSection(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: _accent));
              }
              if (ctrl.hasError.value) {
                return _ErrorState(
                  message: ctrl.errorMessage.value,
                  onRetry: ctrl.fetchHomeworkList,
                  accent: _accent,
                );
              }
              if (ctrl.items.isEmpty) {
                return _EmptyState(lockedType: lockedType);
              }
              return RefreshIndicator(
                color: _accent,
                onRefresh: ctrl.fetchHomeworkList,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: ctrl.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = ctrl.items[index];
                    return _HomeworkCard(item: item, accent: _accent);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final HomeworkController ctrl;
  final Color accent;
  final bool showTypeChips;
  const _FilterBar({required this.ctrl, required this.accent, this.showTypeChips = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black45),
                hintText: 'Search by title or description...',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: (v) {
                ctrl.keyword.value = v.trim();
                ctrl.applyFiltersAndReload();
              },
            ),
          ),
          if (showTypeChips) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _typeChip(ctrl, '', 'All Work'),
                  const SizedBox(width: 8),
                  _typeChip(ctrl, 'Homework', 'Homework'),
                  const SizedBox(width: 8),
                  _typeChip(ctrl, 'Classwork', 'Classwork'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeChip(HomeworkController ctrl, String value, String label) {
    return Obx(() {
      final selected = ctrl.selectedType.value == value;
      return GestureDetector(
        onTap: () {
          ctrl.selectedType.value = value;
          ctrl.applyFiltersAndReload();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? accent : const Color(0xFFF1F2F6),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}

class _AdvancedFilterSection extends StatelessWidget {
  final HomeworkController ctrl;
  const _AdvancedFilterSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterDropdown(
              hint: 'Session',
              selectedObs: ctrl.selectedSession,
              items: ['2025', '2026', '2027'],
            ),
            const SizedBox(width: 8),
            _buildFilterDropdown(
              hint: 'Class',
              selectedObs: ctrl.selectedClass,
              items: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6'],
            ),
            const SizedBox(width: 8),
            _buildFilterDropdown(
              hint: 'Section',
              selectedObs: ctrl.selectedSection,
              items: ['A', 'B', 'C', 'Gold', 'Silver'],
            ),
            const SizedBox(width: 8),
            _buildFilterDropdown(
              hint: 'Subject',
              selectedObs: ctrl.selectedSubject,
              items: ['English', 'Mathematics', 'Science', 'Bangla'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required RxString selectedObs,
    required List<String> items,
  }) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedObs.value.isEmpty ? null : selectedObs.value,
            hint: Text(hint, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black45),
            items: items.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (String? newVal) {
              if (newVal != null) {
                selectedObs.value = newVal;
                ctrl.applyFiltersAndReload();
              }
            },
          ),
        ),
      );
    });
  }
}

class _HomeworkCard extends StatelessWidget {
  final HomeworkItem item;
  final Color accent;
  const _HomeworkCard({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isHomework = item.type.toLowerCase() == 'homework';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => HomeworkDetailPage(id: item.id)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                  color: (isHomework ? accent : const Color(0xFFFF9100)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isHomework ? Icons.home_work_outlined : Icons.class_outlined,
                  color: isHomework ? accent : const Color(0xFFFF9100),
                  size: 22,
                ),
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
                      style: sansproSemibold.copyWith(
                        fontSize: 14.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.subject} • Class ${item.className}-${item.section}',
                      style: sansproRegular.copyWith(fontSize: 12.5, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 13, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(
                          'Due ${item.dueDate}',
                          style: sansproRegular.copyWith(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.hasAttachment)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.attach_file, size: 17, color: Colors.black38),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? lockedType;
  const _EmptyState({this.lockedType});

  @override
  Widget build(BuildContext context) {
    final label = lockedType == null
        ? 'homework or classwork'
        : lockedType!.toLowerCase();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF1FB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined, size: 32, color: Colors.black38),
          ),
          const SizedBox(height: 14),
          Text(
            'Nothing here yet',
            style: sansproSemibold.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'No $label matches this filter.',
            style: sansproRegular.copyWith(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color accent;
  const _ErrorState({required this.message, required this.onRetry, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEFEF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded, size: 30, color: Color(0xFFE53935)),
          ),
          const SizedBox(height: 14),
          Text(
            'Something went wrong',
            style: sansproSemibold.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: sansproRegular.copyWith(fontSize: 13, color: Colors.black45),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Try again', style: sansproSemibold.copyWith(fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}