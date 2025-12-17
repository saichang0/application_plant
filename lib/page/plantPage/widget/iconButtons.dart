import 'package:flutter/material.dart';

class NotificationIconButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        Icons.notifications_outlined,
        size: iconSize,
        color: iconColor ?? (isDark ? Colors.white : Colors.black),
      ),
      onPressed: onPressed ?? () {},
    );
  }
}

class FavoriteIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double iconSize;

  const FavoriteIconButton({
    Key? key,
    this.onPressed,
    this.iconColor,
    this.iconSize = 22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        Icons.favorite_border,
        size: iconSize,
        color: iconColor ?? (isDark ? Colors.white : Colors.black),
      ),
      onPressed: onPressed ?? () {},
    );
  }
}

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
        FavoriteIconButton(
          onPressed: onFavoritePressed,
          iconColor: iconColor,
          iconSize: iconSize,
        ),
      ],
    );
  }
}
