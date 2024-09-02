import 'dart:convert';
import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final http.Client client;

  UserService(this.client);

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken =
        prefs.getString('access_token') ?? prefs.getString('refresh_token');
    '';

    print('Access token: $accessToken');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };
  }

  Future<List<UserModel>> getUsers() async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}users/'),
      headers: await _getHeaders(),
    );

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
        'Content-Type': 'application/json', // Adicione este cabeçalho
      },
      body: json.encode(user.toMap()),
    );

    print('Response status: ${response.body}');

    if (response.statusCode == 201) {
      print('User created successfully');
    } else {
      throw Exception('Failed to create user');
    }
  }
                                             
  Future<void> updateUser(int id, UserModel user) async {
    print('User: ${user.toMap()}');

    print('Id: $id');

    final response = await client.put(
      Uri.parse('${Config.baseUrl}users/$id/'),
      headers: await _getHeaders(),
      body: json.encode(user.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await client.delete(
      Uri.parse('${Config.baseUrl}users/$id/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  Future<UserModel> getCurrentUser() async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}users/me/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromMap(data);
    } else {
      throw Exception('Failed to load current user');
    }
  }
}
