// lib/data/services/api_service.dart

import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;

  ApiService(this.client);

  // ignore: unused_element
  Future<Map<String, String>> _getHeaders() async {
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzI1MTI3MzczLCJpYXQiOjE3MjUwNDA5NzMsImp0aSI6Ijg5ZGNiODk3MjMzNjQwNmNiMmQ4NzEyNGE1NTRlODg2IiwidXNlcl9pZCI6MTF9.oGcU_6rOb6NaE9_NCClaZAgGOrUx4pFKDMQoLywIK_4'; 
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }
}
