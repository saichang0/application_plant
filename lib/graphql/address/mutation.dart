const CreateAddress = r'''
mutation CreateCustomerAddress($input: CreateCustomerAddressInput!) {
  createCustomerAddress(input: $input) {
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

const UpdateAddress = r'''
mutation UpdateCustomerAddress($input: UpdateCustomerAddressInput!) {
  updateCustomerAddress(input: $input) {
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

const DeleteAddress = r'''
mutation DeleteCustomerAddress($input: DeleteCustomerAddressInput!) {
  deleteCustomerAddress(input: $input) {
    status
    message
    tap
    data {
      id
    }
  }
}
''';

const SetDefaultAddress = r'''
mutation SetDefaultCustomerAddress($id: ID!) {
  setDefaultCustomerAddress(id: $id) {
    status
    message
    tap
    data {
      id
      isDefault
    }
  }
}
''';
