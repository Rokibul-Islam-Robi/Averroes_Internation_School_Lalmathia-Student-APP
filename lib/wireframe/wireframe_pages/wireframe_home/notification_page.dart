import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_fontstyle.dart';
import 'package:averroes_student_app/wireframe/wireframe_gloabelclass/wireframe_color.dart';
import 'appointment_page.dart';
import 'complain_page.dart';
import 'fees_overview_page.dart';
import 'notification_controller.dart';
import 'notification_model.dart';
import 'page_hero_header.dart';
import 'teachers_materials_controller.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final NotificationController nCtrl = Get.find<NotificationController>();

    return HeroScaffold(
      backgroundColor: const Color(0xffF5F6FC),
      hero: PageHeroHeader(
        theme: PageHeroTheme.notifications,
        title: 'Notifications',
        subtitle: 'Stay updated with your activities',
        onBack: () => Navigator.pop(context),
        actions: [
          Obx(() {
            final hasUnread = nCtrl.unreadCount > 0;
            return hasUnread
                ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => nCtrl.markAllAsRead(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Mark all read',
                    style: sansproRegular.copyWith(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            )
                : const SizedBox();
          }),
        ],
      ),
      body: Obx(() {
        if (nCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: WireframeColor.appcolor));
        }

        if (nCtrl.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                nCtrl.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ),
          );
        }

        if (nCtrl.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: WireframeColor.textgray.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: sansproRegular.copyWith(fontSize: 16, color: WireframeColor.textgray),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: WireframeColor.appcolor,
          onRefresh: () async {
            await nCtrl.refresh();
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: w / 26, vertical: 10),
            itemCount: nCtrl.notifications.length,
            itemBuilder: (context, index) {
              final notif = nCtrl.notifications[index];
              return _NotificationCard(
                notification: notif,
                onTap: () {
                  if (!notif.isRead) {
                    nCtrl.markAsRead(notif.id);
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type.toLowerCase()) {
      case 'complain':
      case 'complaint':
        return Icons.admin_panel_settings_rounded;
      case 'fee':
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'homework':
      case 'assignment':
        return Icons.assignment_outlined;
      case 'exam':
      case 'routine':
        return Icons.school_outlined;
      case 'holiday':
        return Icons.celebration_outlined;
      case 'appointment':
        return Icons.event_available_rounded;
      default:
        return Icons.campaign_outlined;
    }
  }

  Color get _color {
    switch (notification.type.toLowerCase()) {
      case 'complain':
      case 'complaint':
        return const Color(0xff15803D);
      case 'fee':
      case 'payment':
        return const Color(0xffE2136E);
      case 'homework':
      case 'assignment':
        return const Color(0xff1A56DB);
      case 'exam':
      case 'routine':
        return const Color(0xff7030A0);
      case 'holiday':
        return const Color(0xff2E7D32);
      case 'appointment':
        return const Color(0xff4F46E5);
      default:
        return const Color(0xff7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        onTap();
        final type = notification.type.toLowerCase();
        if (type == 'complain' || type == 'complaint') {
          Get.to(() => const ComplainPage(initialTabIndex: 1));
        } else if (type == 'fee' || type == 'payment') {
          Get.to(() => const FeesOverviewPage());
        } else if (type == 'appointment') {
          Get.to(() => const AppointmentPage(initialTabIndex: 1));
        } else if (notification.hasAttachment) {
          final tmCtrl = Get.isRegistered<TeachersMaterialsController>()
              ? Get.find<TeachersMaterialsController>()
              : Get.put(TeachersMaterialsController());
          tmCtrl.downloadAndOpenDocument(
            title: notification.title,
            fileUrl: notification.fileUrl!,
            fileName: '${notification.title.replaceAll(' ', '_')}.pdf',
            category: 'Announcement',
            description: notification.message,
            publishedAt: notification.time,
            className: notification.className ?? 'Pre KG',
            sectionName: notification.sectionName ?? 'Aqua',
            teacherName: notification.teacherName ?? 'Academic Authority',
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: h / 65),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? const Color(0xffE2E8F0) : _color.withAlpha(90),
            width: notification.isRead ? 1 : 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: notification.isRead
                  ? Colors.black.withAlpha(8)
                  : _color.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w / 26, vertical: h / 65),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _color, size: 22),
              ),
              SizedBox(width: w / 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: sansproBold.copyWith(
                              fontSize: 14.5,
                              color: const Color(0xff0F172A),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    if (notification.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: sansproRegular.copyWith(
                          fontSize: 13,
                          color: const Color(0xff475569),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Color(0xff94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          notification.time,
                          style: sansproRegular.copyWith(
                            fontSize: 11.5,
                            color: const Color(0xff94A3B8),
                          ),
                        ),
                        if (notification.hasAttachment) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xff16A34A).withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xff16A34A).withAlpha(60)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attachment_rounded, size: 12, color: Color(0xff16A34A)),
                                const SizedBox(width: 4),
                                Text(
                                  "Attachment",
                                  style: sansproBold.copyWith(fontSize: 10.5, color: const Color(0xff16A34A)),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  }
}