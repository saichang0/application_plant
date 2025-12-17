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
      name: 'My Wallet',
      balance: '\$9,449',
      icon: Icons.account_balance_wallet,
      iconColor: Colors.white,
      backgroundColor: const Color(0xFF00D9A3),
    ),
    PaymentMethod(
      name: 'PayPal',
      icon: Icons.paypal,
      iconColor: const Color(0xFF003087),
      backgroundColor: const Color(0xFFE8F4FF),
    ),
    PaymentMethod(
      name: 'Google Pay',
      icon: Icons.g_mobiledata,
      iconColor: const Color(0xFF4285F4),
      backgroundColor: const Color(0xFFE8F0FE),
    ),
    PaymentMethod(
      name: 'Apple Pay',
      icon: Icons.apple,
      iconColor: Colors.black,
      backgroundColor: const Color(0xFFF5F5F5),
    ),
    PaymentMethod(
      name: '**** **** **** 4679',
      subtitle: 'Mastercard',
      icon: Icons.credit_card,
      iconColor: const Color(0xFFEB001B),
      backgroundColor: const Color(0xFFFFF0F0),
    ),
  ];
}
