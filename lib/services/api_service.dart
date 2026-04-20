import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String url = 'https://luiscast.app.n8n.cloud/webhook-test/Tareas';

static Future<bool> crearTarea(
    String titulo, String email, DateTime? fecha) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": titulo,
        "email": email,
        "fecha": fecha?.toIso8601String(),
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
}


