import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/group_details_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroupDetailsPage extends StatefulWidget {
  final int groupId;

  const GroupDetailsPage({required this.groupId, Key? key}) : super(key: key);

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late GroupDetailsService _groupDetailsService;
  late Future<List<UserModel>> _membersFuture;
  late Future<UserModel> _currentUserFuture;

  @override
  void initState() {
    super.initState();
    _groupDetailsService = GroupDetailsService(http.Client());
    _membersFuture = _groupDetailsService.getMembers(widget.groupId);
    _currentUserFuture = _groupDetailsService.getCurrentUser();
  }

  void _deleteGroup() {
    // Implementar a função de apagar grupo aqui.
    // Mostrar um diálogo de confirmação antes de deletar.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Grupo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code do Grupo (substitua pelo widget de QR Code que você deseja usar)
            Center(
              child: Container(
                width: 150,
                height: 150,
                color: const Color.fromARGB(
                    255, 67, 67, 67), // Placeholder para o QR Code
                child: Center(child: Text('QR Code')),
              ),
            ),
            const SizedBox(height: 16),
            // Exibição do usuário atual

            const SizedBox(height: 16),
            // Lista de Membros
            FutureBuilder<List<UserModel>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum membro encontrado'));
                } else {
                  final members = snapshot.data!;
                  final owner = members
                      .first; // Considera o primeiro membro como proprietário

                  return Column(
                    children: [
                      Card(
                        color: AppThemes.darkTheme.colorScheme.surface,
                        child: ListTile(
                          leading: const Icon(Icons.star, color: Colors.orange),
                          title: Text(owner.name ?? 'Sem nome',
                              style: AppThemes.darkTheme.textTheme.bodySmall),
                          subtitle: Text(owner.email ?? 'Sem email',
                              style: AppThemes.darkTheme.textTheme.bodySmall),
                        ),
                      ),
                      ...members.where((m) => m.id != owner.id).map((user) {
                        return Card(
                          color: Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.blue),
                            title: Text(user.name ?? 'Sem nome',
                                style: AppThemes.darkTheme.textTheme.bodySmall),
                            subtitle: Text(user.email ?? 'Sem email',
                                style: AppThemes.darkTheme.textTheme.bodySmall),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // Botão de Apagar Grupo
            Center(
              child: ElevatedButton(
                onPressed: _deleteGroup,
                child: const Text('Apagar Grupo'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
