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

  const QRCodeScanner({required this.onQRCodeScanned, Key? key})
      : super(key: key);

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';

      if (accessToken.isEmpty) {
        throw Exception('No access token found');
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}groups/$groupId/join/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 409) {
        // Status 409 indica conflito, como membro já no grupo
        throw Exception('User is already a member of this group.');
      }

      if (response.statusCode == 404) {
        throw Exception('Group not found with ID $groupId.');
      }

      if (response.statusCode != 201) {
        final responseBody =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        throw Exception(
            'Failed to add member: ${responseBody['detail'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: QRView(
        key: _qrKey,
        onQRViewCreated: (QRViewController controller) {
          controller.scannedDataStream.listen((scanData) async {
            final qrCode = scanData.code!;
            try {
              final jsonString = qrCode.replaceAll("'", '"');
              final decodedData = json.decode(jsonString);

              if (decodedData is Map<String, dynamic> &&
                  decodedData.containsKey('group_id')) {
                final groupId = decodedData['group_id'];

                if (groupId is int) {
                  final userId = await _getCurrentUserId();
                  await _addMember(groupId, userId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Membro adicionado com sucesso!')),
                  );

                  Future.microtask(() => Navigator.of(context).pop());
                } else {
                  throw FormatException(
                      'The "group_id" field is not an integer.');
                }
              } else {
                throw FormatException(
                    'QR Code JSON does not contain "group_id" or is in an invalid format.');
              }
            } catch (e) {
              if (mounted) {
                String errorMessage;
                if (e
                    .toString()
                    .contains('User is already a member of this group.')) {
                  errorMessage = 'usuário já é membro deste grupo.';
                } else {
                  errorMessage = 'Você já é membro do grupo!';

                  Future.delayed(Duration(seconds: 3), () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              }
            }
          });
        },
      ),
    );
  }
}
