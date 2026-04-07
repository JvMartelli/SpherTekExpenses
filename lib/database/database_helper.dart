import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../model/despesa.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._interno();
  static Database? _database;

  DatabaseHelper._interno();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _inicializar();
    return _database!;
  }

  Future<Database> _inicializar() async {
    final caminho = join(await getDatabasesPath(), 'spher_tek.db');
    return openDatabase(
      caminho,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE despesas (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao      TEXT    NOT NULL,
            valor          REAL    NOT NULL,
            categoria      TEXT    NOT NULL,
            fotoPath       TEXT    NOT NULL,
            veiculo        TEXT,
            status         TEXT    NOT NULL DEFAULT 'pendente',
            motivoRejeicao TEXT,
            data           TEXT    NOT NULL,
            sincronizado   INTEGER NOT NULL DEFAULT 0,
            categoriaId    TEXT,
            veiculoId      TEXT
          )
        ''');
      },
    );
  }

  static const _chaveWeb = 'despesas';
  static const _chaveCategorias = 'categorias_cache';
  static const _chaveVeiculos = 'veiculos_cache';

  Future<void> _salvarListaWeb(List<Despesa> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = lista.map((d) => jsonEncode(d.toMap())).toList();
    await prefs.setStringList(_chaveWeb, jsonList);
  }

  Future<List<Despesa>> _listarWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_chaveWeb) ?? [];
    return jsonList.map((s) => Despesa.fromMap(jsonDecode(s))).toList();
  }

  // ── Cache de categorias e veículos ───────────────────────

  Future<void> salvarCategorias(List<dynamic> categorias) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveCategorias, jsonEncode(categorias));
  }

  Future<List<dynamic>> listarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_chaveCategorias);
    if (json == null) return [];
    return jsonDecode(json);
  }

  Future<void> salvarVeiculos(List<dynamic> veiculos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveVeiculos, jsonEncode(veiculos));
  }

  Future<List<dynamic>> listarVeiculos() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_chaveVeiculos);
    if (json == null) return [];
    return jsonDecode(json);
  }

  // ── CRUD despesas ────────────────────────────────────────

  Future<int> inserir(Despesa d) async {
    if (kIsWeb) {
      final lista = await _listarWeb();
      d.id = DateTime.now().millisecondsSinceEpoch;
      lista.insert(0, d);
      await _salvarListaWeb(lista);
      return d.id!;
    }
    final db = await database;
    return db.insert('despesas', d.toMap()..remove('id'));
  }

  Future<int> atualizar(Despesa d) async {
    if (kIsWeb) {
      final lista = await _listarWeb();
      final index = lista.indexWhere((x) => x.id == d.id);
      if (index != -1) lista[index] = d;
      await _salvarListaWeb(lista);
      return 1;
    }
    final db = await database;
    return db.update('despesas', d.toMap(), where: 'id = ?', whereArgs: [d.id]);
  }

  Future<int> deletar(int id) async {
    if (kIsWeb) {
      final lista = await _listarWeb();
      lista.removeWhere((d) => d.id == id);
      await _salvarListaWeb(lista);
      return 1;
    }
    final db = await database;
    return db.delete('despesas', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Despesa>> listar() async {
    if (kIsWeb) return _listarWeb();
    final db = await database;
    final rows = await db.query('despesas', orderBy: 'data DESC');
    return rows.map(Despesa.fromMap).toList();
  }

  Future<List<Despesa>> listarNaoSincronizadas() async {
    if (kIsWeb) {
      final lista = await _listarWeb();
      return lista.where((d) => !d.sincronizado).toList();
    }
    final db = await database;
    final rows = await db.query(
      'despesas',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return rows.map(Despesa.fromMap).toList();
  }

  Future<void> marcarSincronizado(int id) async {
    if (kIsWeb) {
      final lista = await _listarWeb();
      final index = lista.indexWhere((d) => d.id == id);
      if (index != -1) {
        lista[index].sincronizado = true;
        await _salvarListaWeb(lista);
      }
      return;
    }
    final db = await database;
    await db.update(
      'despesas',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}