class Plant {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String images;
  final String? discount;
  final bool isFavorite;
  final String description;
  final String? reviewCount;

  Plant({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.images,
    this.discount,
    required this.isFavorite,
    required this.description,
    this.reviewCount,
  });

  factory Plant.fromGraphQL(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0].toString();
    }

    return Plant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      images: imageUrl,
      discount: json['discountPercentage']?.toString(),
      isFavorite: json['isFavorite'] ?? false,
      description: json['description'] ?? '',
      reviewCount: json['reviewCount']?.toString(),
    );
  }

  Plant copyWith({bool? isFavorite}) {
    return Plant(
      id: id,
      name: name,
      price: price,
      rating: rating,
      images: images,
      discount: discount,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description,
      reviewCount: reviewCount,
    );
  }
}
