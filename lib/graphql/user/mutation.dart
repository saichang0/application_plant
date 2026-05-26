const String userRegisterMutation = r'''
mutation CreateCustomer($data: createCustomerInput!) {
  createCustomer(data: $data) {
    status
    message
    tap
    customer {
      id
      firstName
      lastName
      phoneNumber
      email
      profileImageUrl
      address
    }
    accessToken
    refreshToken
  }
}
''';

const String userLoginMutation = r'''
mutation LoginCustomer($data: CustomerLoginInput!) {
  loginCustomer(data: $data) {
    status
    message
    tap
    customer {
      id
      firstName
      lastName
      phoneNumber
      email
      profileImageUrl
      address
    }
    accessToken
    refreshToken
  }
}
''';

const String updateCustomerMutation = r'''
mutation UpdateCustomer($data: UpdateCustomerInput!) {
  updateCustomer(data: $data) {
    status
    message
    tap
    customer {
      id
      firstName
      lastName
      phoneNumber
      email
      profileImageUrl
      address
    }
  }
}
''';

const String requestOTPMutation = r'''
mutation RequestOTP($data: RequestOTPInput!) {
  requestOTP(data: $data) {
    status
    message
    tap
  }
}
''';

const String verifyOTPMutation = r'''
mutation VerifyOTP($data: VerifyOTPInput!) {
  verifyOTP(data: $data) {
    status
    message
    tap
  }
}
''';

const String resetPasswordMutation = r'''
mutation ResetPassword($data: ResetPasswordInput!) {
  resetPassword(data: $data) {
    status
    message
    tap
    customer {
      id
      firstName
      lastName
      phoneNumber
      email
      profileImageUrl
      address
    }
    accessToken
    refreshToken
  }
}
''';
