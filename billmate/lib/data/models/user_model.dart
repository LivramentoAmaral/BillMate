
import 'package:billmate/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.fixedIncome,
    required super.accountType,
    super.avatar,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int? ?? 0,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      fixedIncome: map['fixed_income'] != null ? double.tryParse(map['fixed_income']) : null,
      accountType: AccountTypeEnum.values.byName(map['account_type'] ?? 'Simple'),
      avatar: map['avatar'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'fixed_income': fixedIncome?.toString() ?? '',
      'account_type': accountType.name,
      'avatar': avatar ?? '',
    };
  }
}
