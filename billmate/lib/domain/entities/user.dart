import 'package:billmate/domain/entities/accountTypeEnum.dart';
import 'package:equatable/equatable.dart';

// Define a classe User
class User extends Equatable {
  final int? id;
  final String email;
  final String name;
  final String? password;
  final double? fixedIncome;
  final AccountTypeEnum accountType;
  final String? avatar;

  const User({
    this.id,
    required this.email,
    required this.name,
    this.password,
    this.fixedIncome,
    required this.accountType,
    this.avatar,
  });

  @override
  List<Object?> get props =>
      [id, email, name, password, fixedIncome, accountType, avatar];

  @override
  bool? get stringify => true;

  toMap() {}
}
