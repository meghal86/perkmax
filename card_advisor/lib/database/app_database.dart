import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_advisor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration to add lat/lng/visit_count to merchants
      // Since we are dev/alpha, dropping and recreating is easiest to ensure schema match
      await db.execute('DROP TABLE IF EXISTS merchants');
      await db.execute('''
        CREATE TABLE merchants (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          lat REAL NOT NULL,
          lng REAL NOT NULL,
          mcc TEXT NOT NULL,
          category TEXT NOT NULL,
          visit_count INTEGER DEFAULT 0
        )
      ''');
      // Re-create index
      await db.execute(
        'CREATE INDEX idx_merchants_lat_lng ON merchants(lat, lng)',
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        issuer TEXT NOT NULL,
        product_name TEXT NOT NULL,
        network TEXT NOT NULL,
        annual_fee_cents INTEGER NOT NULL,
        is_active INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE card_rewards (
        id TEXT PRIMARY KEY,
        card_id TEXT NOT NULL,
        category TEXT NOT NULL,
        mcc TEXT,
        earn_rate REAL NOT NULL,
        cap_amount_cents INTEGER,
        cap_period TEXT,
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_wallet (
        card_id TEXT PRIMARY KEY,
        nickname TEXT,
        added_at TEXT NOT NULL,
        FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE merchants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        mcc TEXT NOT NULL,
        category TEXT NOT NULL,
        visit_count INTEGER DEFAULT 0
      )
    ''');

    // Index for location search
    await db.execute(
      'CREATE INDEX idx_merchants_lat_lng ON merchants(lat, lng)',
    );

    await db.execute('''
      CREATE TABLE spend (
        id TEXT PRIMARY KEY,
        merchant_id TEXT,
        amount_cents INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        category TEXT,
        FOREIGN KEY (merchant_id) REFERENCES merchants (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
