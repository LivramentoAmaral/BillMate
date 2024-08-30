
import 'package:billmate/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.amount,
    required super.description,
    required super.dateSpent,
    required super.group,
    required super.isFixed,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int? ?? 0,
      amount: map['amount'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dateSpent: map['date_spent'] as String? ?? '',
      group: map['group'] as int? ?? 0,
      isFixed: map['is_fixed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date_spent': dateSpent,
      'group': group,
      'is_fixed': isFixed,
    };
  }
}
