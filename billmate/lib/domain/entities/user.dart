import 'package:equatable/equatable.dart';

// ignore: constant_identifier_names
enum AccountTypeEnum { Simple, Prime, defaultValue }

class User extends Equatable  {
  final int id;
  final String email;
  final String name;
  final double? fixedIncome;
  final AccountTypeEnum accountType;
  final String? avatar;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.fixedIncome,
    required this.accountType,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, email, name, fixedIncome, accountType, avatar];

  @override
  bool? get stringify => true;
}


