import 'package:cryptobase/configs/app_settings.dart';
import 'package:cryptobase/configs/hive_config.dart';
import 'package:cryptobase/repositories/account_repository.dart';
import 'package:cryptobase/repositories/favorites_repository.dart';
import 'package:cryptobase/repositories/crypto_repository.dart';
import 'package:cryptobase/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/crypto_base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => CryptoRepository()),
        ChangeNotifierProvider(
            create: (context) => AccountRepository(
                  cryptos: context.read<CryptoRepository>(),
                )),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(
          create: (context) => FavoritesRepository(
            auth: context.read<AuthService>(),
            cryptos: context.read<CryptoRepository>(),
          ),
        ),
      ],
      child: const CryptoBase(),
    ),
  );
}
