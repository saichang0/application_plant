import 'package:flutter/material.dart';

// Payment Method Model
class PaymentMethod {
  final String name;
  final String? subtitle;
  final String? balance;
  final IconData? icon;
  final Color? iconColor;
  final Color backgroundColor;
  final String? image;

  PaymentMethod({
    required this.name,
    this.subtitle,
    this.balance,
    this.icon,
    this.iconColor,
    required this.backgroundColor,
    this.image,
  });
}

// Payment Methods Constants
class PaymentMethodConstants {
  static final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      name: 'BCEL',
      image: 'assets/images/bcel.png',
      backgroundColor: const Color(0xFFE8F4FF),
    ),
    PaymentMethod(
      name: 'LDB',
      image: 'assets/images/ldb.png',
      backgroundColor: const Color(0xFFE8F0FE),
    ),
    PaymentMethod(
      name: 'JDB',
      image: 'assets/images/jdb.png',
      backgroundColor: const Color(0xFFF5F5F5),
    ),
  ];
}
