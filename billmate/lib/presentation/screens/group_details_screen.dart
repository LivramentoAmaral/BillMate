import 'dart:convert';
import 'dart:typed_data';
import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/models/group_details_model.dart';
import 'package:billmate/data/models/group_model.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:billmate/data/service/group_details_service.dart';
import 'package:billmate/data/service/group_service.dart';
import 'package:billmate/data/service/user_service.dart';
import 'package:flutter/foundation.dart';
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
  late Future<GroupDetailsModel> _groupFuture;
  late Future<UserModel> _currentUserFuture;
  UserModel? _currentUser;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _groupDetailsService = GroupDetailsService(http.Client());
    _groupService = GroupService(http.Client());
    _userService = UserService(http.Client());
    _groupFuture = _groupService.getGroupById(widget.groupId);
    _currentUserFuture = _userService.getCurrentUser(); // Fetch current user
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    try {
      final group = await _groupFuture;
      final currentUser = await _currentUserFuture;
      setState(() {
        _currentUser = currentUser;
        _isOwner = currentUser.id == group.owner;
      });
    } catch (e) {
      print('Erro ao verificar a propriedade: $e');
    }
  }

  Future<void> _confirmRemoveMember(UserModel user) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Deseja remover o membro?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text('Tem certeza de que deseja remover ${user.name}?',
              style: TextStyle(
                color: Colors.black,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _groupDetailsService.removeMember(widget.groupId, user.id);
        setState(() {
          _groupFuture = _groupService.getGroupById(widget.groupId)
              as Future<GroupDetailsModel>;
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
          title: Text(
            'Deseja apagar o grupo?',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
              'Tem certeza de que deseja apagar este grupo? Esta ação não pode ser desfeita.',
              style: TextStyle(
                color: Colors.black,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Apagar'),
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
          SnackBar(content: Text('Grupo apagado com sucesso.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao apagar grupo: $e')),
        );
      }
    }
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
          throw Exception('QR Code inválido');
        }
      } else {
        throw Exception('Falha ao gerar QR Code');
      }
    } catch (e) {
      print('Erro ao gerar QR Code: $e');
      rethrow; // Propaga a exceção para ser capturada no FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<GroupDetailsModel>(
          future: _groupFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Carregando...');
            } else if (snapshot.hasError) {
              return Text('Erro ao carregar grupo');
            } else if (snapshot.hasData && snapshot.data != null) {
              final groupName = snapshot.data?.name ?? 'Sem nome';
              return Text(groupName);
            } else {
              return Text('Grupo não encontrado');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code do Grupo
            FutureBuilder<Uint8List>(
              future: _generateQRCode(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
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
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Escaneie este QR Code para entrar no grupo',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('Erro ao gerar QR Code'));
                }
              },
            ),
            SizedBox(height: 16),
            // Lista de Membros
            FutureBuilder<GroupDetailsModel>(
              future: _groupFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  final group = snapshot.data!;
                  final members = group.members ?? [];
                  final ownerId = group.owner;

                  return Column(
                    children: [
                      if (members.isNotEmpty)
                        ...members.map((user) {
                          final isOwner = user.id == ownerId;

                          return Card(
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              leading: Icon(
                                isOwner ? Icons.star : Icons.person,
                                color: isOwner ? Colors.orange : Colors.blue,
                              ),
                              title: Text(user.name ?? 'Sem nome',
                                  style:
                                      AppThemes.darkTheme.textTheme.bodySmall),
                              subtitle: Text(user.email ?? 'Sem email',
                                  style:
                                      AppThemes.darkTheme.textTheme.bodySmall),
                              trailing: _isOwner && !isOwner
                                  ? IconButton(
                                      icon: Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () => _confirmRemoveMember(
                                          user as UserModel),
                                    )
                                  : null,
                            ),
                          );
                        }).toList()
                      else
                        Center(child: Text('Nenhum membro encontrado')),
                      SizedBox(height: 16),
                      // Botão de Apagar Grupo (visível apenas para o criador do grupo)
                      Visibility(
                        visible: _isOwner,
                        child: ElevatedButton(
                          onPressed: _confirmDeleteGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // Cor de fundo do botão
                          ),
                          child: Text('Apagar Grupo'),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('Nenhum membro encontrado'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Future<GroupDetailsModel>>(
        '_groupFuture', _groupFuture));
    properties.add(DiagnosticsProperty<Future<UserModel>>(
        '_currentUserFuture', _currentUserFuture));
  }
}
