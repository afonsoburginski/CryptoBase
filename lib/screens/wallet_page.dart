import 'package:cryptobase/configs/app_settings.dart';
import 'package:cryptobase/models/position.dart';
import 'package:cryptobase/repositories/account_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatefulWidget {
  WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int index = 0;
  double totalWallet = 0;
  double saldo = 0;
  late NumberFormat real;
  late AccountRepository account;

  String graficoLabel = '';
  double graficoValor = 0;
  List<Position> wallet = [];

  @override
  Widget build(BuildContext context) {
    account = context.watch<AccountRepository>();
    final loc = context.read<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
    saldo = account.saldo;

    setTotalWallet();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: const EdgeInsets.only(top: 48, bottom: 8),
              child: Text(
                'Valor da Wallet',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              real.format(totalWallet),
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.5,
              ),
            ),
            loadGrafico(),
            loadHistorico(),
          ],
        ),
      ),
    );
  }

  setTotalWallet() {
    final walletList = account.wallet;
    setState(() {
      totalWallet = account.saldo;
      for (var position in walletList) {
        totalWallet += position.crypto.preco * position.quantidade;
      }
    });
  }

  setGraficoDados(int index) {
    if (index < 0) return;

    if (index == wallet.length) {
      graficoLabel = 'Saldo';
      graficoValor = account.saldo;
    } else {
      graficoLabel = wallet[index].crypto.nome;
      graficoValor = wallet[index].crypto.preco * wallet[index].quantidade;
    }
  }

  loadWallet() {
    setGraficoDados(index);
    wallet = account.wallet;
    final tamanhoLista = wallet.length + 1;

    return List.generate(tamanhoLista, (i) {
      final isTouched = i == index;
      final isSaldo = i == tamanhoLista - 1;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = isTouched ? Colors.indigoAccent : Colors.indigoAccent[400];

      double porcentagem = 0;
      if (!isSaldo) {
        porcentagem =
            wallet[i].crypto.preco * wallet[i].quantidade / totalWallet;
      } else {
        porcentagem = (account.saldo > 0) ? account.saldo / totalWallet : 0;
      }
      porcentagem *= 100;

      return PieChartSectionData(
        color: color,
        value: porcentagem,
        title: '${porcentagem.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );
    });
  }

  loadGrafico() {
    return (account.saldo <= 0)
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: const Center(
              child: const CircularProgressIndicator(),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 120,
                    sections: loadWallet(),
                    pieTouchData: PieTouchData(
                      touchCallback: (touch) => setState(() {
                        index = touch.touchedSection!.touchedSectionIndex;
                        setGraficoDados(index);
                      }),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    graficoLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    real.format(graficoValor),
                    style: const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  loadHistorico() {
    final historico = account.historico;
    final date = DateFormat('dd/MM/yyyy - hh:mm');
    List<Widget> widgets = [];

    for (var operacao in historico) {
      widgets.add(ListTile(
        title: Text(operacao.crypto.nome),
        subtitle: Text(date.format(operacao.dataOperacao)),
        trailing:
            Text(real.format((operacao.crypto.preco * operacao.quantidade))),
      ));
      widgets.add(const Divider());
    }
    return Column(
      children: widgets,
    );
  }
}
