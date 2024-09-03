import 'dart:convert';

import 'package:billmate/core/config.dart';
import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/group_model.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/group_service.dart';
import 'package:billmate/presentation/widgets/buttonNavbar.dart';
import 'package:billmate/presentation/widgets/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserGroupsPage extends StatefulWidget {
  const UserGroupsPage({super.key});

  @override
  _UserGroupsPageState createState() => _UserGroupsPageState();
}

class _UserGroupsPageState extends State<UserGroupsPage> {
  late Future<List<GroupModel>> _groupsFuture;
  late GroupService _groupService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _groupService = GroupService(http.Client());
    _groupsFuture = _fetchGroups();
  }

  Future<List<GroupModel>> _fetchGroups() async {
    try {
      final groups = await _groupService.getGroups();
      setState(() {
        _isLoading = false;
      });
      return groups;
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      rethrow;
    }
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
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _createGroup() async {
    showDialog(
      context: context,
      builder: (context) {
        return CreateGroupDialog(onCreate: (name) async {
          try {
            await _groupService
                .createGroup(GroupModel(name: name, id: 0, owner: 0));
            setState(() {
              _groupsFuture = _fetchGroups();
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create group: $e')),
            );
          }
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        });
      },
    );
  }

  void _openQRCodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScanner(
          onQRCodeScanned: (groupId) async {
            try {
              final userId = await _getCurrentUserId();
              await _addMember(groupId, userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membro adicionado com sucesso')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao adicionar membro: $e')),
              );
            }
          },
        ),
      ),
    );
  }

  Future<int> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';

      if (accessToken.isEmpty) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}users/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromMap(data);
        return user.id!;
      } else {
        throw Exception('Failed to load current user');
      }
    } catch (e) {
      throw Exception('Failed to get user ID: $e');
    }
  }

  Future<void> _addMember(int groupId, int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';

      if (accessToken.isEmpty) {
        throw Exception('No access token found');
      }

      final memberData = {'user': userId};

      final response = await http.post(
        Uri.parse('${Config.baseUrl}groups/$groupId/add-member/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(memberData),
      );

      if (response.statusCode == 404) {
        throw Exception(
            'Não foi possível encontrar o grupo com o ID $groupId.');
      }

      if (response.statusCode != 201) {
        final responseBody =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        throw Exception(
            'Falha ao adicionar membro: ${responseBody['detail'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      throw Exception('Falha ao adicionar membro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Groups'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : FutureBuilder<List<GroupModel>>(
                  future: _groupsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final groups = snapshot.data!;
                      return ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Card(
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: ListTile(
                              title: Text(
                                group.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/groupdetails',
                                arguments: group,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No groups available'));
                    }
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Escolha uma Ação'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Adicionar Grupo'),
                    onTap: () {
                      Navigator.of(context).pop(); // Fechar o dialog
                      _createGroup();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Escanear QR Code'),
                    onTap: () {
                      Navigator.of(context).pop(); // Fechar o dialog
                      _openQRCodeScanner();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.menu),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          // Lógica para navegação
        },
      ),
    );
  }
}

class CreateGroupDialog extends StatefulWidget {
  final Function(String) onCreate;

  const CreateGroupDialog({super.key, required this.onCreate});

  @override
  _CreateGroupDialogState createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text(
        'Adicionar Grupo',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Nome do grupo',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            if (name.isNotEmpty) {
              widget.onCreate(name);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grupo deve ter um nome')),
              );
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
