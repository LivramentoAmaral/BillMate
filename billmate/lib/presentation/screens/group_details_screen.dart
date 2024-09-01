import 'dart:convert';
import 'dart:typed_data';
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
  late Future<Uint8List> _qrCodeFuture;

  @override
  void initState() {
    super.initState();
    _groupDetailsService = GroupDetailsService(http.Client());
    _membersFuture = _groupDetailsService.getMembers(widget.groupId);
    _qrCodeFuture = _generateQRCode();
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
                  return Center(
                    child: Image.memory(
                      qrCodeImage,
                      width: 150,
                      height: 150,
                    ),
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
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () async {
                                try {
                                  await _groupDetailsService.removeMember(
                                      widget.groupId, user.id);
                                  setState(() {
                                    _membersFuture = _groupDetailsService
                                        .getMembers(widget.groupId);
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Erro ao remover membro: $e')),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      // Botão de Apagar Grupo (visível apenas para o criador do grupo)
                    ],
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
