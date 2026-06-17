const String ShopBankAccountsQuery = r'''
query ShopBankAccounts($userId: ID!) {
  shopBankAccounts(userId: $userId) {
    status
    message
    tap
    total
    data {
      id
      userId
      bankName
      qrImageUrl
    }
  }
}
''';
