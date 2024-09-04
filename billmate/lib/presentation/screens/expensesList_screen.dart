import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/expense_model.dart';
import 'package:billmate/data/service/expense_service.dart';
import 'package:billmate/presentation/screens/expenses_screen.dart';
import 'package:billmate/presentation/widgets/buttonNavbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

      if (expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nenhuma despesa encontrada')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erro ao carregar despesas. Tente novamente mais tarde.';
        _isLoading = false;
      });
      print('Erro ao carregar despesas: $e');
    }
  }

  Future<void> _deleteExpense(int id) async {
    try {
      final expenseService = ExpenseService(http.Client());
      await expenseService.deleteExpense(id);

      setState(() {
        _expenses.removeWhere((expense) => expense.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Despesa deletada com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar a despesa: ${e.toString()}')),
      );
    }
  }

  void _confirmDeleteExpense(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkTheme.scaffoldBackgroundColor,
          title: Text(
            'Confirmar Exclusão',
            style: TextStyle(color: AppThemes.darkTheme.colorScheme.primary),
          ),
          content: Text(
            'Você tem certeza que deseja excluir esta despesa?',
            style: TextStyle(color: AppThemes.darkTheme.colorScheme.secondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppThemes.darkTheme.colorScheme.error),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.darkTheme.colorScheme.primary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense(id);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkTheme.scaffoldBackgroundColor,
          title: Text('Confirmar logout',
              style: TextStyle(color: AppThemes.darkTheme.colorScheme.primary)),
          content: Text('Você tem certeza que deseja sair da sua conta?',
              style:
                  TextStyle(color: AppThemes.darkTheme.colorScheme.secondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar',
                  style:
                      TextStyle(color: AppThemes.darkTheme.colorScheme.error)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Sair',
                  style: TextStyle(
                      color: AppThemes.darkTheme.colorScheme.primary)),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
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
        title: Text('Lista de despesas'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
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
                      color: AppThemes.darkTheme.cardColor,
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
                            color: AppThemes.darkTheme.colorScheme.onPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Data: ${expense.dateSpent.split('T')[0]}',
                          style: TextStyle(
                            color: AppThemes.darkTheme.colorScheme.onSurface,
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
                                color: AppThemes.darkTheme.colorScheme.primary,
                              ),
                              onPressed: () => _openEditModal(expense),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_forever_outlined,
                                color: AppThemes.darkTheme.colorScheme.error,
                              ),
                              onPressed: () =>
                                  _confirmDeleteExpense(expense.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppThemes.darkTheme.colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Adicionar Despesa',
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onItemTapped: (index) {
          // Lógica para navegação
        },
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
  late ExpenseService _expenseService;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.expense.description);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _selectedDate = DateTime.parse(widget.expense.dateSpent);
    _isFixed = widget.expense.isFixed;
    _expenseService = ExpenseService(http.Client());
  }

  Future<void> _saveExpense() async {
    try {
      final updatedExpense = ExpenseModel(
        id: widget.expense.id,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        description: _descriptionController.text,
        dateSpent: _selectedDate,
        group: widget.expense.group,
        isFixed: _isFixed,
      );

      final savedExpense = await _expenseService.updateExpense(
          widget.expense.id, updatedExpense);

      widget.onSave(savedExpense);
      Navigator.of(context).pop();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar a despesa: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemes.darkTheme.scaffoldBackgroundColor,
      title: Text(
        'Editar Despesa',
        style: TextStyle(color: AppThemes.darkTheme.colorScheme.primary),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: AppThemes.darkTheme.colorScheme.primary),
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle:
                    TextStyle(color: AppThemes.darkTheme.colorScheme.primary),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _amountController,
              style: TextStyle(color: AppThemes.darkTheme.colorScheme.primary),
              decoration: InputDecoration(
                labelText: 'Valor',
                labelStyle:
                    TextStyle(color: AppThemes.darkTheme.colorScheme.primary),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text(
                'Data: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                style:
                    TextStyle(color: AppThemes.darkTheme.colorScheme.secondary),
              ),
              trailing: Icon(Icons.calendar_today,
                  color: AppThemes.darkTheme.colorScheme.primary),
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
              title: Text(
                'Despesa fixa',
                style:
                    TextStyle(color: AppThemes.darkTheme.colorScheme.secondary),
              ),
              value: _isFixed,
              onChanged: (value) {
                setState(() {
                  _isFixed = value ?? false;
                });
              },
              checkColor: AppThemes.darkTheme.colorScheme.primary,
              activeColor: AppThemes.darkTheme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AppThemes.darkTheme.colorScheme.error),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemes.darkTheme.colorScheme.primary,
          ),
          onPressed: _saveExpense,
          child: Text('Salvar'),
        ),
      ],
    );
  }
}
