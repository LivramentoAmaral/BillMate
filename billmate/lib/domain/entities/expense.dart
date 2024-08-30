import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int id;
  final String amount;
  final String description;
  final String dateSpent;
  final int group;
  final bool isFixed;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.dateSpent,
    required this.group,
    required this.isFixed,
  });

  @override
  List<Object?> get props => [id, amount, description, dateSpent, group, isFixed];

  @override
  bool? get stringify => true;
}
