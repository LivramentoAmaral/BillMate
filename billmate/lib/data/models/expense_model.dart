import 'dart:convert';
import 'package:billmate/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({
    required super.id,
    required double amount,
    required super.description,
    required DateTime dateSpent,
    required super.group,
    required super.isFixed,
  }) : super(
          amount: amount.toString(),
          dateSpent: _formatDate(dateSpent),
        );

  // Método para formatar a data no formato YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Factory method to create an ExpenseModel from a Map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int ?? 0,
      amount: double.tryParse(map['amount'] as String) ?? 0.0,
      description: map['description'] as String,
      dateSpent: DateTime.parse(map['date_spent'] as String),
      group: map['group'] as int,
      isFixed: map['is_fixed'] as bool,
    );
  }

  // Method to convert an ExpenseModel instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount.toString(),
      'description': description,
      'date_spent': _formatDate(DateTime.parse(dateSpent)), // Ajuste aqui
      'group': group,
      'is_fixed': isFixed,
    };
  }

  // Method to convert an ExpenseModel instance to JSON
  String toJson() => json.encode(toMap());

  // Factory method to create an ExpenseModel from JSON
  factory ExpenseModel.fromJson(String source) =>
      ExpenseModel.fromMap(json.decode(source));
}
