import 'dart:convert';
import 'package:billmate/core/config.dart';
import 'package:billmate/data/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseService {
  final http.Client client;

  ExpenseService(this.client);

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

  // GET /api/expenses/
  Future<List<ExpenseModel>> getAllExpenses() async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}expenses/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ExpenseModel.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      print('Expense: ${expense.toMap()}');
      final response = await client.post(
        Uri.parse('${Config.baseUrl}groups/${expense.group}/add-expense/'),
        headers: await _getHeaders(),
        body: json.encode(expense.toMap()),
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return ExpenseModel.fromJson(response.body);
      } else {
        // Para uma mensagem de erro mais detalhada
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['detail'] ?? 'Erro desconhecido';
        throw Exception('Failed to create expense: $errorMessage');
      }
    } catch (e) {
      print('Error creating expense: $e');
      rethrow; // Re-throws the caught exception
    }
  }
  

  // GET /api/expenses/{id}/
  Future<ExpenseModel> getExpenseById(int id) async {
    final response = await client.get(
      Uri.parse('${Config.baseUrl}expenses/$id/'),
      headers: await _getHeaders(),
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return ExpenseModel.fromJson(response.body);
    } else {
      throw Exception('Expense not found');
    }
  }

  // PUT /api/expenses/{id}/
  Future<ExpenseModel> updateExpense(int id, ExpenseModel expense) async {
    final response = await client.put(
      Uri.parse('${Config.baseUrl}expenses/$id/'),
      headers: await _getHeaders(),
      body: json.encode(expense.toMap()),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return ExpenseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to update expense');
    }
  }

  // PATCH /api/expenses/{id}/
  Future<ExpenseModel> partialUpdateExpense(
      int id, Map<String, dynamic> updates) async {
    final response = await client.patch(
      Uri.parse('${Config.baseUrl}expenses/$id/'),
      headers: await _getHeaders(),
      body: json.encode(updates),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return ExpenseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to partially update expense');
    }
  }

  // DELETE /api/expenses/{id}/
  Future<void> deleteExpense(int id) async {
    final response = await client.delete(
      Uri.parse('${Config.baseUrl}expenses/$id/'),
      headers: await _getHeaders(),
    );

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 204) {
      // Success: expense deleted
      return;
    } else {
      throw Exception(
          'Failed to delete expense. Status code: ${response.statusCode}');
    }
  }
}
