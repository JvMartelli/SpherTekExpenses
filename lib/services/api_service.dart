import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://sphertekexpenses-production.up.railway.app';
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

  static Future<String> uploadFoto(Uint8List bytes, String nomeArquivo) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload/foto'),
    );

    request.headers['Authorization'] = 'Bearer $_token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: nomeArquivo,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(body)['url'];
    }
    throw Exception('Erro ao fazer upload da foto');
  }

  static Future<List<dynamic>> listarCategorias() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categorias'),
      headers: _headers,
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro ao buscar categorias');
  }

  static Future<List<dynamic>> listarVeiculos() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/veiculos'),
      headers: _headers,
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
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

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erro ao buscar despesas');
  }

  static Future<void> deletarDespesa(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/despesas/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao deletar despesa');
    }
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