class ShippingOption {
  final String name;
  final String image;

  ShippingOption({required this.name, required this.image});
}

class ShippingConstants {
  static final List<ShippingOption> shippingOptions = [
    ShippingOption(name: 'MIXAY', image: 'assets/images/mixay.png'),
    ShippingOption(name: 'ANOUSITH', image: 'assets/images/anousith.png'),
    ShippingOption(name: 'KIANGKAI', image: 'assets/images/kiankai.jpg'),
    ShippingOption(name: 'HAL', image: 'assets/images/hal.png'),
  ];
}
