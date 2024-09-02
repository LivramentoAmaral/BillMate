// lib/data/services/api_service.dart

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client client;

  ApiService(this.client);

  // ignore: unused_element
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ??
        prefs.getString('refresh_token') ??
        '';

    if (accessToken.isEmpty) {
      throw Exception('No access token found');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }
}
