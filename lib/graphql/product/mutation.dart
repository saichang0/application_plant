const String ToggleWishlist = r'''
mutation ToggleWishlist($productId: String!) {
  toggleWishlist(productId: $productId) {
    status
    message
    tap
    data {
      id
      customerId
      productId
      isFavorite
    }
  }
}
''';
