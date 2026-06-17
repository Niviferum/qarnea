import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/producer_form_data.dart';

class ProducteurService {
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

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _authHeaders();
    dynamic lastError;

    for (final base in _urls) {
      try {
        final uri = Uri.parse('$base$path');
        final http.Response response;

        if (method == 'GET') {
          response = await http.get(uri, headers: headers)
              .timeout(const Duration(seconds: 4));
        } else {
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(const Duration(seconds: 4));
        }
        return response;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError;
  }

  Future<void> soumettre(ProducerFormData data) async {
    final response = await _request('POST', '/producteurs', body: data.toJson());

    if (response.statusCode == 201) return;
    if (response.statusCode == 409) {
      throw ProducteurException('Une fiche producteur existe déjà pour ce compte');
    }
    throw ProducteurException('Erreur serveur (${response.statusCode})');
  }

  // Retourne null si l'utilisateur n'est pas producteur
  Future<Map<String, dynamic>?> getMonProfil() async {
    final response = await _request('GET', '/producteurs/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}

class ProducteurException implements Exception {
  final String message;
  ProducteurException(this.message);

  @override
  String toString() => message;
}
