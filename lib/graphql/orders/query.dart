const QueryOrder = r'''
query MyOrders($status: String, $limit: Int, $offset: Int) {
  myOrders(status: $status, limit: $limit, offset: $offset) {
    status
    message
    tap
    total
    sales {
      id
      code
      source
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
      user {
        id
        firstName
        lastName
        shopName
        phoneNumber
      }
      customerAddress {
        id
        province
        district
        village
        country
      }
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
        paidAt
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

const QueryOrderById = r'''
query MyOrder($id: ID!) {
  myOrder(id: $id) {
    status
    message
    tap
    sale {
      id
      code
      source
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
      user {
        id
        firstName
        lastName
        shopName
        phoneNumber
      }
      customerAddress {
        id
        province
        district
        village
        country
      }
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
        paidAt
      }
    }
  }
}
''';
