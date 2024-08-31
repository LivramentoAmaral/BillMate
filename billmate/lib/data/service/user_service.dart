import 'dart:convert';
import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/user_model.dart'; // Atualize para o caminho correto do seu modelo
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final http.Client client;

  UserService(this.client);

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<List<UserModel>> getUsers() async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}users/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => UserModel.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<UserModel> getUserById(int id) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}users/$id/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromMap(data);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> createUser(UserModel user) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}users/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(user.toMap()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Usuário criado com sucesso: ${response.body}');
    } else {
      throw Exception(
          'Falha ao criar o usuário já existe um usuário com o mesmo e-mail');
    }
  }

  Future<void> updateUser(int id, UserModel user) async {
    final response = await client.put(
      Uri.parse('${Config.baseUrl}users/$id/'),
      headers: await _getHeaders(),
      body: json.encode(user.toMap()),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await client.delete(
      Uri.parse('${Config.baseUrl}users/$id/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  Future<UserModel> getCurrentUser() async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}users/me/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromMap(data);
    } else {
      throw Exception('Failed to load current user');
    }
  }
}
