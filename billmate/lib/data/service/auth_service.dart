import 'dart:convert';
import 'dart:io';

import 'package:billmate/core/config.dart';

class AuthService {
  final HttpClient client;

  AuthService(this.client);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('${Config.baseUrl}token/');
    final HttpClientRequest request = await client.postUrl(url);

    // Adiciona headers
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

    // Adiciona body
    final Map<String, String> body = {
      'email': email,
      'password': password,
    };
    request.add(utf8.encode(json.encode(body)));

    // Envia a requisição
    final HttpClientResponse response = await request.close();

    // Lê a resposta
    final String responseBody = await response.transform(utf8.decoder).join();
    final Map<String, dynamic> parsedResponse = json.decode(responseBody);

    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode == 200) {
      return parsedResponse;
    } else {
      throw Exception(
          'Failed to login: ${parsedResponse['detail'] ?? 'Unknown error'}');
    }
  }
}
