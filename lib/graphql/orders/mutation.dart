const CreateOrder = r'''
mutation PlaceOrder($input: PlaceOrderInput!) {
  placeOrder(input: $input) {
    status
    message
    tap
    sale {
      id
      customerId
      userId
      saleDate
      totalAmount
      taxAmount
      discountAmount
      status
      customerName
      note
      customerAddressId
      confirmedAt
      updatedAt
      saleDetails {
        id
        quantity
        unitId
        weightGrams
        unitPrice
        totalPrice
        note
        product {
          id
          name
          imageUrl
        }
        unit {
          id
          name
        }
      }
      payments {
        id
        paymentMethod
        currency
        amount
        slipImageUrl
        paidAt
      }
      customerAddress {
        id
        province
        district
        village
        country
      }
      deliveries {
        id
        deliveryService
        branch
        trackingNumber
        status
        shippedAt
      }
    }
  }
}
''';

const ConfirmOrderReceived = r'''
mutation ConfirmOrderReceived($id: ID!) {
  confirmOrderReceived(id: $id) {
    status
    message
    tap
    sale {
      id
      status
      updatedAt
    }
  }
}
''';

const CreateReview = r'''
mutation CreateReview($input: CreateProductReviewInput!) {
  createReview(input: $input) {
    tap
    status
    message
    data {
      id
      productId
      customerId
      saleId
      rating
      comment
      isVerifiedPurchase
      createdAt
    }
  }
}
''';
