import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'nova_despesa_page.dart';
import 'detalhe_despesa_page.dart';

class ListaDespesasPage extends StatefulWidget {
  const ListaDespesasPage({super.key});

  @override
  State<ListaDespesasPage> createState() => _ListaDespesasPageState();
}

class _ListaDespesasPageState extends State<ListaDespesasPage> {
  List<dynamic> _despesas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      _despesas = await ApiService.listarDespesas();
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

  Future<void> _excluir(Map<String, dynamic> despesa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Atenção'),
        ]),
        content: Text('Excluir "${despesa['descricao']}"?'),
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
      await ApiService.deletarDespesa(despesa['id']);
      _carregar();
    }
  }

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
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            SizedBox(height: 8),
            Text('Toque no + para adicionar',
                style: TextStyle(color: Colors.grey)),
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
            final d = _despesas[i] as Map<String, dynamic>;
            final status = d['status'] ?? 'pendente';
            final categoria = d['categorias']?['nome'] ?? '';
            final veiculo = d['veiculos']?['placa'];
            final cor = _corStatus(status);

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
                      CircleAvatar(
                        backgroundColor:
                        const Color(0xFF1565C0).withOpacity(0.1),
                        child: Icon(_iconeCategoria(categoria),
                            color: const Color(0xFF1565C0)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(d['descricao'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                                '$categoria  •  ${d['data_despesa'] ?? ''}',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13)),
                            if (veiculo != null)
                              Text('🚗 $veiculo',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${double.tryParse(d['valor'].toString())?.toStringAsFixed(2) ?? '0,00'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1565C0)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.12),
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: Text(
                              _labelStatus(status),
                              style: TextStyle(
                                  color: cor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (status == 'rejeitada')
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            NovaDespesaPage(
                                                despesaAtual: d),
                                      ),
                                    );
                                    _carregar();
                                  },
                                  child: const Icon(Icons.edit,
                                      color: Colors.orange,
                                      size: 20),
                                ),
                              if (status == 'rejeitada')
                                const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _excluir(d),
                                child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20),
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