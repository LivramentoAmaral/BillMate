import 'dart:convert';
import 'dart:typed_data';
import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/group_model.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/group_details_service.dart';
import 'package:billmate/data/service/group_service.dart';
import 'package:billmate/data/service/user_service.dart';
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
  late GroupService _groupService;
  late UserService _userService;
  late Future<GroupModel> _groupFuture;
  late Future<List<UserModel>> _membersFuture;
  late Future<Uint8List> _qrCodeFuture;
  late Future<UserModel> _currentUserFuture;

  @override
  void initState() {
    super.initState();
    _groupDetailsService = GroupDetailsService(http.Client());
    _groupService = GroupService(http.Client());
    _userService = UserService(http.Client());
    _groupFuture = _groupService.getGroupById(widget.groupId);
    _membersFuture = _groupDetailsService.getMembers(widget.groupId);
    _qrCodeFuture = _generateQRCode();
    _currentUserFuture = _userService.getCurrentUser(); // Fetch current user
  }

  Future<Uint8List> _generateQRCode() async {
    try {
      final response =
          await _groupDetailsService.inviteByQRCode(widget.groupId);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final base64String = responseBody['qr_code'] as String?;
        if (base64String != null && base64String.isNotEmpty) {
          return base64Decode(base64String);
        } else {
          throw Exception('QR code string is empty');
        }
      } else {
        final responseBody =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final errorDetail = responseBody['detail'] ?? 'Unknown error';
        throw Exception(
            'Failed to generate QR code. Status code: ${response.statusCode}, Details: $errorDetail');
      }
    } catch (e) {
      throw Exception('Erro ao gerar QR Code: $e');
    }
  }

  Future<void> _confirmRemoveMember(UserModel user) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Deseja remover o membro?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('Tem certeza de que deseja remover ${user.name}?',
              style: const TextStyle(
                color: Colors.black,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _groupDetailsService.removeMember(widget.groupId, user.id);
        setState(() {
          _membersFuture = _groupDetailsService.getMembers(widget.groupId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name} removido com sucesso.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover membro: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteGroup() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Deseja apagar o grupo?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
              'Tem certeza de que deseja apagar este grupo? Esta ação não pode ser desfeita.',
              style: TextStyle(
                color: Colors.black,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _groupService.deleteGroup(widget.groupId);
        Navigator.of(context).pop(); // Voltar para a tela anterior
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo apagado com sucesso.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao apagar grupo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<GroupModel>(
          future: _groupFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Carregando...');
            } else if (snapshot.hasError) {
              return const Text('Erro ao carregar grupo');
            } else if (!snapshot.hasData) {
              return const Text('Grupo não encontrado');
            } else {
              final groupName = snapshot.data!.name ?? 'Sem nome';
              return Text(groupName);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code do Grupo
            FutureBuilder<Uint8List>(
              future: _qrCodeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Erro ao gerar QR Code'));
                } else {
                  final qrCodeImage = snapshot.data!;
                  return Column(
                    children: [
                      Center(
                        child: Image.memory(
                          qrCodeImage,
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Escaneie este QR Code para entrar no grupo',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
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
                  return FutureBuilder<UserModel>(
                    future: _currentUserFuture,
                    builder: (context, currentUserSnapshot) {
                      if (currentUserSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (currentUserSnapshot.hasError) {
                        return Center(
                            child: Text('Erro: ${currentUserSnapshot.error}'));
                      } else if (!currentUserSnapshot.hasData) {
                        return const Center(
                            child: Text('Usuário não encontrado'));
                      } else {
                        final currentUser = currentUserSnapshot.data!;
                        final groupOwnerId = members
                            .first.id; // Assume the first member is the owner
                        final isOwner = currentUser.id == groupOwnerId;

                        return Column(
                          children: [
                            Card(
                              color: AppThemes.darkTheme.colorScheme.surface,
                              child: ListTile(
                                leading: const Icon(Icons.star,
                                    color: Colors.orange),
                                title: Text(members.first.name ?? 'Sem nome',
                                    style: AppThemes
                                        .darkTheme.textTheme.bodySmall),
                                subtitle: Text(
                                    members.first.email ?? 'Sem email',
                                    style: AppThemes
                                        .darkTheme.textTheme.bodySmall),
                              ),
                            ),
                            ...members
                                .where((m) => m.id != groupOwnerId)
                                .map((user) {
                              return Card(
                                color: Theme.of(context).colorScheme.surface,
                                child: ListTile(
                                  leading: const Icon(Icons.person,
                                      color: Colors.blue),
                                  title: Text(user.name ?? 'Sem nome',
                                      style: AppThemes
                                          .darkTheme.textTheme.bodySmall),
                                  subtitle: Text(user.email ?? 'Sem email',
                                      style: AppThemes
                                          .darkTheme.textTheme.bodySmall),
                                  trailing: isOwner
                                      ? IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmRemoveMember(user),
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                            // Botão de Apagar Grupo (visível apenas para o criador do grupo)
                            Visibility(
                              visible: isOwner,
                              child: ElevatedButton(
                                onPressed: _confirmDeleteGroup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red, // Cor de fundo do botão
                                ),
                                child: const Text('Apagar Grupo'),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
