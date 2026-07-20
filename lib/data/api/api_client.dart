import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/env.dart';
import '../services/auth_store.dart';

/// Excepción de una respuesta HTTP no exitosa.
class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}

/// Cliente HTTP mínimo para la API de negocio.
/// Adjunta el token de Supabase (Bearer) en cada llamada.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Env.apiBaseUrl;
    final limpio =
        base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return Uri.parse('$limpio$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers {
    final token = authStore.accessToken;
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET que devuelve el JSON decodificado (List o Map).
  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? null : jsonDecode(res.body);
    }
    throw ApiException(res.statusCode, res.body);
  }

  /// PATCH con cuerpo JSON. Devuelve el JSON decodificado (o null si no hay).
  Future<dynamic> patchJson(String path, {Map<String, dynamic>? body}) async {
    final res = await http.patch(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: body == null ? null : jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? null : jsonDecode(res.body);
    }
    throw ApiException(res.statusCode, res.body);
  }
}

/// Instancia compartida.
final apiClient = ApiClient.instance;
