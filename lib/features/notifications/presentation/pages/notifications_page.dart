import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../trip/presentation/providers/users_provider.dart';

class NotificationsPage extends ConsumerWidget {
  final String userId;

  const NotificationsPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationControllerProvider(userId));

    final controller =
        ref.read(notificationControllerProvider(userId).notifier);

    final unreadCount =
        notifications.where((notification) => !notification.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          ref.tr('notifications'),
          style: AppTextStyles.h3,
        ),
        backgroundColor: AppColors.background(context),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: controller.markAllAsRead,
              child: Text(ref.tr('mark_all_as_read')),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return _NotificationCard(
                  notification: notification,
                  onTap: () {
                    controller.markAsRead(notification.id);
                    context.go(
                      RouteConstants.tripDashboard.replaceFirst(
                        ':tripId',
                        notification.tripId,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.expenseAdded:
        return Icons.receipt_long_outlined;
      case NotificationType.activityAdded:
        return Icons.event_available_outlined;
      case NotificationType.memberJoined:
        return Icons.person_add_alt_1_outlined;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy · HH:mm').format(date);
  }

  String _getTitle(WidgetRef ref) {
    switch (notification.type) {
      case NotificationType.expenseAdded:
        return ref.tr('notification_expense_title');
      case NotificationType.activityAdded:
        return ref.tr('notification_activity_title');
      case NotificationType.memberJoined:
        return ref.tr('notification_member_title');
    }
  }

  String _getBody(WidgetRef ref, String actorName) {
    switch (notification.type) {
      case NotificationType.expenseAdded:
        return ref.tr(
          'notification_expense_body',
          params: {
            'name': actorName,
            'title': notification.body,
          },
        );

      case NotificationType.activityAdded:
        return ref.tr(
          'notification_activity_body',
          params: {
            'name': actorName,
            'title': notification.body,
          },
        );

      case NotificationType.memberJoined:
        return ref.tr(
          'notification_member_body',
          params: {
            'name': actorName,
          },
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = notification.isRead;

    final userNameAsync = ref.watch(
      userNameProvider(notification.actorId),
    );

    final actorName = userNameAsync.when(
      data: (name) => name.isNotEmpty && name != 'Unknown' ? name : 'Alguien',
      loading: () => 'Alguien',
      error: (_, __) => 'Alguien',
    );

    return Material(
      color: isRead
          ? AppColors.card(context)
          : AppColors.primary.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getTitle(ref),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getBody(ref, actorName),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary(context),
                      ),
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

class _EmptyNotifications extends ConsumerWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: AppColors.textTertiary(context),
            ),
            const SizedBox(height: 20),
            Text(
              ref.tr('notifications_empty_title'),
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              ref.tr('notifications_empty_description'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
