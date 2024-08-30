import 'dart:convert';
import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/group_model.dart';
import 'package:http/http.dart' as http;

class GroupService {
  final http.Client client;

  GroupService(this.client);

  Future<Map<String, String>> _getHeaders() async {
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzI1MTI4OTA5LCJpYXQiOjE3MjUwNDI1MDksImp0aSI6IjlkZmQ1NWE4YmQ3NTQyYjlhMzFhY2Q1ZTNiYzc5NzRlIiwidXNlcl9pZCI6MTF9.s8UESb6VZYCV36IK2UCPWvBJz9OruOAAm5vk-7g1p8o';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<GroupModel>> getGroups() async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => GroupModel.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load groups');
    }
  }

  Future<GroupModel> getGroupById(int id) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}groups/$id/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return GroupModel.fromMap(data);
    } else {
      throw Exception('Failed to load group');
    }
  }

  Future<void> createGroup(GroupModel group) async {
    final response = await client.post(
      Uri.parse('${Config.baseUrl}groups/'),
      headers: await _getHeaders(),
      body: json.encode(group.toMap()),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode != 201) {
      throw Exception('Failed to create group');
    }
  }

  Future<void> updateGroup(int id, GroupModel group) async {
    final response = await client.put(
      Uri.parse('${Config.baseUrl}groups/$id/'),
      headers: await _getHeaders(),
      body: json.encode(group.toMap()),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update group');
    }
  }

  Future<void> deleteGroup(int id) async {
    final response = await client.delete(
      Uri.parse('${Config.baseUrl}groups/$id/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete group');
    }
  }
}
