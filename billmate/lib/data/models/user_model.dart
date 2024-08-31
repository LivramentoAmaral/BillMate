import 'package:billmate/domain/entities/accountTypeEnum.dart';
import 'package:billmate/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.email,
    required super.name,
    super.fixedIncome,
    required super.accountType,
    super.avatar,
    super.password,
    super.id, // Adicionado para suportar o campo id
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      fixedIncome: map['fixed_income'] != null
          ? double.tryParse(map['fixed_income'].toString())
          : null,
      accountType:
          AccountTypeEnum.fromString(map['account_type'] as String? ?? ''),
      avatar: map['avatar'] as String?,
      password: map['password'] as String?,
      id: map['id'] as int?, // Adicionado para suportar o campo id
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email ?? '',
      'name': name ?? '',
      'fixed_income': fixedIncome?.toString() ?? '',
      'account_type':
          accountType.value, // Usando o value para representar o tipo de conta
      'avatar': avatar ?? '',
      'password': password ?? '', // Incluído no mapeamento
      'id': id ?? 0, // Incluído no mapeamento
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    double? fixedIncome,
    AccountTypeEnum? accountType,
    String? avatar,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      fixedIncome: fixedIncome ?? this.fixedIncome,
      accountType: accountType ?? this.accountType,
      avatar: avatar ?? this.avatar,
      password: password ?? this.password,
    );
  }
}
