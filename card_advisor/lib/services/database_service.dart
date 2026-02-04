import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class DatabaseService {
  static Database? _database;
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();
  static encrypt.Encrypter? _encrypter;
  static encrypt.IV? _iv;

  static const String _encryptionKeyName = 'db_encryption_key';
  static const String _ivKeyName = 'db_encryption_iv';

  // Tables
  static const String tableCards = 'cards';
  static const String tableCardFeatures = 'card_features';
  static const String tableRewardRates = 'reward_rates';
  static const String tableCardPoints = 'card_points';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<void> _initEncryption() async {
    if (_encrypter != null) return;

    // Get or create encryption key
    String? storedKey = await _secureStorage.read(key: _encryptionKeyName);
    String? storedIv = await _secureStorage.read(key: _ivKeyName);

    if (storedKey == null || storedIv == null) {
      // Generate new encryption key and IV
      final key = encrypt.Key.fromSecureRandom(32);
      final iv = encrypt.IV.fromSecureRandom(16);

      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Encode(key.bytes),
      );
      await _secureStorage.write(
        key: _ivKeyName,
        value: base64Encode(iv.bytes),
      );

      _encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      _iv = iv;
    } else {
      final key = encrypt.Key(base64Decode(storedKey));
      _iv = encrypt.IV(base64Decode(storedIv));
      _encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
    }
  }

  // Encrypt sensitive data
  static String encryptValue(String value) {
    if (_encrypter == null || _iv == null) {
      throw Exception('Encryption not initialized');
    }
    return _encrypter!.encrypt(value, iv: _iv).base64;
  }

  // Decrypt sensitive data
  static String decryptValue(String encryptedValue) {
    if (_encrypter == null || _iv == null) {
      throw Exception('Encryption not initialized');
    }
    return _encrypter!.decrypt64(encryptedValue, iv: _iv);
  }

  static Future<Database> _initDatabase() async {
    await _initEncryption();

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'card_advisor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Cards table
    await db.execute('''
      CREATE TABLE $tableCards (
        id TEXT PRIMARY KEY,
        nickname TEXT NOT NULL,
        cardholder_name TEXT NOT NULL,
        last_four TEXT NOT NULL,
        card_type TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        card_color TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Card features table (1 card has many features)
    await db.execute('''
      CREATE TABLE $tableCardFeatures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id TEXT NOT NULL,
        feature_name TEXT NOT NULL,
        feature_value TEXT,
        feature_category TEXT,
        FOREIGN KEY (card_id) REFERENCES $tableCards(id) ON DELETE CASCADE
      )
    ''');

    // Reward rates table
    await db.execute('''
      CREATE TABLE $tableRewardRates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id TEXT NOT NULL,
        category TEXT NOT NULL,
        rate REAL NOT NULL,
        is_rotating INTEGER DEFAULT 0,
        valid_from TEXT,
        valid_until TEXT,
        FOREIGN KEY (card_id) REFERENCES $tableCards(id) ON DELETE CASCADE,
        UNIQUE(card_id, category)
      )
    ''');

    // Card points table
    await db.execute('''
      CREATE TABLE $tableCardPoints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id TEXT NOT NULL,
        points_balance INTEGER DEFAULT 0,
        points_currency TEXT NOT NULL,
        points_value_cents REAL,
        last_updated TEXT NOT NULL,
        FOREIGN KEY (card_id) REFERENCES $tableCards(id) ON DELETE CASCADE,
        UNIQUE(card_id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
      'CREATE INDEX idx_features_card_id ON $tableCardFeatures(card_id)',
    );
    await db.execute(
      'CREATE INDEX idx_rates_card_id ON $tableRewardRates(card_id)',
    );
    await db.execute(
      'CREATE INDEX idx_rates_category ON $tableRewardRates(category)',
    );
    await db.execute(
      'CREATE INDEX idx_points_card_id ON $tableCardPoints(card_id)',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle future migrations here
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
