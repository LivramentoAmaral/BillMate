import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:billmate/data/service/expense_service.dart'; // Importa o ExpenseService
import 'package:billmate/domain/entities/accountTypeEnum.dart';
import 'package:billmate/presentation/widgets/buttonNavbar.dart'; // Ajuste o import conforme a estrutura do seu projeto
import 'package:billmate/presentation/widgets/fixedModal.dart';
import 'package:billmate/presentation/widgets/graficExpense.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserModel> _userFuture;
  late UserService _userService;
  late ExpenseService _expenseService; // Adiciona o ExpenseService
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userService = UserService(http.Client());
    _expenseService =
        ExpenseService(http.Client()); // Inicializa o ExpenseService
    _userFuture = _checkAndFetchCurrentUser();
  }

  Future<UserModel> _checkAndFetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty || accessToken == '') {
      Navigator.pushReplacementNamed(context, '/');
      return UserModel(
          email: '',
          name: '',
          accountType: AccountTypeEnum.Unknown); // Valor padrão
    }

    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      }
      return user;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Falha ao carregar o usuário: ${e.toString()}';
        });
      }
    }

    throw Exception('Failed to fetch current user.');
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

  void _showFixedIncomeModal(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => FixedIncomeModal(
        user: user,
        onUpdate: (updatedUser) {
          setState(() {
            _userFuture = Future.value(updatedUser);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balancço'),
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
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.red),
                  ),
                )
              : FutureBuilder<UserModel>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print('Erro na FutureBuilder: ${snapshot.error}');
                      return Center(
                        child: Text(
                          'Erro: ${snapshot.error}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final user = snapshot.data!;
                      final fixedIncome = user.fixedIncome;

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Nome: ${user.name}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Email: ${user.email}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Renda Fixa: ${user.fixedIncome}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton.icon(
                              onPressed: () => _showFixedIncomeModal(user),
                              icon: Icon(Icons.edit),
                              label: Text('Editar Renda Fixa'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Expanded(
                              child: ExpensesChart(
                                expenseService: _expenseService,
                                fixedIncome: fixedIncome!,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: Text('Nenhum dado disponível'));
                    }
                  },
                ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/groups');
              break;
            case 2:
              Navigator.pushNamed(context, '/listexpenses');
              break;
          }
        },
      ),
    );
  }
}
