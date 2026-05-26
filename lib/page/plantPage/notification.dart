import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/model/order.dart';
import 'package:plant_aplication/page/ordersPage/order.dart';
import 'package:plant_aplication/page/ordersPage/trackOrder.dart';
import 'package:plant_aplication/until/appTranslate.dart';

/// A notification derived from an order's current backend status.
class OrderNotification {
  final OrderItem order;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final Color color;
  final DateTime? when;

  OrderNotification({
    required this.order,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.color,
    required this.when,
  });

  String get key =>
      '${order.orderId}|${order.status.toLowerCase()}|'
      '${order.deliveryStatus.toLowerCase()}';
}

const _kReadNotifPrefsKey = 'read_notification_keys';

final notificationReadProvider =
    StateNotifierProvider<NotificationReadNotifier, Set<String>>(
      (ref) => NotificationReadNotifier(),
    );

class NotificationReadNotifier extends StateNotifier<Set<String>> {
  NotificationReadNotifier() : super(<String>{}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_kReadNotifPrefsKey) ?? <String>[]).toSet();
  }

  Future<void> markRead(String key) async {
    if (state.contains(key)) return;
    final next = {...state, key};
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kReadNotifPrefsKey, next.toList());
  }

  Future<void> markAllRead(Iterable<String> keys) async {
    final next = {...state, ...keys};
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kReadNotifPrefsKey, next.toList());
  }
}

final orderNotificationsProvider = Provider<AsyncValue<List<OrderNotification>>>((
  ref,
) {
  final ordersAsync = ref.watch(ordersProvider);
  return ordersAsync.whenData((items) {
    // ordersProvider yields one OrderItem per line; collapse to one per order.
    final seen = <String>{};
    final perOrder = <OrderItem>[];
    for (final item in items) {
      if (item.orderId.isEmpty || seen.add(item.orderId)) {
        perOrder.add(item);
      }
    }

    final notifications = perOrder
        // "Order completed" is the customer's own confirm action — it is
        // not news to them, so it is not shown as a notification.
        .where((o) => o.status.toLowerCase() != 'completed')
        .map(_notificationFor)
        .toList();
    // Latest update first.
    notifications.sort((a, b) {
      final ad = a.when ?? DateTime(2000);
      final bd = b.when ?? DateTime(2000);
      return bd.compareTo(ad);
    });
    return notifications;
  });
});

/// Number of notifications the customer has not opened yet.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(orderNotificationsProvider);
  final readKeys = ref.watch(notificationReadProvider);
  final notifs = notifsAsync.asData?.value ?? const <OrderNotification>[];
  return notifs.where((n) => !readKeys.contains(n.key)).length;
});

OrderNotification _notificationFor(OrderItem order) {
  final s = order.status.toLowerCase();
  final d = order.deliveryStatus.toLowerCase();

  if (s == 'completed') {
    return OrderNotification(
      order: order,
      titleKey: 'notif_completed_title',
      subtitleKey: 'notif_completed_sub',
      icon: Icons.check_circle_outline,
      color: Colors.green,
      when: order.completedAt ?? order.orderDate,
    );
  }
  if (s == 'cancelled' || s == 'canceled') {
    return OrderNotification(
      order: order,
      titleKey: 'notif_cancelled_title',
      subtitleKey: 'notif_cancelled_sub',
      icon: Icons.cancel_outlined,
      color: Colors.red,
      when: order.completedAt ?? order.orderDate,
    );
  }
  if (s == 'shipping' || s == 'shipped' || d == 'shipping' || d == 'shipped') {
    return OrderNotification(
      order: order,
      titleKey: 'notif_shipping_title',
      subtitleKey: 'notif_shipping_sub',
      icon: Icons.local_shipping_outlined,
      color: ColorConstants.primaryColor,
      when: order.completedAt ?? order.orderDate,
    );
  }
  if (s == 'confirmed') {
    return OrderNotification(
      order: order,
      titleKey: 'notif_confirmed_title',
      subtitleKey: 'notif_confirmed_sub',
      icon: Icons.task_alt_outlined,
      color: ColorConstants.primaryColor,
      when: order.completedAt ?? order.orderDate,
    );
  }
  return OrderNotification(
    order: order,
    titleKey: 'notif_placed_title',
    subtitleKey: 'notif_placed_sub',
    icon: Icons.shopping_bag_outlined,
    color: Colors.orange,
    when: order.orderDate,
  );
}

class NotificationPage extends ConsumerWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final notificationsAsync = ref.watch(orderNotificationsProvider);
    final readKeys = ref.watch(notificationReadProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'notifications'.tr(lang),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Mark every visible notification as read.
          IconButton(
            tooltip: 'mark_all_read'.tr(lang),
            icon: Icon(
              Icons.done_all,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              final all = notificationsAsync.asData?.value ?? const [];
              ref
                  .read(notificationReadProvider.notifier)
                  .markAllRead(all.map((n) => n.key));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(ordersProvider),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 140),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: isDark ? Colors.white24 : Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'notif_empty'.tr(lang),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              );
            }

            final grouped = <String, List<OrderNotification>>{};
            for (final n in notifications) {
              final label = _dateLabel(n.when, lang);
              grouped.putIfAbsent(label, () => []).add(n);
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (n) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotificationTile(
                          notification: n,
                          lang: lang,
                          isDark: isDark,
                          isRead: readKeys.contains(n.key),
                          onTap: () {
                            ref
                                .read(notificationReadProvider.notifier)
                                .markRead(n.key);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrackOrderPage(order: n.order),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  String _dateLabel(DateTime? d, String lang) {
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'notif_today'.tr(lang);
    if (diff == 1) return 'notif_yesterday'.tr(lang);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}

class _NotificationTile extends StatelessWidget {
  final OrderNotification notification;
  final String lang;
  final bool isDark;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.lang,
    required this.isDark,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Unread tiles get a tinted background + accent border + a dot.
    final Color background = isRead
        ? (isDark ? Colors.grey[900]! : Colors.grey[50]!)
        : (isDark
              ? ColorConstants.primaryColor.withOpacity(0.18)
              : ColorConstants.primaryColor.withOpacity(0.08));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: isRead
              ? null
              : Border.all(color: ColorConstants.primaryColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: notification.color,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(notification.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.titleKey.tr(lang),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitleKey.tr(lang),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  if (notification.order.name.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.order.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  color: ColorConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}
