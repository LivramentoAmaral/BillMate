import 'package:billmate/data/models/expense_model.dart';
import 'package:billmate/data/service/expense_service.dart';
import 'package:billmate/presentation/screens/expenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenseService = ExpenseService(http.Client());
      final expenses = await expenseService.getAllExpenses();
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erro ao carregar despesas. Tente novamente mais tarde.';
        _isLoading = false;
      });
      print('Erro ao carregar despesas: $e');
    }
  }

  void _openEditModal(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) {
        return EditExpenseModal(
          expense: expense,
          onSave: (updatedExpense) {
            setState(() {
              final index =
                  _expenses.indexWhere((e) => e.id == updatedExpense.id);
              if (index != -1) {
                _expenses[index] = updatedExpense;
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Despesas'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final expense = _expenses[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        title: Text(
                          expense.description,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          'Data: ${expense.dateSpent.split('T')[0]}',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'R\$ ${double.parse(expense.amount).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: double.parse(expense.amount) < 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () => _openEditModal(expense),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Adicionar Despesa',
      ),
    );
  }
}

class EditExpenseModal extends StatefulWidget {
  final ExpenseModel expense;
  final Function(ExpenseModel) onSave;

  EditExpenseModal({required this.expense, required this.onSave});

  @override
  _EditExpenseModalState createState() => _EditExpenseModalState();
}

class _EditExpenseModalState extends State<EditExpenseModal> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  bool _isFixed = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _selectedDate = DateTime.parse(widget.expense.dateSpent);
    _isFixed = widget.expense.isFixed;
  }

  void _saveExpense() {
    final updatedExpense = ExpenseModel(
      id: widget.expense.id,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      description: _descriptionController.text,
      dateSpent: _selectedDate,
      group: widget.expense.group,
      isFixed: _isFixed,
    );

    widget.onSave(updatedExpense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Despesa'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: Text(
                'Data: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            CheckboxListTile(
              title: Text('Despesa fixa'),
              value: _isFixed,
              onChanged: (value) {
                setState(() {
                  _isFixed = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          child: Text('Salvar'),
        ),
      ],
    );
  }
}
