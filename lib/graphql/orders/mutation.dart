const CreateOrder = r'''
mutation CreateOrder($input: OrderInput!) {
  createOrder(input: $input) {
    status
    message
    tag
    data {
      _id
      userId
      orderNumber
      totalAmount
      status
      shippingAddressId
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
        productId
        quantity
        unitPrice
        totalPrice
        createAt
        updateAt
      }
      createdAt
      updatedAt
      createBy
      updateBy
    }
  }
}
''';
