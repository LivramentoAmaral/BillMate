import 'dart:convert';
import 'package:billmate/core/config.dart';
import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupExpensesWidget extends StatefulWidget {
  final int groupId;

  GroupExpensesWidget({required this.groupId});

  @override
  _GroupExpensesWidgetState createState() => _GroupExpensesWidgetState();
}

class _GroupExpensesWidgetState extends State<GroupExpensesWidget> {
  late Future<List<ExpenseModel>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = _fetchExpenses();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ??
        prefs.getString('refresh_token') ??
        '';
    print('Access Token: $accessToken');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };
  }

  Future<List<ExpenseModel>> _fetchExpenses() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}groups/${widget.groupId}/expenses/'),
        headers: await _getHeaders(),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ExpenseModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load expenses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching expenses: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}expenses/$id/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 204) {
      setState(() {
        _expensesFuture = _fetchExpenses();
      });
    } else {
      throw Exception(
          'Failed to delete expense. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: FutureBuilder<List<ExpenseModel>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma despesa encontrada'));
          } else {
            final expenses = snapshot.data!;

            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          icon: Icon(Icons.delete_forever_outlined,
                              color: Colors.red),
                          onPressed: () async {
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: AppThemes
                                      .darkTheme.scaffoldBackgroundColor,
                                  title: Text(
                                    'Confirmar exclusão',
                                    style: TextStyle(
                                        color: AppThemes
                                            .darkTheme.colorScheme.primary),
                                  ),
                                  content: Text(
                                      'Você tem certeza que deseja excluir essa despesa?',
                                      style: TextStyle(
                                        color: AppThemes
                                            .darkTheme.colorScheme.secondary,
                                      )),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        'Excluir',
                                        style: TextStyle(
                                            color: AppThemes
                                                .darkTheme.colorScheme.error),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmDelete == true) {
                              try {
                                await deleteExpense(expense.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Despesa excluída com sucesso')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Erro ao excluir despesa: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
