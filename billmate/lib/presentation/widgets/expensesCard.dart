import 'package:billmate/data/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseCard({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
    final String formattedDate = dateFormatter.format(expense.dateSpent as DateTime);

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: Icon(
          expense.isFixed ? Icons.attach_money : Icons.money_off,
          color: expense.isFixed ? Colors.green : Colors.red,
        ),
        title: Text(
          expense.description,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          NumberFormat.simpleCurrency().format(expense.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: double.parse(expense.amount) < 0 ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}
