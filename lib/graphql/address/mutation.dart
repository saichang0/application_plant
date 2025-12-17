const CreateAddress = r'''
mutation CreateUserAddress($input: CreateUserAddressInput!) {
  createUserAddress(input: $input) {
    status
    message
    tag
    data {
      _id
      village
      district
      province
      country
    }
  }
}
''';
