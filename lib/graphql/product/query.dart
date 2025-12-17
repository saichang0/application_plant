const String ProductsQuery = r'''
query Products($paginate: PaginationInput, $keyword: String, $filter: FilterInputProduct) {
  products(paginate: $paginate, keyword: $keyword, filter: $filter) {
    status
    message
    data {
      _id
      name
      description
      price
      originalPrice
      categoryId
      images
      rating
      reviewCount
      stockQuantity
      isPopular
      isSpecialOffer
      discountPercentage
      isActive
      createdAt
      updatedAt
      deletedAt
      isFavorite
    }
    total
    tag
  }
}
''';

const String Product = r'''
query Product($where: entityInput) {
  product(where: $where) {
    status
    message
    tag
    data {
      _id
      name
      description
      price
      originalPrice
      categoryId
      images
      rating
      reviewCount
      stockQuantity
      isPopular
      isSpecialOffer
      discountPercentage
      isActive
      createdAt
      updatedAt
      deletedAt
      isFavorite
    }
  }
}
''';

const String Wishlist = r'''
query Wishlists {
  wishlists {
    status
    message
    tag
    total
    data {
      _id
      userId
      productId
      product {
        _id
        name
        description
        price
        originalPrice
        categoryId
        images
        rating
        reviewCount
        stockQuantity
        isPopular
        isSpecialOffer
        discountPercentage
      }
    }
  }
}
''';
