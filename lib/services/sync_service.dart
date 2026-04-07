import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_helper.dart';
import 'api_service.dart';

class SyncService {
  static final DatabaseHelper _db = DatabaseHelper();

  static Future<bool> temInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  static Future<void> sincronizar() async {
    if (!await temInternet()) return;

    try {
      final despesasPendentes = await _db.listarNaoSincronizadas();
      if (despesasPendentes.isEmpty) return;

      final dados = despesasPendentes.map((d) => {
        'descricao': d.descricao,
        'valor': d.valor,
        'categoria_id': d.categoriaId,
        'veiculo_id': d.veiculoId,
        'foto_url': d.fotoPath,
        'data_despesa': '${d.data.year}-${d.data.month.toString().padLeft(2, '0')}-${d.data.day.toString().padLeft(2, '0')}',
      }).toList();

      await ApiService.sincronizar(dados);

      for (final despesa in despesasPendentes) {
        await _db.marcarSincronizado(despesa.id!);
      }
    } catch (e) {
      // Falhou silenciosamente — tenta na próxima vez
    }
  }

  static void monitorar(Function onSincronizado) {
    Connectivity().onConnectivityChanged.listen((results) async {
      final temConexao = results.any((r) => r != ConnectivityResult.none);
      if (temConexao) {
        await sincronizar();
        onSincronizado();
      }
    });
  }
}