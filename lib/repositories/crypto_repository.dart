import 'dart:async';
import 'dart:convert';

import 'package:cryptobase/database/db.dart';
import 'package:cryptobase/models/crypto.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:http/http.dart' as http;

class CryptoRepository extends ChangeNotifier {
  List<Crypto> _table = [];
  late Timer intervalo;

  List<Crypto> get table => _table;

  CryptoRepository() {
    _setupCryptosTable();
    _setupDadosTableCrypto();
    _readCryptosTable();
    _refreshPrecos();
  }

  _refreshPrecos() async {
   intervalo = Timer.periodic(Duration(minutes: 5), (_) => checkPrecos());
  }

  getHistoricoCrypto(Crypto crypto) async {
    final response = await http.get(
      Uri.parse(
        'https://api.coinbase.com/v2/assets/prices/${crypto.baseId}?base=BRL',
      ),
    );
    List<Map<String, dynamic>> precos = [];

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Map<String, dynamic> crypto = json['data']['prices'];

      precos.add(crypto['hour']);
      precos.add(crypto['day']);
      precos.add(crypto['week']);
      precos.add(crypto['month']);
      precos.add(crypto['year']);
      precos.add(crypto['all']);
    }

    return precos;
  }

  checkPrecos() async {
    String uri = 'https://api.coinbase.com/v2/assets/prices?base=BRL';
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> cryptos = json['data'];
      Database db = await DB.instance.database;
      Batch batch = db.batch();

      _table.forEach((atual) {
        cryptos.forEach((novo) {
          if (atual.baseId == novo['base_id']) {
            final crypto = novo['prices'];
            final preco = crypto['latest_price'];
            final timestamp = DateTime.parse(preco['timestamp']);

            batch.update(
              'cryptos',
              {
                'preco': crypto['latest'],
                'timestamp': timestamp.millisecondsSinceEpoch,
                'mudancaHora': preco['percent_change']['hour'].toString(),
                'mudancaDia': preco['percent_change']['day'].toString(),
                'mudancaSemana': preco['percent_change']['week'].toString(),
                'mudancaMes': preco['percent_change']['month'].toString(),
                'mudancaAno': preco['percent_change']['year'].toString(),
                'mudancaPeriodoTotal': preco['percent_change']['all'].toString()
              },
              where: 'baseId = ?',
              whereArgs: [atual.baseId],
            );
          }
        });
      });
      await batch.commit(noResult: true);
      await _readCryptosTable();
    }
  }

  _readCryptosTable() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('cryptos');

    _table = resultados.map((row) {
      return Crypto(
        baseId: row['baseId'],
        icone: row['icone'],
        sigla: row['sigla'],
        nome: row['nome'],
        preco: double.parse(row['preco']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        mudancaHora: double.parse(row['mudancaHora']),
        mudancaDia: double.parse(row['mudancaDia']),
        mudancaSemana: double.parse(row['mudancaSemana']),
        mudancaMes: double.parse(row['mudancaMes']),
        mudancaAno: double.parse(row['mudancaAno']),
        mudancaPeriodoTotal: double.parse(row['mudancaPeriodoTotal']),
      );
    }).toList();

    notifyListeners();
  }

  _cryptosTableIsEmpty() async {
    Database db = await DB.instance.database;
    List resultados = await db.query('cryptos');
    return resultados.isEmpty;
  }

  _setupDadosTableCrypto() async {
    if (await _cryptosTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> cryptos = json['data'];
        Database db = await DB.instance.database;
        Batch batch = db.batch();

        cryptos.forEach((crypto) {
          final preco = crypto['latest_price'];
          final timestamp = DateTime.parse(preco['timestamp']);

          batch.insert('cryptos', {
            'baseId': crypto['id'],
            'sigla': crypto['symbol'],
            'nome': crypto['name'],
            'icone': crypto['image_url'],
            'preco': crypto['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'mudancaHora': preco['percent_change']['hour'].toString(),
            'mudancaDia': preco['percent_change']['day'].toString(),
            'mudancaSemana': preco['percent_change']['week'].toString(),
            'mudancaMes': preco['percent_change']['month'].toString(),
            'mudancaAno': preco['percent_change']['year'].toString(),
            'mudancaPeriodoTotal': preco['percent_change']['all'].toString()
          });
        });
        await batch.commit(noResult: true);
      }
    }
  }

  _setupCryptosTable() async {
    const String table = '''
      CREATE TABLE IF NOT EXISTS cryptos (
        baseId TEXT PRIMARY KEY,
        sigla TEXT,
        nome TEXT,
        icone TEXT,
        preco TEXT,
        timestamp INTEGER,
        mudancaHora TEXT,
        mudancaDia TEXT,
        mudancaSemana TEXT,
        mudancaMes TEXT,
        mudancaAno TEXT,
        mudancaPeriodoTotal TEXT
      );
    ''';
    Database db = await DB.instance.database;
    await db.execute(table);
  }
}
