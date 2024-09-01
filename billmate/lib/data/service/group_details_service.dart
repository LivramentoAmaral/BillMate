import 'dart:convert';
import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupDetailsService {
  final http.Client client;

  GroupDetailsService(this.client);

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';

    if (accessToken.isEmpty) {
      throw Exception('No access token found');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<List<UserModel>> getMembersById(int groupId) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$groupId/members/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final membersData = json.decode(response.body) as List;
      print('Members data: $membersData');
      return membersData.map((data) => UserModel.fromMap(data)).toList();
    } else {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to load members: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<void> addExpense(int groupId, Map<String, dynamic> expenseData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/add-expense/'),
      headers: await _getHeaders(),
      body: json.encode(expenseData),
    );

    if (response.statusCode != 201) {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to add expense: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<void> addMember(int groupId, Map<String, dynamic> memberData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/add-member/'),
      headers: await _getHeaders(),
      body: json.encode(memberData),
    );

    if (response.statusCode != 201) {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to add member: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<List<Map<String, dynamic>>> getExpenses(int groupId) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$groupId/expenses/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to load expenses: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<Map<String, dynamic>> getFinancialSummary(int groupId) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$groupId/financial-summary/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to load financial summary: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<void> inviteByEmail(
      int groupId, Map<String, dynamic> inviteData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/invite-email/'),
      headers: await _getHeaders(),
      body: json.encode(inviteData),
    );

    if (response.statusCode != 201) {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to send email invite: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<void> inviteByQRCode(
      int groupId, Map<String, dynamic> inviteData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/invite-qrcode/'),
      headers: await _getHeaders(),
      body: json.encode(inviteData),
    );

    if (response.statusCode != 201) {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to send QR code invite: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<void> joinGroup(int groupId, Map<String, dynamic> joinData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/join/'),
      headers: await _getHeaders(),
      body: json.encode(joinData),
    );

    if (response.statusCode != 201) {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to join group: ${responseBody['detail'] ?? 'Unknown error'}');
    }
  }

  Future<List<UserModel>> getMembers(int groupId) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$groupId/members/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> membersData = json.decode(response.body);

      // Lista para armazenar os objetos UserModel
      List<UserModel> members = [];

      // Loop para buscar detalhes de cada usuário
      for (var member in membersData) {
        final userId = member['user'];
        final userDetailsResponse = await client.get(
          Uri.parse('${Config.baseUrl}users/$userId/'),
          headers: await _getHeaders(),
        );

        if (userDetailsResponse.statusCode == 200) {
          final userData = json.decode(userDetailsResponse.body);
          members.add(UserModel.fromMap(userData));
        }
      }

      return members;
    } else {
      throw Exception('Failed to load group members');
    }
  }

  Future<void> removeMember(int groupId, int userId) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/remove-member/'),
      headers: await _getHeaders(),
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode != 204) {
      final responseBody =
          response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(
          'Failed to remove member: ${responseBody['detail'] ?? 'Unknown error'}');
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
