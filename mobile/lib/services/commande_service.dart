import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/tarification.dart';
import '../config.dart';

class CommandeService {
  static const _urls = [kApiBaseUrl];

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

  Future<Tarification> getTarification(double prixProducteur) async {
    final prix = prixProducteur.toStringAsFixed(2);
    final response = await _get('/commandes/tarification?prix=$prix');

    if (response.statusCode == 200) {
      return Tarification.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw CommandeException('Impossible de calculer la tarification (${response.statusCode})');
  }

  Future<String> creerPaiement({
    required double prixProducteur,
    required String description,
    required String idProducteur,
  }) async {
    final response = await _post('/commandes/paiement', {
      'prix_producteur': prixProducteur,
      'description': description,
      'id_producteur': idProducteur,
    });

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['client_secret'] as String;
    }
    throw CommandeException('Erreur lors de la création du paiement (${response.statusCode})');
  }
}

class CommandeException implements Exception {
  final String message;
  CommandeException(this.message);

  @override
  String toString() => message;
}
