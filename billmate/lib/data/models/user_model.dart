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
      fixedIncome: map['fixed_income'] != null 
          ? double.tryParse(map['fixed_income'].toString()) 
          : null,
      accountType: AccountTypeEnum.values.firstWhere(
        (e) => e.name == map['account_type'], 
        orElse: () => AccountTypeEnum.Simple // Ensure this is a valid default value
      ),
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

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    double? fixedIncome,
    AccountTypeEnum? accountType,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      fixedIncome: fixedIncome ?? this.fixedIncome,
      accountType: accountType ?? this.accountType,
      avatar: avatar ?? this.avatar,
    );
  }
}
