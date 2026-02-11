import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

class UserWalletDao {
  final DatabaseHelper dbHelper;

  UserWalletDao({required this.dbHelper});

  Future<void> addToWallet(String cardId, String? nickname) async {
    final db = await dbHelper.database;
    await db.insert('user_wallet', {
      'card_id': cardId,
      'nickname': nickname,
      'added_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromWallet(String cardId) async {
    final db = await dbHelper.database;
    await db.delete('user_wallet', where: 'card_id = ?', whereArgs: [cardId]);
  }

  Future<List<Map<String, dynamic>>> getUserCards() async {
    final db = await dbHelper.database;
    // Join with cards table to get full details
    return await db.rawQuery('''
      SELECT c.*, w.nickname as user_nickname, w.added_at
      FROM user_wallet w
      INNER JOIN cards c ON w.card_id = c.id
    ''');
  }

  Future<bool> isCardInWallet(String cardId) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'user_wallet',
      where: 'card_id = ?',
      whereArgs: [cardId],
      limit: 1,
    );
    return results.isNotEmpty;
  }
}
