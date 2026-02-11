import 'dart:math' as math;
import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/merchant.dart';

class MerchantsDao {
  final DatabaseHelper dbHelper;

  MerchantsDao({required this.dbHelper});

  Future<Map<String, dynamic>?> getMerchantById(String id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'merchants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertMerchant(Merchant merchant) async {
    final db = await dbHelper.database;
    await db.insert(
      'merchants',
      merchant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMerchant(String id) async {
    final db = await dbHelper.database;
    await db.delete('merchants', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllMerchants() async {
    final db = await dbHelper.database;
    return await db.query('merchants');
  }

  Future<List<Merchant>> getMerchantsInRadius({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    final db = await dbHelper.database;

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
      'merchants',
      where: 'lat BETWEEN ? AND ? AND lng BETWEEN ? AND ?',
      whereArgs: [minLat, maxLat, minLng, maxLng],
    );

    return List.generate(maps.length, (i) {
      return Merchant.fromMap(maps[i]);
    });
  }
}
