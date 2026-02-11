import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/credit_card.dart';

class CardsDao {
  final DatabaseHelper dbHelper;

  CardsDao({required this.dbHelper});

  Future<List<Map<String, dynamic>>> getAllCards() async {
    final db = await dbHelper.database;
    return await db.query('cards');
  }

  Future<Map<String, dynamic>?> getCardById(String id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertCard(Map<String, dynamic> card) async {
    final db = await dbHelper.database;
    await db.insert(
      'cards',
      card,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCardRewards(
    String cardId,
    List<Map<String, dynamic>> rewards,
  ) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    // Clear existing rewards for this card to avoid duplicates/stale data
    batch.delete('card_rewards', where: 'card_id = ?', whereArgs: [cardId]);

    for (var reward in rewards) {
      batch.insert('card_rewards', reward);
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getRewardsForCard(String cardId) async {
    final db = await dbHelper.database;
    return await db.query(
      'card_rewards',
      where: 'card_id = ?',
      whereArgs: [cardId],
    );
  }
}
