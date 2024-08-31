class AccountTypeEnum {
  final String value;

  const AccountTypeEnum(this.value);

  static const Personal = AccountTypeEnum('Simple');

  static const Business = AccountTypeEnum('Prime');

  static AccountTypeEnum fromString(String? value) {
    switch (value) {
      case 'Simple':
        return Personal;

      case 'Prime':
        return Business;

      default:
        throw Exception('Invalid account type');
    }
  }
}
