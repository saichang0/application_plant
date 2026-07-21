import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/page/plantPage/notification.dart';

class NotificationIconButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double iconSize;

  const NotificationIconButton({
    Key? key,
    this.onPressed,
    this.iconColor,
    this.iconSize = 22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = ref.watch(unreadNotificationCountProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            size: iconSize,
            color: iconColor ?? (isDark ? Colors.white : Colors.black),
          ),
          onPressed: onPressed ?? () {},
        ),
        if (unread > 0)
          Positioned(
            top: 6,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// class FavoriteIconButton extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final Color? iconColor;
//   final double iconSize;

//   const FavoriteIconButton({
//     Key? key,
//     this.onPressed,
//     this.iconColor,
//     this.iconSize = 22,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return IconButton(
//       icon: Icon(
//         Icons.favorite_border,
//         size: iconSize,
//         color: iconColor ?? (isDark ? Colors.white : Colors.black),
//       ),
//       onPressed: onPressed ?? () {},
//     );
//   }
// }

class HeaderActionButtons extends StatelessWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onFavoritePressed;
  final Color? iconColor;
  final double iconSize;

  const HeaderActionButtons({
    Key? key,
    this.onNotificationPressed,
    this.onFavoritePressed,
    this.iconColor,
    this.iconSize = 22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NotificationIconButton(
          onPressed: onNotificationPressed,
          iconColor: iconColor,
          iconSize: iconSize,
        ),
        // FavoriteIconButton(
        //   onPressed: onFavoritePressed,
        //   iconColor: iconColor,
        //   iconSize: iconSize,
        // ),
      ],
    );
  }
}
