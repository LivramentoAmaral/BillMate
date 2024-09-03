import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/expense_model.dart';
import 'package:billmate/data/models/group_model.dart';
import 'package:billmate/data/service/group_service.dart';
import 'package:billmate/data/service/expense_service.dart'; // Importe o serviço de despesas
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpenseForm extends StatefulWidget {
  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedGroup;
  bool _isFixed = false;
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final groupService = GroupService(http.Client());
      final groups = await groupService.getGroups();
      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Erro ao carregar grupos. Tente novamente mais tarde.';
          _isLoading = false;
        });
      }
      print('Erro ao carregar grupos: $e');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Debug: Verifique o valor de _selectedDate
      print('Selected date: $_selectedDate');

      final expense = ExpenseModel(
        id: 0,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        description: _descriptionController.text,
        dateSpent: _selectedDate ??
            DateTime
                .now(), // Garantia de que sempre haverá um valor para dateSpent
        group: _selectedGroup ?? 0,
        isFixed: _isFixed,
      );

      // Debug: Verifique o corpo da requisição
      print('Expense to send: ${expense.toMap()}');

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      try {
        final expenseService = ExpenseService(
            http.Client()); // Crie uma instância do serviço de despesas
        final createdExpense = await expenseService.createExpense(expense);

        if (mounted) {
          setState(() {
            _successMessage = 'Despesa adicionada com sucesso!';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Erro ao adicionar despesa. Tente novamente mais tarde.';
            _isLoading = false;
          });
        }
        print('Erro ao adicionar despesa: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading) Center(child: CircularProgressIndicator()),
                if (_successMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: TextStyle(
                          color: AppThemes.darkTheme.colorScheme.primary)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Descrição é obrigatória';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                      labelText: 'Valor',
                      labelStyle: TextStyle(
                          color: AppThemes.darkTheme.colorScheme.primary)),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Valor é obrigatório';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Digite um valor válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Data da despesa:',
                  style: TextStyle(
                      color: AppThemes.darkTheme.colorScheme.secondary),
                ),
                ListTile(
                  title: Text(
                    style: TextStyle(
                        color: AppThemes.darkTheme.colorScheme.secondary),
                    _selectedDate != null
                        ? _selectedDate!.toLocal().toString().split(' ')[0]
                        : 'Selecionar data',
                  ),
                  trailing: Icon(Icons.calendar_today,
                      color: AppThemes.darkTheme.colorScheme.primary),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                        // Debug: Verifique o valor de _selectedDate após a seleção
                        print('Date selected: $_selectedDate');
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedGroup,
                  decoration: InputDecoration(labelText: 'Selecione um grupo'),
                  items: _groups.map((group) {
                    return DropdownMenuItem<int>(
                      value: group.id,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGroup = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione um grupo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isFixed,
                      onChanged: (value) {
                        setState(() {
                          _isFixed = value ?? false;
                        });
                      },
                    ),
                    Text('Despesa fixa'),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
