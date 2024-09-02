import 'package:billmate/presentation/widgets/form/expenseForm.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpenseForm(), // Use o formulário de despesa aqui
      ),
    );
  }
}
