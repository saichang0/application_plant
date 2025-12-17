class OrderItem {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final double totalPrice;
  final String status;
  final bool isCompleted;
  final DateTime? orderDate;

  OrderItem({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.isCompleted,
    this.orderDate,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];

    return OrderItem(
      id: json['_id'] ?? '',
      name: product != null ? product['name'] ?? '' : '',
      image:
          product != null &&
              product['images'] != null &&
              (product['images'] as List).isNotEmpty
          ? product['images'][0]
          : '',
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'Processing',
      isCompleted: (json['status'] ?? '').toLowerCase() == 'completed',
      orderDate: json['createAt'] != null
          ? DateTime.tryParse(json['createAt'])
          : null,
    );
  }
}
