import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/user_model.dart';

class QRCodeScanner extends StatefulWidget {
  final Function(int) onQRCodeScanned;

  QRCodeScanner({required this.onQRCodeScanned, Key? key}) : super(key: key);

  @override
  _QRCodeScannerState createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  final GlobalKey<State<StatefulWidget>> _qrKey =
      GlobalKey<State<StatefulWidget>>();

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
    print("Iniciando adição de membro ao grupo");

    print("Group ID: $groupId");
    print('User ID: $userId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';

      if (accessToken.isEmpty) {
        throw Exception('No access token found');
      }

      final memberData = {
        'user': userId
      }; // Certifique-se de que isso está correto

      print('Dados do membro: $memberData');

      final response = await http.post(
        Uri.parse('${Config.baseUrl}groups/$groupId/add-member/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(memberData),
      );

      print('Resposta da API - Status: ${response.statusCode}');
      print('Resposta da API - Corpo: ${response.body}');

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
      print('Erro no bloco try: $e');
      throw Exception('Falha ao adicionar membro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
      ),
      body: QRView(
        key: _qrKey,
        onQRViewCreated: (QRViewController controller) {
          controller.scannedDataStream.listen((scanData) async {
            final qrCode = scanData.code!;
            print("QR Code captured: $qrCode");

            try {
              // Corrigido para manipular o JSON corretamente
              final jsonString = qrCode.replaceAll("'", '"');
              final decodedData = json.decode(jsonString);
              print("Decoded JSON: $decodedData");

              if (decodedData is Map<String, dynamic> &&
                  decodedData.containsKey('group_id')) {
                final groupId = decodedData['group_id'];

                if (groupId is int) {
                  print("Group ID: $groupId");

                  final userId = await _getCurrentUserId();
                  print("User ID: $userId");

                  await _addMember(groupId, userId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Membro adicionado com sucesso')),
                  );

                  Navigator.of(context).pop();
                } else {
                  throw FormatException('O campo "group_id" não é um inteiro.');
                }
              } else {
                throw FormatException(
                    'QR Code JSON não contém o campo "group_id" ou está em um formato inválido.');
              }
            } catch (e) {
              print("Erro no bloco try: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao adicionar membro: $e')),
              );
            }
          });
        },
      ),
    );
  }
}
