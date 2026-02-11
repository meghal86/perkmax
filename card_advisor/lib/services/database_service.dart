import 'package:card_advisor/models/merchant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:math' as math;

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
  static const String tableMerchants = 'merchants';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<void> _initEncryption() async {
    if (_encrypter != null) return;

    try {
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
    } catch (e) {
      print(
        "DatabaseService: Secure storage failed ($e). Using fallback DEV key.",
      );
      // Fallback for development/unsigned builds
      // WARNING: This key is not secure and should only be used for dev.
      // Constant key ensures data persists across restarts in dev.
      final key = encrypt.Key.fromUtf8('DEV_KEY_32_CHARS_MUST_BE_EXACT!!');
      final iv = encrypt.IV.fromUtf8('DEV_IV_16_CHARS!');

      _encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      _iv = iv;
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
      version: 4,
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

    // Merchants table
    await _createMerchantsTable(db);
  }

  static Future<void> _createMerchantsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableMerchants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        mcc TEXT NOT NULL,
        category TEXT NOT NULL,
        visit_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_merchants_lat_lng ON $tableMerchants(lat, lng)',
    );
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print("DatabaseService: onUpgrade old=\$oldVersion new=\$newVersion");
    if (oldVersion < 2) {
      await _createMerchantsTable(db);
    }
    if (oldVersion < 4) {
      print("DatabaseService: Dropping and recreating merchants table");
      await db.execute('DROP TABLE IF EXISTS $tableMerchants');
      await _createMerchantsTable(db);
    }
  }

  // Merchant Methods
  static Future<void> insertMerchant(Merchant merchant) async {
    final db = await database;
    await db.insert(
      tableMerchants,
      merchant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Merchant>> getMerchantsInRadius({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    final db = await database;

    // 1 degree of latitude is ~111km (111,000 meters)
    // 1 degree of longitude is ~111km * cos(lat)
    const metersPerLatDegree = 111000.0;
    final latDelta = radiusMeters / metersPerLatDegree;

    // Approximate longitude delta (using cosine of the latitude)
    // Add some buffer to the bounding box to be safe
    final lngDelta =
        radiusMeters /
        (metersPerLatDegree * math.cos(lat * math.pi / 180).abs());

    final minLat = lat - latDelta;
    final maxLat = lat + latDelta;
    final minLng = lng - lngDelta;
    final maxLng = lng + lngDelta;

    final List<Map<String, dynamic>> maps = await db.query(
      tableMerchants,
      where: 'lat BETWEEN ? AND ? AND lng BETWEEN ? AND ?',
      whereArgs: [minLat, maxLat, minLng, maxLng],
    );

    return List.generate(maps.length, (i) {
      return Merchant.fromMap(maps[i]);
    });
  }

  // Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
