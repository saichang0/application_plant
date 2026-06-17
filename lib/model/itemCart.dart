class CartItem {
  final String id;
  final String name;
  final String image;
  final double price;
  final int quantity;
  // Shop owner whose bank accounts should be shown at checkout.
  final String? ownerId;
  // Legacy single-bank QR (kept as a fallback).
  final String? bankAccountImageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    this.ownerId,
    this.bankAccountImageUrl,
  });

  CartItem copyWith({
    String? id,
    String? name,
    String? image,
    double? price,
    int? quantity,
    String? ownerId,
    String? bankAccountImageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      ownerId: ownerId ?? this.ownerId,
      bankAccountImageUrl: bankAccountImageUrl ?? this.bankAccountImageUrl,
    );
  }
}
