const String ProductsQuery = r'''
query PublicProducts(
  $keyword: String
  $paginate: PaginationInput
  $filter: FilterInputProduct
  $shopId: ID
) {
  publicProducts(
    keyword: $keyword
    paginate: $paginate
    filter: $filter
    shopId: $shopId
  ) {
    status
    message
    tap
    total
    data {
      id
      name
      description
      size
      imageUrl
      stockQuantity
      stockWeight
      costPrice
      salePrice
      pricePerKg
      pricePerHalfBag
      pricePer12Kg
      weightPerUnit
      isPopular
      isSpecialOffer
      discount
      isActive
      createdAt
      viewsCount
      isFavorite
      productViews {
        id
        source
        createdAt
      }
      productReviews {
        id
        rating
      }
      category {
        id
        name
      }
      unit {
        id
        name
        weightInGrams
      }
      owner {
        id
        firstName
        lastName
        shopName
        profileImageUrl
        bankAccountImageUrl
      }
    }
  }
}
''';

const String Product = r'''
query PublicProduct($id: ID!) {
  publicProduct(id: $id) {
    status
    message
    tap
    data {
      id
      name
      description
      size
      imageUrl
      stockQuantity
      stockWeight
      costPrice
      salePrice
      pricePerKg
      pricePerHalfBag
      pricePer12Kg
      weightPerUnit
      isPopular
      isSpecialOffer
      discount
      isActive
      createdAt
      viewsCount
      isFavorite
      productViews {
        id
        source
        createdAt
      }
      productReviews {
        id
        rating
      }
      category {
        id
        name
      }
      unit {
        id
        name
        weightInGrams
      }
      owner {
        id
        firstName
        lastName
        shopName
        profileImageUrl
        bankAccountImageUrl
      }
    }
  }
}
''';

const String Wishlist = r'''
query Wishlists {
  wishlists {
    status
    message
    tap
    total
    data {
      id
      customerId
      productId
      product {
        id
        name
        description
        size
        imageUrl
        stockQuantity
        stockWeight
        costPrice
        salePrice
        pricePerKg
        pricePerHalfBag
        pricePer12Kg
        weightPerUnit
        isPopular
        isSpecialOffer
        discount
        isActive
        createdAt
        viewsCount
        isFavorite
        productViews {
          id
          source
          createdAt
        }
        productReviews {
          id
          rating
        }
        category {
          id
          name
        }
        unit {
          id
          name
          weightInGrams
        }
        owner {
          id
          firstName
          lastName
          shopName
          profileImageUrl
          bankAccountImageUrl
        }
      }
    }
  }
}
''';
