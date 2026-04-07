import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../model/despesa.dart';
import 'login_page.dart';
import 'nova_despesa_page.dart';
import 'detalhe_despesa_page.dart';

class ListaDespesasPage extends StatefulWidget {
  const ListaDespesasPage({super.key});

  @override
  State<ListaDespesasPage> createState() => _ListaDespesasPageState();
}

class _ListaDespesasPageState extends State<ListaDespesasPage> {
  final _db = DatabaseHelper();
  List<Despesa> _despesas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _despesas = await _db.listar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _excluir(Despesa despesa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Atenção'),
        ]),
        content: Text('Excluir "${despesa.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _db.deletar(despesa.id!);
      _carregar();
    }
  }

  IconData _iconeCategoria(String cat) {
    switch (cat) {
      case 'Combustível':    return Icons.local_gas_station;
      case 'Alimentação':    return Icons.restaurant;
      case 'Pedágio':        return Icons.toll;
      case 'Estacionamento': return Icons.local_parking;
      case 'Hospedagem':     return Icons.hotel;
      case 'Manutenção':     return Icons.build_outlined;
      default:               return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text('Minhas Despesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _despesas.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma despesa lançada',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Toque no + para adicionar', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _carregar,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _despesas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (_, i) {
            final d = _despesas[i];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalheDespesaPage(despesa: d),
                    ),
                  );
                  _carregar();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Foto miniatura
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: kIsWeb
                              ? Image.network(d.fotoPath, fit: BoxFit.cover)
                              : Image.file(File(d.fotoPath), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Dados
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.descricao,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${d.categoria}  •  ${d.dataFormatada}',
                                style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            if (d.veiculo != null)
                              Text('🚗 ${d.veiculo}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),

                      // Valor + status + ações
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(d.valorFormatado,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1565C0))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: d.statusCor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              d.statusLabel,
                              style: TextStyle(
                                  color: d.statusCor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Botão corrigir (só rejeitadas)
                              if (d.status == 'rejeitada')
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NovaDespesaPage(despesaAtual: d),
                                      ),
                                    );
                                    _carregar();
                                  },
                                  child: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                ),
                              if (d.status == 'rejeitada') const SizedBox(width: 6),
                              // Botão excluir
                              GestureDetector(
                                onTap: () => _excluir(d),
                                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NovaDespesaPage()),
          );
          _carregar();
        },
        tooltip: 'Nova Despesa',
        child: const Icon(Icons.add),
      ),
    );
  }
}