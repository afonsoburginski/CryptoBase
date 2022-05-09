import 'package:cryptobase/screens/home_page.dart';
import 'package:cryptobase/widgets/auth_check.dart';
import 'package:flutter/material.dart';

class CryptoBase extends StatelessWidget {
  const CryptoBase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CryptoBase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}

/* AuthCheck */