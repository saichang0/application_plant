const QueryAddress = r'''
 query UserAddresses {
  userAddresses {
    status
    message
    tag
    data {
      _id
      village
      district
      province
      country
      createdAt
      updatedAt
    }
  }
}
''';
