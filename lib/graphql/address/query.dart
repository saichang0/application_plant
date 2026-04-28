const QueryAddress = r'''
query CustomerAddresses {
  customerAddresses {
    status
    message
    tap
    data {
      id
      customerId
      province
      district
      village
      country
      isDefault
      createdAt
      updatedAt
    }
  }
}
''';

const QueryAddressById = r'''
query CustomerAddress($id: ID!) {
  customerAddress(id: $id) {
    status
    message
    tap
    data {
      id
      customerId
      province
      district
      village
      country
      isDefault
      createdAt
      updatedAt
    }
  }
}
''';
