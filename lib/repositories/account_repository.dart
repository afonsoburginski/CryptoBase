import 'package:cryptobase/database/db.dart';
import 'package:cryptobase/models/historic.dart';
import 'package:cryptobase/models/crypto.dart';
import 'package:cryptobase/models/position.dart';
import 'package:cryptobase/repositories/crypto_repository.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';

class AccountRepository extends ChangeNotifier {
  late Database db;
  List<Position> _Wallet = [];
  List<Historico> _historico = [];
  double _saldo = 0;
  CryptoRepository cryptos;

  get saldo => _saldo;
  List<Position> get wallet => _Wallet;
  List<Historico> get historico => _historico;

  AccountRepository({required this.cryptos}) {
    _initRepository();
  }

  _initRepository() async {
    await _getSaldo();
    await _getWallet();
    await _getHistorico();
  }

  _getSaldo() async {
    db = await DB.instance.database;
    List account = await db.query('account', limit: 1);
    _saldo = account.first['saldo'];
    notifyListeners();
  }

  setSaldo(double valor) async {
    db = await DB.instance.database;
    db.update('account', {
      'saldo': valor,
    });
    _saldo = valor;
    notifyListeners();
  }

  comprar(Crypto crypto, double valor) async {
    db = await DB.instance.database;
    await db.transaction((txn) async {
      // Verificar se a crypto já foi comprada
      final positionCrypto = await txn.query(
        'Wallet',
        where: 'sigla = ?',
        whereArgs: [crypto.sigla],
      );
      // Se não tem a crypto em Wallet
      if (positionCrypto.isEmpty) {
        await txn.insert('Wallet', {
          'sigla': crypto.sigla,
          'crypto': crypto.nome,
          'quantidade': (valor / crypto.preco).toString()
        });
      }
      // Já tem a crypto em Wallet
      else {
        final atual = double.parse(positionCrypto.first['quantidade'].toString());
        await txn.update(
          'Wallet',
          {'quantidade': (atual + (valor / crypto.preco)).toString()},
          where: 'sigla = ?',
          whereArgs: [crypto.sigla],
        );
      }

      // Inserir a compra no historico
      await txn.insert('historico', {
        'sigla': crypto.sigla,
        'crypto': crypto.nome,
        'quantidade': (valor / crypto.preco).toString(),
        'valor': valor,
        'tipo_operacao': 'compra',
        'data_operacao': DateTime.now().millisecondsSinceEpoch
      });

      //Atualizar o saldo
      await txn.update('account', {'saldo': saldo - valor});
    });
    await _initRepository();
    notifyListeners();
  }

  _getWallet() async {
    _Wallet = [];
    List posicoes = await db.query('Wallet');
    posicoes.forEach((position) {
      Crypto crypto = cryptos.table.firstWhere(
        (m) => m.sigla == position['sigla'],
      );
      _Wallet.add(Position(
        crypto: crypto,
        quantidade: double.parse(position['quantidade']),
      ));
    });
    notifyListeners();
  }

  _getHistorico() async {
    _historico = [];
    List operacoes = await db.query('historico');
    operacoes.forEach((operacao) {
      Crypto crypto = cryptos.table.firstWhere(
        (m) => m.sigla == operacao['sigla'],
      );
      _historico.add(
        Historico(
          dataOperacao:
              DateTime.fromMillisecondsSinceEpoch(operacao['data_operacao']),
          tipoOperacao: operacao['tipo_operacao'],
          crypto: crypto,
          valor: operacao['valor'],
          quantidade: double.parse(operacao['quantidade']),
        ),
      );
    });
    notifyListeners();
  }
}
