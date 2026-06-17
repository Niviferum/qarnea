import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';

class AuthService {
  // localhost fonctionne via tunnel ADB (USB).
  // Si le tunnel est coupé, on retente sur l'IP LAN du PC de dev.
  static const _urls = [
    'http://localhost:3001',
    'http://10.20.132.237:3001',
  ];

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    dynamic lastError;
    for (final base in _urls) {
      try {
        final response = await http
            .post(
              Uri.parse('$base$path'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 4));
        return response;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError;
  }
  static const _storage = FlutterSecureStorage();

  // ── Login ────────────────────────────────────────────────────────────────

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _post('/auth/login', {'email': email, 'password': password});

    if (response.statusCode == 200) {
      final tokens = AuthTokens.fromJson(jsonDecode(response.body));
      await _saveTokens(tokens);
      return tokens;
    } else if (response.statusCode == 401) {
      throw AuthException('Identifiants invalides');
    } else {
      throw AuthException('Erreur serveur (${response.statusCode})');
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────

  Future<AuthTokens> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? telephone,
  }) async {
    final body = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
    };

    final response = await _post('/auth/register', body);

    if (response.statusCode == 201) {
      final tokens = AuthTokens.fromJson(jsonDecode(response.body));
      await _saveTokens(tokens);
      return tokens;
    } else if (response.statusCode == 409) {
      throw AuthException('Cet e-mail est déjà utilisé');
    } else {
      throw AuthException('Erreur serveur (${response.statusCode})');
    }
  }

  // ── Token storage ─────────────────────────────────────────────────────────

  Future<void> _saveTokens(AuthTokens tokens) async {
    await _storage.write(key: 'access_token', value: tokens.accessToken);
    await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
