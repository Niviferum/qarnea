import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UtilisateurService {
  static const _urls = [
    'http://localhost:3001',
    'http://10.20.132.237:3001',
  ];

  final _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _get(String path) async {
    final headers = await _authHeaders();
    dynamic lastError;

    for (final base in _urls) {
      try {
        return await http
            .get(Uri.parse('$base$path'), headers: headers)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError;
  }

  Future<Map<String, dynamic>> getMonProfil() async {
    final response = await _get('/utilisateurs/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Erreur serveur (${response.statusCode})');
  }
}
