class OrderItem {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final double totalPrice;
  final String status;
  final bool isCompleted;
  final DateTime? orderDate;
  final DateTime? completedAt;
  final DateTime? shippedAt;
  final DateTime? confirmedAt;
  final String productId;
  final String orderId;
  final int lineCount;
  final String deliveryStatus;
  final String deliveryService;
  final String deliveryBranch;
  final String trackingNumber;

  OrderItem({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.isCompleted,
    required this.productId,
    required this.orderId,
    this.orderDate,
    this.completedAt,
    this.shippedAt,
    this.confirmedAt,
    this.lineCount = 1,
    this.deliveryStatus = '',
    this.deliveryService = '',
    this.deliveryBranch = '',
    this.trackingNumber = '',
  });

  /// Builds an [OrderItem] from a single `saleDetail` entry.
  ///
  /// The parent sale's `status`, `id` (orderId), and `saleDate` must be
  /// merged into the detail map before calling this — see
  /// `CreateOrderController.fetchOrderItems` / `ordersProvider`.
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final deliveries = json['deliveries'];
    Map<String, dynamic>? firstDelivery;
    if (deliveries is List && deliveries.isNotEmpty) {
      firstDelivery = Map<String, dynamic>.from(deliveries.first as Map);
    }

    return OrderItem(
      id: (json['id'] ?? '').toString(),
      name: product != null ? (product['name'] ?? '') : '',
      image: product != null ? (product['imageUrl'] ?? '') : '',
      quantity: (json['quantity'] ?? 0) is int
          ? json['quantity'] ?? 0
          : (json['quantity'] as num).toInt(),
      totalPrice: (json['totalPrice'] ?? 0) is num
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse(json['totalPrice'].toString()) ?? 0,
      status: json['status'] ?? 'Processing',
      isCompleted: (json['status'] ?? '').toString().toLowerCase() == 'completed',
      productId: product != null ? (product['id'] ?? '').toString() : '',
      orderId: (json['orderId'] ?? '').toString(),
      orderDate: json['saleDate'] != null
          ? DateTime.tryParse(json['saleDate'].toString())
          : (json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString())
                : null),
      // The shop owner's confirm/complete action updates the sale row, so
      // `updatedAt` is the moment the customer is told they can get the plant.
      completedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      shippedAt: firstDelivery?['shippedAt'] != null
          ? DateTime.tryParse(firstDelivery!['shippedAt'].toString())
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
      lineCount: (json['lineCount'] is num)
          ? (json['lineCount'] as num).toInt()
          : 1,
      deliveryStatus: firstDelivery?['status']?.toString() ?? '',
      deliveryService: firstDelivery?['deliveryService']?.toString() ?? '',
      deliveryBranch: firstDelivery?['branch']?.toString() ?? '',
      trackingNumber: firstDelivery?['trackingNumber']?.toString() ?? '',
    );
  }
}
