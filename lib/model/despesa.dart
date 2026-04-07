import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Despesa {
  int? id;
  String descricao;
  double valor;
  String categoria;
  String fotoPath;   // obrigatória
  String? veiculo;
  String status;     // pendente, aprovada, rejeitada
  String? motivoRejeicao;
  DateTime data;
  bool sincronizado;

  Despesa({
    this.id,
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.fotoPath,
    this.veiculo,
    this.status = 'pendente',
    this.motivoRejeicao,
    required this.data,
    this.sincronizado = false,
  });

  String get dataFormatada => DateFormat('dd/MM/yyyy').format(data);

  String get valorFormatado =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor);

  String get statusLabel {
    switch (status) {
      case 'aprovada':   return 'Aprovada';
      case 'rejeitada':  return 'Rejeitada';
      default:           return 'Pendente';
    }
  }

  Color get statusCor {
    switch (status) {
      case 'aprovada':  return const Color(0xFF2E7D32);
      case 'rejeitada': return const Color(0xFFC62828);
      default:          return const Color(0xFFE65100);
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'descricao': descricao,
    'valor': valor,
    'categoria': categoria,
    'fotoPath': fotoPath,
    'veiculo': veiculo,
    'status': status,
    'motivoRejeicao': motivoRejeicao,
    'data': data.toIso8601String(),
    'sincronizado': sincronizado ? 1 : 0,
  };

  factory Despesa.fromMap(Map<String, dynamic> map) => Despesa(
    id: map['id'],
    descricao: map['descricao'],
    valor: map['valor'],
    categoria: map['categoria'],
    fotoPath: map['fotoPath'],
    veiculo: map['veiculo'],
    status: map['status'] ?? 'pendente',
    motivoRejeicao: map['motivoRejeicao'],
    data: DateTime.parse(map['data']),
    sincronizado: map['sincronizado'] == 1,
  );
}