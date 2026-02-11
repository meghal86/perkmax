import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/widgets.dart';
import '../database/app_database.dart';
import '../database/daos/cards_dao.dart';
import 'card_seed_loader.dart';
import 'card_sync_service.dart';

// Top-level function for background execution
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize DB and Service in background isolate
    final dbHelper = DatabaseHelper.instance;
    final cardsDao = CardsDao(dbHelper: dbHelper);
    final seedLoader = CardSeedLoader(cardsDao: cardsDao);
    final service = CardSyncService(seedLoader: seedLoader);

    try {
      await service.syncCardData();
      return Future.value(true);
    } catch (e) {
      print('Background sync failed: $e');
      return Future.value(false);
    }
  });
}

class BackgroundSyncManager {
  static Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print(
        'Background sync not supported on Desktop target. Skipping Workmanager init.',
      );
      return;
    }
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // TODO: Set to false in production
    );
  }

  static Future<void> registerPeriodicTask() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) return;

    await Workmanager().registerPeriodicTask(
      "perkmax_card_sync",
      "syncCards",
      frequency: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
