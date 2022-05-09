import 'package:cryptobase/models/crypto.dart';

class Historico {
  DateTime dataOperacao;
  String tipoOperacao;
  Crypto crypto;
  double valor;
  double quantidade;

  Historico({
    required this.dataOperacao,
    required this.tipoOperacao,
    required this.crypto,
    required this.valor,
    required this.quantidade,
  });
}
