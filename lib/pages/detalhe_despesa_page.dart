import 'package:flutter/material.dart';

class DetalheDespesaPage extends StatelessWidget {
  final Map<String, dynamic> despesa;

  const DetalheDespesaPage({super.key, required this.despesa});

  Color _corStatus(String status) {
    switch (status) {
      case 'aprovada':  return const Color(0xFF2E7D32);
      case 'rejeitada': return const Color(0xFFC62828);
      default:          return const Color(0xFFE65100);
    }
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'aprovada':  return 'Aprovada';
      case 'rejeitada': return 'Rejeitada';
      default:          return 'Pendente';
    }
  }

  IconData _iconeStatus(String status) {
    switch (status) {
      case 'aprovada':  return Icons.check_circle;
      case 'rejeitada': return Icons.cancel;
      default:          return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = despesa['status'] ?? 'pendente';
    final cor = _corStatus(status);
    final categoria = despesa['categorias']?['nome'] ?? '';
    final veiculo = despesa['veiculos']?['placa'];
    final modelo = despesa['veiculos']?['modelo'];
    final fotoUrl = despesa['foto_url'];

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                border: Border.all(color: cor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(_iconeStatus(status), color: cor),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _labelStatus(status),
                        style: TextStyle(
                          color: cor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (despesa['motivo_rejeicao'] != null)
                        Text(
                          despesa['motivo_rejeicao'],
                          style: TextStyle(color: cor, fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text('Comprovante',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            if (fotoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fotoUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _semFoto(),
                ),
              )
            else
              _semFoto(),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _linha(Icons.description_outlined, 'Descrição',
                        despesa['descricao'] ?? ''),
                    const Divider(),
                    _linha(Icons.attach_money, 'Valor',
                        'R\$ ${double.tryParse(despesa['valor'].toString())?.toStringAsFixed(2) ?? '0,00'}',
                        destaque: true),
                    const Divider(),
                    _linha(Icons.category_outlined, 'Categoria', categoria),
                    const Divider(),
                    if (veiculo != null) ...[
                      _linha(Icons.directions_car_outlined, 'Veículo',
                          '$veiculo${modelo != null ? ' - $modelo' : ''}'),
                      const Divider(),
                    ],
                    _linha(Icons.calendar_today_outlined, 'Data',
                        despesa['data_despesa'] ?? ''),
                    const Divider(),
                    _linha(
                      despesa['sincronizado_em'] != null
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      'Sincronização',
                      despesa['sincronizado_em'] != null
                          ? 'Sincronizado'
                          : 'Pendente',
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

  Widget _semFoto() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_photography, color: Colors.grey, size: 36),
          SizedBox(height: 8),
          Text('Sem foto anexada', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _linha(IconData icone, String label, String valor,
      {bool destaque = false}) {
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
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: destaque ? 20 : 15,
                    fontWeight:
                    destaque ? FontWeight.bold : FontWeight.w500,
                    color: destaque
                        ? const Color(0xFF1565C0)
                        : Colors.black87,
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