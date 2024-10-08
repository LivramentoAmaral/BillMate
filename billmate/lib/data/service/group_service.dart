import 'dart:convert';
import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/group_details_model.dart';
import 'package:billmate/data/models/group_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupService {
  final http.Client client;

  GroupService(this.client);

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ??
        prefs.getString('refresh_token') ??
        '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
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

  Future<GroupDetailsModel> getGroupById(int groupId) async {
    print('Requesting group with id $groupId');

    final parsedGroupId = int.parse(groupId.toString());
    final response = await client.get(
        Uri.parse('${Config.baseUrl}groups/$parsedGroupId/'),
        headers: await _getHeaders());

    print(
        'Response body: ${response.body}'); // Adicione esta linha para verificar a resposta

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return GroupDetailsModel.fromMap(data);
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
    try {
      final response = await client.delete(
        Uri.parse('${Config.baseUrl}groups/$id/'),
        headers: await _getHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 204) {
        // Sucesso: grupo deletado
        return;
      } else {
        // Se a resposta não tem body, mas tem status de erro
        throw Exception(
            'Failed to delete group. Status code: ${response.statusCode}. No response body.');
      }
    } catch (e) {
      print('Erro ao tentar deletar o grupo: $e');
      throw Exception('Failed to delete group: $e');
    }
  }
}
