const QueryOrder = r'''
query Orders {
  orders {
    status
    message
    tag
    data {
      _id
      userId
      orderNumber
      totalAmount
      status
      shippingAddress {
        _id
        village
        district
        province
        country
        createdAt
        updatedAt
      }
      shippingMethod
      shippingCost
      estimatedDelivery
      paymentMethod
      paymentStatus
      promoCodeId
      discountAmount
      orderItems {
        _id
        orderId
        quantity
        unitPrice
        totalPrice
        createAt
        updateAt
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
          isActive
          createdAt
          updatedAt
          deletedAt
          isFavorite
        }
      }
      createdAt
      updatedAt
    }
  }
}
''';

const QuerorderItems = r'''
query OrderItems {
  orderItems {
    status
    message
    tag
    data {
      _id
      orderId
      quantity
      unitPrice
      totalPrice
      createAt
      updateAt
      productId {
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
}
''';
