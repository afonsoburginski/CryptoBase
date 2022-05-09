import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DB {
  // Construtor com acesso privado
  DB._();
  // Criar uma instancia de DB
  static final DB instance = DB._();
  //Instancia do SQLite
  static Database? _database;

  get database async {
    if (_database != null) return _database;

    return await _initDatabase();
  }

  _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'criptoo.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, versao) async {
    await db.execute(_account);
    await db.execute(_Wallet);
    await db.execute(_historic);
    await db.insert('account', {'saldo': 0});
  }

  String get _account => '''
    CREATE TABLE account (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      saldo REAL
    );
  ''';

  String get _Wallet => '''
    CREATE TABLE Wallet (
      sigla TEXT PRIMARY KEY,
      crypto TEXT,
      quantidade TEXT
    );
  ''';

  String get _historic => '''
    CREATE TABLE historic (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_operacao INT,
      tipo_operacao TEXT,
      crypto TEXT,
      sigla TEXT,
      valor REAL,
      quantidade TEXT
    );
  ''';
}
