import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/operateur_map.dart';
import '../config.dart';

class CarteService {
  static const _urls = [kApiBaseUrl];

  final _authService = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<OperateurMap>> getOperateursMap() async {
    final headers = await _authHeaders();
    dynamic lastError;

    for (final base in _urls) {
      try {
        final response = await http
            .get(Uri.parse('$base/agence-bio/operateurs/map'), headers: headers)
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return list
              .map((e) => OperateurMap.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Erreur serveur (${response.statusCode})');
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError;
  }
}
