import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../database/database_helper.dart';
import '../model/despesa.dart';

class NovaDespesaPage extends StatefulWidget {
  final Map<String, dynamic>? despesaAtual;

  const NovaDespesaPage({super.key, this.despesaAtual});

  @override
  State<NovaDespesaPage> createState() => _NovaDespesaPageState();
}

class _NovaDespesaPageState extends State<NovaDespesaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _db = DatabaseHelper();

  List<dynamic> _categorias = [];
  List<dynamic> _veiculos = [];
  String? _categoriaSelecionada;
  String? _veiculoSelecionado;
  bool _exigePlaca = false;
  DateTime _data = DateTime.now();
  XFile? _fotoXFile;
  bool _salvando = false;
  bool _carregando = true;

  bool get _editando => widget.despesaAtual != null;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    if (_editando) {
      final d = widget.despesaAtual!;
      _descricaoCtrl.text = d['descricao'] ?? '';
      _valorCtrl.text = d['valor'].toString();
      _data = DateTime.parse(d['data_despesa']);
    }
  }

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      List<dynamic> categorias = [];
      List<dynamic> veiculos = [];

      try {
        categorias = await ApiService.listarCategorias();
        veiculos = await ApiService.listarVeiculos();
        await _db.salvarCategorias(categorias);
        await _db.salvarVeiculos(veiculos);
      } catch (_) {
        categorias = await _db.listarCategorias();
        veiculos = await _db.listarVeiculos();
      }

      setState(() {
        _categorias = categorias;
        _veiculos = veiculos;
        if (_editando) {
          _categoriaSelecionada = widget.despesaAtual!['categoria_id'];
          _veiculoSelecionado = widget.despesaAtual!['veiculo_id'];
          final cat = _categorias.firstWhere(
                (c) => c['id'] == _categoriaSelecionada,
            orElse: () => null,
          );
          if (cat != null) _exigePlaca = cat['exige_placa'] ?? false;
        } else if (_categorias.isNotEmpty) {
          _categoriaSelecionada = _categorias.first['id'];
          _exigePlaca = _categorias.first['exige_placa'] ?? false;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _tirarFoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );
      if (picked != null) setState(() => _fotoXFile = picked);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Câmera não disponível. Tente a galeria.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _escolherGaleria() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (picked != null) setState(() => _fotoXFile = picked);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1565C0)),
              title: const Text('Tirar foto com câmera'),
              onTap: () { Navigator.pop(context); _tirarFoto(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1565C0)),
              title: const Text('Escolher da galeria'),
              onTap: () { Navigator.pop(context); _escolherGaleria(); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewFoto() {
    if (_fotoXFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: kIsWeb
            ? Image.network(_fotoXFile!.path, fit: BoxFit.cover)
            : Image.file(File(_fotoXFile!.path), fit: BoxFit.cover),
      );
    }

    if (_editando && widget.despesaAtual!['foto_url'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.despesaAtual!['foto_url'],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _semFotoWidget(),
        ),
      );
    }

    return _semFotoWidget();
  }

  Widget _semFotoWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text('Toque para adicionar foto *',
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _selecionarData() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (dt != null) setState(() => _data = dt);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final temFoto = _fotoXFile != null ||
        (_editando && widget.despesaAtual!['foto_url'] != null);
    if (!temFoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A foto do comprovante é obrigatória!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_exigePlaca && _veiculoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta categoria exige seleção de veículo!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final categoriaNome = _categorias.firstWhere(
            (c) => c['id'] == _categoriaSelecionada,
        orElse: () => {'nome': ''},
      )['nome'];

      final veiculoPlaca = _veiculoSelecionado != null
          ? _veiculos.firstWhere(
            (v) => v['id'] == _veiculoSelecionado,
        orElse: () => {'placa': ''},
      )['placa']
          : null;

      try {
        String fotoUrl;
        if (_fotoXFile != null) {
          final bytes = await _fotoXFile!.readAsBytes();
          fotoUrl = await ApiService.uploadFoto(bytes, _fotoXFile!.name);
        } else {
          fotoUrl = widget.despesaAtual!['foto_url'];
        }

        await ApiService.criarDespesa({
          'descricao': _descricaoCtrl.text.trim(),
          'valor': double.parse(_valorCtrl.text.trim().replaceAll(',', '.')),
          'categoria_id': _categoriaSelecionada,
          'veiculo_id': _veiculoSelecionado,
          'foto_url': fotoUrl,
          'data_despesa':
          '${_data.year}-${_data.month.toString().padLeft(2, '0')}-${_data.day.toString().padLeft(2, '0')}',
        });
      } catch (_) {
        // Sem internet — salva localmente
        final despesaLocal = Despesa(
          descricao: _descricaoCtrl.text.trim(),
          valor: double.parse(_valorCtrl.text.trim().replaceAll(',', '.')),
          categoria: categoriaNome,
          fotoPath: _fotoXFile?.path ?? widget.despesaAtual!['foto_url'],
          veiculo: veiculoPlaca,
          categoriaId: _categoriaSelecionada,
          veiculoId: _veiculoSelecionado,
          data: _data,
          sincronizado: false,
        );
        await _db.inserir(despesaLocal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sem internet. Despesa salva localmente e será sincronizada em breve.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao salvar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(_editando ? 'Corrigir Despesa' : 'Nova Despesa'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_editando && widget.despesaAtual!['motivo_rejeicao'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Motivo da rejeição: ${widget.despesaAtual!['motivo_rejeicao']}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Row(
                children: const [
                  Text('Foto do Comprovante',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(width: 4),
                  Text('*', style: TextStyle(color: Colors.red, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _mostrarOpcoesFoto,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(
                      color: _fotoXFile == null &&
                          !(_editando && widget.despesaAtual!['foto_url'] != null)
                          ? Colors.red.shade300
                          : const Color(0xFF1565C0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _previewFoto(),
                ),
              ),
              if (_fotoXFile != null)
                TextButton.icon(
                  onPressed: () => setState(() => _fotoXFile = null),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Remover foto',
                      style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _valorCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$) *',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _categorias
                    .map((c) => DropdownMenuItem<String>(
                  value: c['id'],
                  child: Text(c['nome']),
                ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _categoriaSelecionada = v;
                    final cat = _categorias.firstWhere(
                          (c) => c['id'] == v,
                      orElse: () => null,
                    );
                    _exigePlaca = cat?['exige_placa'] ?? false;
                    if (!_exigePlaca) _veiculoSelecionado = null;
                  });
                },
              ),
              const SizedBox(height: 14),

              if (_exigePlaca) ...[
                DropdownButtonFormField<String>(
                  value: _veiculoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Veículo *',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _veiculos
                      .map((v) => DropdownMenuItem<String>(
                    value: v['id'],
                    child: Text('${v['placa']} - ${v['modelo'] ?? ''}'),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _veiculoSelecionado = v),
                ),
                const SizedBox(height: 14),
              ],

              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_data.day.toString().padLeft(2, '0')}/'
                        '${_data.month.toString().padLeft(2, '0')}/'
                        '${_data.year}',
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(
                    _salvando
                        ? 'Salvando...'
                        : (_editando ? 'Reenviar Despesa' : 'Salvar Despesa'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}