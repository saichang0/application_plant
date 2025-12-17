import 'package:flutter/material.dart';
import 'package:plant_aplication/constant/colorConst.dart';

class NotificationModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final String date;

  NotificationModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.date,
  });
}

class NotificationPage extends StatelessWidget {
  NotificationPage({Key? key}) : super(key: key);

  final List<NotificationModel> notifications = [
    NotificationModel(
      title: '30% Special Discount!',
      subtitle: 'Special promotion only valid today',
      icon: Icons.discount_outlined,
      date: 'Today',
    ),
    NotificationModel(
      title: 'Top Up E-Wallet Successful!',
      subtitle: 'You have to top up your e-wallet',
      icon: Icons.account_balance_wallet_outlined,
      date: 'Yesterday',
    ),
    NotificationModel(
      title: 'New Services Available!',
      subtitle: 'Now you can track orders in real time',
      icon: Icons.location_on_outlined,
      date: 'Yesterday',
    ),
    NotificationModel(
      title: 'Credit Card Connected!',
      subtitle: 'Credit Card has been linked!',
      icon: Icons.credit_card_outlined,
      date: 'December 22, 2024',
    ),
    NotificationModel(
      title: 'Account Setup Successful!',
      subtitle: 'Your account has been created!',
      icon: Icons.person_outline,
      date: 'December 22, 2024',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, List<NotificationModel>> groupedNotifications = {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    for (var notification in notifications) {
      if (!groupedNotifications.containsKey(notification.date)) {
        groupedNotifications[notification.date] = [];
      }
      groupedNotifications[notification.date]!.add(notification);
    }

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
          'Notification',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final date = groupedNotifications.keys.elementAt(index);
          final items = groupedNotifications[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              ...items.map((notification) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NotificationTile(notification: notification),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({Key? key, required this.notification})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? ColorConstants.primaryColor : Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(notification.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
