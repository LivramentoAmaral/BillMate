import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:billmate/presentation/widgets/buttonNavbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixedIncomeModal extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onUpdate;

  FixedIncomeModal({required this.user, required this.onUpdate});

  @override
  _FixedIncomeModalState createState() => _FixedIncomeModalState();
}

class _FixedIncomeModalState extends State<FixedIncomeModal> {
  late TextEditingController _fixedIncomeController;
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _fixedIncomeController =
        TextEditingController(text: widget.user.fixedIncome.toString());
    _userService = UserService(Client());
  }

  @override
  void dispose() {
    _fixedIncomeController.dispose();
    super.dispose();
  }

  Future<void> _updateFixedIncome() async {
    try {
      final updatedUser = widget.user.copyWith(
        fixedIncome: double.parse(_fixedIncomeController.text),
      );
      await _userService.updateUser(updatedUser.id!, updatedUser);
      widget.onUpdate(updatedUser);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Atualização realizada com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar o valor da renda fixa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemes.darkTheme.scaffoldBackgroundColor,
      title: Text('Editar Renda Fixa'),
      content: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _fixedIncomeController,
              decoration: InputDecoration(
                labelText: 'Renda Fixa',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateFixedIncome,
              child: Text('Atualizar'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

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
    _userService = UserService(Client());
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
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
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
                              'Name: ${user.name}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Email: ${user.email}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Fixed Income: ${user.fixedIncome}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () => _showFixedIncomeModal(user),
                              child: Text('Edit Fixed Income'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onItemTapped: (index) {
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
