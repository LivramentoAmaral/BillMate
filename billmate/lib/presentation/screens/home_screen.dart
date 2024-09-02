import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:billmate/domain/entities/accountTypeEnum.dart';
import 'package:billmate/presentation/widgets/fixedModal.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billmate/presentation/widgets/buttonNavbar.dart'; // Adjust the import according to your project structure

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserModel> _userFuture;
  late UserService _userService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userService = UserService(http.Client());
    _userFuture = _checkAndFetchCurrentUser();
  }

  Future<UserModel> _checkAndFetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null || accessToken.isEmpty || accessToken == '') {
      // No access token found, redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      return const UserModel(
          email: '',
          name: '',
          accountType: AccountTypeEnum
              .Unknown); // Replace 'AccountTypeEnum.none' with the appropriate value.
    }

    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null; // Clear any previous error messages
        });
      }
      return user;
    } catch (e) {
      print('Erro ao buscar usuário: $e'); // Adicionando print para depuração
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Falha ao carregar o usuário: ${e.toString()}'; // Mensagem de erro detalhada
        });
      }
    }

    throw Exception(
        'Failed to fetch current user.'); // Add a throw statement at the end to ensure a non-null value is always returned
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
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
        title: Text('Home Page'),
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
                      print(
                          'Erro na FutureBuilder: ${snapshot.error}'); // Adicionando print para depuração
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
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Nome: ${user.name}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Email: ${user.email}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Renda Fixa: ${user.fixedIncome}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () => _showFixedIncomeModal(user),
                              child: Text('Editar Renda Fixa'),
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
              Navigator.pushNamed(context, '/');
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
