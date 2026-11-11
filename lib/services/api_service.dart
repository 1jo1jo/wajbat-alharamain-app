import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://haramain-backend.onrender.com';

  static String? token;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // GET
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // POST
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // PUT
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // DELETE
  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Response Handler
  static dynamic _handleResponse(http.Response response) {
    final body = response.body;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (body.isEmpty) return null;

      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }

    throw Exception(
      'HTTP ${response.statusCode}: $body',
    );
  }
}