import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptobase/databases/db_firestore.dart';
import 'package:cryptobase/models/crypto.dart';
import 'package:cryptobase/repositories/crypto_repository.dart';
import 'package:cryptobase/services/auth_service.dart';
import 'package:flutter/material.dart';

class FavoritesRepository extends ChangeNotifier {
  List<Crypto> _lista = [];
  late FirebaseFirestore db;
  late AuthService auth;
  CryptoRepository cryptos;

  FavoritesRepository({required this.auth, required this.cryptos}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    await _readFavorites();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  _readFavorites() async {
    if (auth.usuario != null && _lista.isEmpty) {
      try {
        final snapshot = await db
            .collection('usuarios/${auth.usuario!.uid}/favorites')
            .get();

        snapshot.docs.forEach((doc) {
          Crypto crypto = cryptos.table
              .firstWhere((crypto) => crypto.sigla == doc.get('sigla'));
          _lista.add(crypto);
          notifyListeners();
        });
      } catch (e) {
        print('Sem id de usuário');
      }
    }
  }

  UnmodifiableListView<Crypto> get lista => UnmodifiableListView(_lista);

  saveAll(List<Crypto> cryptos) {
    cryptos.forEach((crypto) async {
      if (!_lista.any((atual) => atual.sigla == crypto.sigla)) {
        _lista.add(crypto);
        await db
            .collection('usuarios/${auth.usuario!.uid}/favorites')
            .doc(crypto.sigla)
            .set({
          'crypto': crypto.nome,
          'sigla': crypto.sigla,
          'preco': crypto.preco,
        });
      }
    });
    notifyListeners();
  }

  remove(Crypto crypto) async {
    await db
        .collection('usuarios/${auth.usuario!.uid}/favorites')
        .doc(crypto.sigla)
        .delete();
    _lista.remove(crypto);
    notifyListeners();
  }
}
