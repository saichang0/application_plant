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
  final String? ownerId;
  final String? shopName;
  final String? bankAccountImageUrl;
  final String? categoryId;
  final String? categoryName;
  final int viewsCount;

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
    this.ownerId,
    this.shopName,
    this.bankAccountImageUrl,
    this.categoryId,
    this.categoryName,
    this.viewsCount = 0,
  });

  factory Plant.fromGraphQL(Map<String, dynamic> json) {
    final imageUrl = (json['imageUrl'] ?? '').toString();
    final owner = json['owner'];
    final ownerId = owner is Map<String, dynamic>
        ? owner['id']?.toString()
        : null;
    final shopName = owner is Map<String, dynamic>
        ? owner['shopName']?.toString()
        : null;
    final bankAccountImageUrl = owner is Map<String, dynamic>
        ? owner['bankAccountImageUrl']?.toString()
        : null;
    final category = json['category'];
    final categoryId = category is Map<String, dynamic>
        ? category['id']?.toString()
        : null;
    final categoryName = category is Map<String, dynamic>
        ? category['name']?.toString()
        : null;

    // Average rating + review count come from productReviews.
    double rating = 0;
    int reviewCount = 0;
    final reviews = json['productReviews'];
    if (reviews is List && reviews.isNotEmpty) {
      double total = 0;
      int counted = 0;
      for (final r in reviews) {
        if (r is Map && r['rating'] != null) {
          final v = double.tryParse(r['rating'].toString());
          if (v != null) {
            total += v;
            counted += 1;
          }
        }
      }
      reviewCount = reviews.length;
      if (counted > 0) rating = total / counted;
    }
    if (rating == 0 && json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString()) ?? 0;
    }

    // viewsCount: prefer server-provided counter; fall back to productViews length.
    int viewsCount = 0;
    if (json['viewsCount'] is num) {
      viewsCount = (json['viewsCount'] as num).toInt();
    } else if (json['viewsCount'] != null) {
      viewsCount = int.tryParse(json['viewsCount'].toString()) ?? 0;
    }
    final views = json['productViews'];
    if (viewsCount == 0 && views is List) {
      viewsCount = views.length;
    }

    return Plant(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      price: double.tryParse((json['salePrice'] ?? 0).toString()) ?? 0,
      rating: rating,
      images: imageUrl,
      discount: json['discount']?.toString(),
      isFavorite: json['isFavorite'] ?? false,
      description: json['description'] ?? '',
      reviewCount: (json['reviewCount']?.toString()) ?? reviewCount.toString(),
      ownerId: ownerId,
      shopName: shopName,
      bankAccountImageUrl: bankAccountImageUrl,
      categoryId: categoryId,
      categoryName: categoryName,
      viewsCount: viewsCount,
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
      ownerId: ownerId,
      shopName: shopName,
      bankAccountImageUrl: bankAccountImageUrl,
      categoryId: categoryId,
      categoryName: categoryName,
      viewsCount: viewsCount,
    );
  }
}
