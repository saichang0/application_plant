class ShippingOption {
  final String name;
  final String date;
  final String price;
  final String icon;

  ShippingOption({
    required this.name,
    required this.date,
    required this.price,
    required this.icon,
  });
}

class ShippingConstants {
  static final List<ShippingOption> shippingOptions = [
    ShippingOption(
      name: 'MIXAY',
      date: 'Estimated Arrival: Dec 20-23',
      price: '\$10',
      icon: '📦',
    ),
    ShippingOption(
      name: 'ANOUSITH',
      date: 'Estimated Arrival: Dec 20-22',
      price: '\$15',
      icon: '🚚',
    ),
    ShippingOption(
      name: 'KIANGKAI',
      date: 'Estimated Arrival: Dec 19-20',
      price: '\$20',
      icon: '📮',
    ),
    ShippingOption(
      name: 'HAL',
      date: 'Estimated Arrival: Dec 18-19',
      price: '\$30',
      icon: '⚡',
    ),
  ];
}
