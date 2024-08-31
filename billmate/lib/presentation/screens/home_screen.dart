import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:billmate/presentation/widgets/buttonNavbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Corrigido para o caminho correto

class HomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
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
    _userService = UserService(Client()); // Certifique-se de que HttpClient está configurado corretamente
    _userFuture = _fetchCurrentUser();
  }

  Future<UserModel> _fetchCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return user;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Exception: Failed to load current user';
        });
      }
      throw Exception('Failed to load current user');
    }
  }

  Future<void> _logout() async {
    // Implementar a lógica de logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    // Navegar para a tela de login
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    // Se houver listeners, timers ou streams, cancele-os aqui.
    super.dispose();
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
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : FutureBuilder<UserModel>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red, fontSize: 16),
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
                              'Name: ${user.name}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Email: ${user.email}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Fixed Income: ${user.fixedIncome}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            // Adicione mais campos conforme necessário
                          ],
                        ),
                      );
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0, // Ajuste conforme necessário
        onItemTapped: (index) {
          // Lógica para navegação
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/balance');
              break;
            case 1:
              Navigator.pushNamed(context, '/groups');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
