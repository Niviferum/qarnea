import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/alternative_locale.dart';
import '../models/scan_result.dart';

class ScanService {
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
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError;
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    dynamic lastError;
    for (final base in _urls) {
      try {
        return await http
            .post(
              Uri.parse('$base$path'),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError;
  }

  Future<ScanResult> scanProduct(String codeBarre) async {
    final response = await _post('/scan', {'code_barre': codeBarre});

    switch (response.statusCode) {
      case 201:
        return ScanResult.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      case 404:
        throw ScanException('Produit introuvable sur Open Food Facts');
      case 401:
        throw ScanException('Session expirée, reconnectez-vous');
      default:
        throw ScanException('Erreur serveur (${response.statusCode})');
    }
  }

  Future<List<AlternativeLocale>> getAlternatives(String idScan) async {
    final response = await _get('/scan/$idScan/alternatives');

    switch (response.statusCode) {
      case 200:
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => AlternativeLocale.fromJson(e as Map<String, dynamic>))
            .toList();
      case 404:
        throw ScanException('Scan introuvable');
      case 401:
        throw ScanException('Session expirée, reconnectez-vous');
      default:
        throw ScanException('Erreur serveur (${response.statusCode})');
    }
  }
}

class ScanException implements Exception {
  final String message;
  ScanException(this.message);

  @override
  String toString() => message;
}
