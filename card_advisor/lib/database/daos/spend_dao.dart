import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import 'package:uuid/uuid.dart';

class SpendDao {
  final DatabaseHelper dbHelper;

  SpendDao({required this.dbHelper});

  Future<void> logSpend({
    required String merchantId,
    required int amountCents,
    String? category,
    DateTime? timestamp,
  }) async {
    final db = await dbHelper.database;
    await db.insert('spend', {
      'id': const Uuid().v4(),
      'merchant_id': merchantId,
      'amount_cents': amountCents,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      'category': category,
    });
  }

  Future<List<Map<String, dynamic>>> getSpendForMerchant(
    String merchantId,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'spend',
      where: 'merchant_id = ?',
      whereArgs: [merchantId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getSpendForCategory(
    String category,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'spend',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'timestamp DESC',
    );
  }

  Future<int> getMerchantVisitCount(String merchantId) async {
    final db = await dbHelper.database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM spend WHERE merchant_id = ?',
            [merchantId],
          ),
        ) ??
        0;
  }
}
