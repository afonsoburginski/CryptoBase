import 'package:cryptobase/models/crypto.dart';
import 'package:cryptobase/repositories/favorites_repository.dart';
import 'package:cryptobase/widgets/crypto_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cryptos Favorites'),
      ),
      body: Container(
        color: Colors.indigo.withOpacity(0.05),
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(12.0),
        child: Consumer<FavoritesRepository>(
          builder: (context, favorites, child) {
            return favorites.lista.isEmpty
                ? const ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Você ainda não adicionou nenhuma Moeda :('),
                  )
                : ListView.builder(
                    itemCount: favorites.lista.length,
                    itemBuilder: (_, index) {
                      return CryptoCard(crypto: favorites.lista[index]);
                    },
                  );
          },
        ),
      ),
    );
  }
}
