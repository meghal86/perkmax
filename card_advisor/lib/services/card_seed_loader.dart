import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../database/daos/cards_dao.dart';
import '../database/app_database.dart';

class CardSeedLoader {
  final CardsDao cardsDao;
  static const String _seedVersionKey = 'cards_seed_version';
  static const String _currentSeedVersion =
      '2023-10-27-v4'; // Update when JSON changes

  CardSeedLoader({required this.cardsDao});

  Future<void> loadSeedData() async {
    final db = await DatabaseHelper.instance.database;

    // Check if we already loaded this version
    final List<Map<String, dynamic>> result = await db.query(
      'metadata',
      where: 'key = ?',
      whereArgs: [_seedVersionKey],
    );

    String? currentDbVersion;
    if (result.isNotEmpty) {
      currentDbVersion = result.first['value'] as String;
    }

    if (currentDbVersion == _currentSeedVersion) {
      print('Seed data already up to date ($currentDbVersion). Skipping.');
      return;
    }

    print('Loading seed data version $_currentSeedVersion...');

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/cards_seed.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> cardsJson = jsonData['cards'];

      for (var cardJson in cardsJson) {
        final cardMap = {
          'id': cardJson['id'],
          'issuer': cardJson['issuer'],
          'product_name': cardJson['product_name'],
          'network': cardJson['network'],
          'annual_fee_cents': cardJson['annual_fee_cents'],
          'is_active': cardJson['is_active'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await cardsDao.insertCard(cardMap);

        final List<dynamic> rewardsJson = cardJson['rewards'];
        final List<Map<String, dynamic>> rewardsList = [];

        for (var reward in rewardsJson) {
          rewardsList.add({
            'id':
                '${cardJson['id']}_${reward['category']}_${reward['mcc'] ?? 'all'}',
            'card_id': cardJson['id'],
            'category': reward['category'],
            'mcc': reward['mcc'],
            'earn_rate': (reward['earn_rate'] as num).toDouble(),
            'cap_amount_cents': reward['cap_amount_cents'],
            'cap_period': reward['cap_period'],
          });
        }

        await cardsDao.insertCardRewards(cardJson['id'], rewardsList);
      }

      // Update version in metadata
      await db.insert('metadata', {
        'key': _seedVersionKey,
        'value': _currentSeedVersion,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      print('Seed data loaded successfully.');
    } catch (e) {
      print('Error loading seed data: $e');
      rethrow;
    }
  }
}
