import 'dart:convert';

import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class GroupDetailsService {
  final http.Client client;

  GroupDetailsService(this.client);

  Future<Map<String, String>> _getHeaders() async {
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzI1MTI4OTA5LCJpYXQiOjE3MjUwNDI1MDksImp0aSI6IjlkZmQ1NWE4YmQ3NTQyYjlhMzFhY2Q1ZTNiYzc5NzRlIiwidXNlcl9pZCI6MTF9.s8UESb6VZYCV36IK2UCPWvBJz9OruOAAm5vk-7g1p8o';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> addExpense(int groupId, Map<String, dynamic> expenseData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/add-expense/'),
      headers: await _getHeaders(),
      body: json.encode(expenseData),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 201) {
      throw Exception('Failed to add expense');
    }
  }

  Future<void> addMember(int groupId, Map<String, dynamic> memberData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/add-member/'),
      headers: await _getHeaders(),
      body: json.encode(memberData),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 201) {
      throw Exception('Failed to add member');
    }
  }

  Future<List<Map<String, dynamic>>> getExpenses(int groupId) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$groupId/expenses/'),
      headers: await _getHeaders(),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<Map<String, dynamic>> getFinancialSummary(int groupId) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$groupId/financial-summary/'),
      headers: await _getHeaders(),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load financial summary');
    }
  }

  Future<void> inviteByEmail(int groupId, Map<String, dynamic> inviteData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/invite-email/'),
      headers: await _getHeaders(),
      body: json.encode(inviteData),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 201) {
      throw Exception('Failed to send email invite');
    }
  }

  Future<void> inviteByQRCode(int groupId, Map<String, dynamic> inviteData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/invite-qrcode/'),
      headers: await _getHeaders(),
      body: json.encode(inviteData),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 201) {
      throw Exception('Failed to send QR code invite');
    }
  }

  Future<void> joinGroup(int groupId, Map<String, dynamic> joinData) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/$groupId/join/'),
      headers: await _getHeaders(),
      body: json.encode(joinData),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 201) {
      throw Exception('Failed to join group');
    }
  }

  Future<List<UserModel>> getMembers(int groupId) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$groupId/members/'),
      headers: await _getHeaders(),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => UserModel.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load group members');
    }
  }

  Future<void> removeMember(int groupId, int userId) async {
    final response = await client.delete(
      Uri.parse('${Config.baseUrl}groups/$groupId/remove-member/'),
      headers: await _getHeaders(),
      body: json.encode({'user_id': userId}),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 204) {
      throw Exception('Failed to remove member');
    }
  }
}
