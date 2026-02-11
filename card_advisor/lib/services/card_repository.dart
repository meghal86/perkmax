import 'package:sqflite/sqflite.dart';
import '../models/credit_card.dart';
import '../models/card_feature.dart';
import '../models/card_points.dart';
import 'database_service.dart';

class CardRepository {
  // ==================== CARDS ====================

  /// Insert a new card
  Future<void> insertCard(CreditCard card) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    await db.insert(DatabaseService.tableCards, {
      'id': card.id,
      'nickname': card.cardNickname,
      'cardholder_name': DatabaseService.encryptValue(card.cardholderName),
      'last_four': card.lastFourDigits,
      'card_type': card.cardType.name,
      'expiry_date': card.expiryDate,
      'card_color': card.cardColor,
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert reward rates
    for (final entry in card.rewardRates.entries) {
      await db.insert(
        DatabaseService.tableRewardRates,
        {'card_id': card.id, 'category': entry.key.name, 'rate': entry.value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get all cards with their reward rates
  Future<List<CreditCard>> getAllCards() async {
    final db = await DatabaseService.database;

    final cardMaps = await db.query(DatabaseService.tableCards);
    final cards = <CreditCard>[];

    for (final cardMap in cardMaps) {
      final cardId = cardMap['id'] as String;

      // Get reward rates for this card
      final rateMaps = await db.query(
        DatabaseService.tableRewardRates,
        where: 'card_id = ?',
        whereArgs: [cardId],
      );

      final rewardRates = <RewardCategory, double>{};
      for (final rateMap in rateMaps) {
        final category = RewardCategory.values.firstWhere(
          (c) => c.name == rateMap['category'],
          orElse: () => RewardCategory.general,
        );
        rewardRates[category] = (rateMap['rate'] as num).toDouble();
      }

      cards.add(
        CreditCard(
          id: cardId,
          cardNickname: cardMap['nickname'] as String,
          cardholderName: DatabaseService.decryptValue(
            cardMap['cardholder_name'] as String,
          ),
          lastFourDigits: cardMap['last_four'] as String,
          cardType: CardType.values.firstWhere(
            (t) => t.name == cardMap['card_type'],
            orElse: () => CardType.other,
          ),
          expiryDate: cardMap['expiry_date'] as String,
          cardColor: cardMap['card_color'] as String? ?? '0',
          issuer: 'Unknown',
          rewardRates: rewardRates,
        ),
      );
    }

    return cards;
  }

  /// Get a single card by ID
  Future<CreditCard?> getCardById(String cardId) async {
    final db = await DatabaseService.database;

    final cardMaps = await db.query(
      DatabaseService.tableCards,
      where: 'id = ?',
      whereArgs: [cardId],
    );

    if (cardMaps.isEmpty) return null;

    final cardMap = cardMaps.first;

    // Get reward rates
    final rateMaps = await db.query(
      DatabaseService.tableRewardRates,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );

    final rewardRates = <RewardCategory, double>{};
    for (final rateMap in rateMaps) {
      final category = RewardCategory.values.firstWhere(
        (c) => c.name == rateMap['category'],
        orElse: () => RewardCategory.general,
      );
      rewardRates[category] = (rateMap['rate'] as num).toDouble();
    }

    return CreditCard(
      id: cardId,
      cardNickname: cardMap['nickname'] as String,
      cardholderName: DatabaseService.decryptValue(
        cardMap['cardholder_name'] as String,
      ),
      lastFourDigits: cardMap['last_four'] as String,
      cardType: CardType.values.firstWhere(
        (t) => t.name == cardMap['card_type'],
        orElse: () => CardType.other,
      ),
      expiryDate: cardMap['expiry_date'] as String,
      cardColor: cardMap['card_color'] as String? ?? '0',
      rewardRates: rewardRates,
    );
  }

  /// Update a card
  Future<void> updateCard(CreditCard card) async {
    final db = await DatabaseService.database;

    await db.update(
      DatabaseService.tableCards,
      {
        'nickname': card.cardNickname,
        'cardholder_name': DatabaseService.encryptValue(card.cardholderName),
        'last_four': card.lastFourDigits,
        'card_type': card.cardType.name,
        'expiry_date': card.expiryDate,
        'card_color': card.cardColor,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [card.id],
    );

    // Update reward rates (delete and re-insert)
    await db.delete(
      DatabaseService.tableRewardRates,
      where: 'card_id = ?',
      whereArgs: [card.id],
    );

    for (final entry in card.rewardRates.entries) {
      await db.insert(DatabaseService.tableRewardRates, {
        'card_id': card.id,
        'category': entry.key.name,
        'rate': entry.value,
      });
    }
  }

  /// Delete a card (cascades to features, rates, points)
  Future<void> deleteCard(String cardId) async {
    final db = await DatabaseService.database;

    // Delete related data first (SQLite cascade may not work on all platforms)
    await db.delete(
      DatabaseService.tableCardFeatures,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
    await db.delete(
      DatabaseService.tableRewardRates,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
    await db.delete(
      DatabaseService.tableCardPoints,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );

    // Delete the card
    await db.delete(
      DatabaseService.tableCards,
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  // ==================== FEATURES ====================

  /// Add a feature to a card
  Future<int> addFeature(CardFeature feature) async {
    final db = await DatabaseService.database;
    return await db.insert(DatabaseService.tableCardFeatures, feature.toMap());
  }

  /// Get all features for a card
  Future<List<CardFeature>> getCardFeatures(String cardId) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableCardFeatures,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
    return maps.map((m) => CardFeature.fromMap(m)).toList();
  }

  /// Delete a feature
  Future<void> deleteFeature(int featureId) async {
    final db = await DatabaseService.database;
    await db.delete(
      DatabaseService.tableCardFeatures,
      where: 'id = ?',
      whereArgs: [featureId],
    );
  }

  /// Find cards with a specific feature
  Future<List<String>> findCardsWithFeature(String featureName) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableCardFeatures,
      columns: ['card_id'],
      where: 'feature_name = ?',
      whereArgs: [featureName],
      distinct: true,
    );
    return maps.map((m) => m['card_id'] as String).toList();
  }

  // ==================== POINTS ====================

  /// Set or update points for a card
  Future<void> setCardPoints(CardPoints points) async {
    final db = await DatabaseService.database;
    await db.insert(
      DatabaseService.tableCardPoints,
      points.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get points for a card
  Future<CardPoints?> getCardPoints(String cardId) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableCardPoints,
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
    if (maps.isEmpty) return null;
    return CardPoints.fromMap(maps.first);
  }

  /// Get all points (for total balance view)
  Future<List<CardPoints>> getAllPoints() async {
    final db = await DatabaseService.database;
    final maps = await db.query(DatabaseService.tableCardPoints);
    return maps.map((m) => CardPoints.fromMap(m)).toList();
  }

  /// Update points balance
  Future<void> updatePointsBalance(String cardId, int newBalance) async {
    final db = await DatabaseService.database;
    await db.update(
      DatabaseService.tableCardPoints,
      {
        'points_balance': newBalance,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
  }

  // ==================== REWARD RATES ====================

  /// Get best cards for a category (sorted by rate)
  Future<List<Map<String, dynamic>>> getBestCardsForCategory(
    String category, {
    int limit = 5,
  }) async {
    final db = await DatabaseService.database;
    return await db.rawQuery(
      '''
      SELECT c.*, r.rate 
      FROM ${DatabaseService.tableCards} c
      JOIN ${DatabaseService.tableRewardRates} r ON c.id = r.card_id
      WHERE r.category = ?
      ORDER BY r.rate DESC
      LIMIT ?
    ''',
      [category, limit],
    );
  }

  /// Get cards with rate above threshold
  Future<List<String>> getCardsWithMinRate(
    String category,
    double minRate,
  ) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableRewardRates,
      columns: ['card_id'],
      where: 'category = ? AND rate >= ?',
      whereArgs: [category, minRate],
    );
    return maps.map((m) => m['card_id'] as String).toList();
  }
}
