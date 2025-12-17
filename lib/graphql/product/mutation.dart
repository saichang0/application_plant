const String ToggleWishlist = r'''
mutation ToggleWishlist($productId: String!) {
  toggleWishlist(productId: $productId) {
    status
    message
    tag
    data {
      _id
      userId
      productId
      isFavorite
    }
  }
}
''';
