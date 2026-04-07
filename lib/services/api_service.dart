import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('E-mail ou senha incorretos');
  }

  static Future<List<dynamic>> listarCategorias() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categorias'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao buscar categorias');
  }

  static Future<List<dynamic>> listarVeiculos() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/veiculos'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao buscar veículos');
  }

  static Future<Map<String, dynamic>> criarDespesa(Map<String, dynamic> dados) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/despesas'),
      headers: _headers,
      body: jsonEncode(dados),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao criar despesa');
  }

  static Future<List<dynamic>> listarDespesas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/despesas'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao buscar despesas');
  }

  static Future<void> sincronizar(List<Map<String, dynamic>> despesas) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/despesas/sincronizar'),
      headers: _headers,
      body: jsonEncode({'despesas': despesas}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao sincronizar despesas');
    }
  }
}