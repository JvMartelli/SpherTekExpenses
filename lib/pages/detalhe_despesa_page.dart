import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../model/despesa.dart';

class DetalheDespesaPage extends StatelessWidget {
  final Despesa despesa;

  const DetalheDespesaPage({super.key, required this.despesa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text('Detalhe da Despesa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: despesa.statusCor.withOpacity(0.1),
                border: Border.all(color: despesa.statusCor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(_iconeStatus(despesa.status), color: despesa.statusCor),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        despesa.statusLabel,
                        style: TextStyle(
                          color: despesa.statusCor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (despesa.motivoRejeicao != null)
                        Text(
                          despesa.motivoRejeicao!,
                          style: TextStyle(color: despesa.statusCor, fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Foto do comprovante ───────────────────────
            const Text('Comprovante',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(despesa.fotoPath, width: double.infinity, fit: BoxFit.cover)
                  : Image.file(File(despesa.fotoPath), width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // ── Dados ─────────────────────────────────────
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _linha(Icons.description_outlined, 'Descrição', despesa.descricao),
                    const Divider(),
                    _linha(Icons.attach_money, 'Valor', despesa.valorFormatado, destaque: true),
                    const Divider(),
                    _linha(Icons.category_outlined, 'Categoria', despesa.categoria),
                    const Divider(),
                    if (despesa.veiculo != null) ...[
                      _linha(Icons.directions_car_outlined, 'Veículo', despesa.veiculo!),
                      const Divider(),
                    ],
                    _linha(Icons.calendar_today_outlined, 'Data', despesa.dataFormatada),
                    const Divider(),
                    _linha(
                      despesa.sincronizado ? Icons.cloud_done : Icons.cloud_off,
                      'Sincronização',
                      despesa.sincronizado ? 'Sincronizado' : 'Pendente',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconeStatus(String status) {
    switch (status) {
      case 'aprovada':  return Icons.check_circle;
      case 'rejeitada': return Icons.cancel;
      default:          return Icons.hourglass_empty;
    }
  }

  Widget _linha(IconData icone, String label, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icone, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: destaque ? 20 : 15,
                    fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
                    color: destaque ? const Color(0xFF1565C0) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}