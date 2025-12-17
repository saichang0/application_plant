const String userRegisterMutation = r'''
mutation CreateUser($data: CreateUserInput!) {
  createUser(data: $data) {
    status
    message
    tag
    user {
      _id
      firstName
      lastName
      phoneNumber
      password
      email
      role
      status
      profileImage
      pin
      otp
      otpExpiry
    }
    accessToken
    refreshToken
  }
}
''';

const String userLoginMutation = r'''
mutation UserLogin($data: LoginInput!) {
  userLogin(data: $data) {
    status
    message
    tag
    user {
      _id
      firstName
      lastName
      phoneNumber
      password
      email
      role
      status
      profileImage
      pin
      otp
      otpExpiry
    }
    accessToken
    refreshToken
  }
}
''';

const String requestOTPMutation = r'''
mutation RequestOTP($data: RequestOTPInput!) {
  requestOTP(data: $data) {
    status
    message
    tag
  }
}
''';

const String verifyOTPMutation = r'''
mutation VerifyOTP($data: VerifyOTPInput!) {
  verifyOTP(data: $data) {
    status
    message
    tag
  }
}
''';

const String resetPasswordMutation = r'''
mutation ResetPassword($data: ResetPasswordInput!) {
  resetPassword(data: $data) {
    status
    message
    tag
  }
}
''';
