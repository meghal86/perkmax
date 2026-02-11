import '../services/card_seed_loader.dart';

class CardSyncService {
  final CardSeedLoader seedLoader;

  CardSyncService({required this.seedLoader});

  Future<void> syncCardData() async {
    print('Starting card sync...');
    // Real implementation would fetch JSON from a remote URL here
    // For now, we reuse the seed loader logic which checks versioning
    // and only updates if necessary (simulated by updating assets)

    try {
      await seedLoader.loadSeedData();
      print('Card sync completed.');
    } catch (e) {
      print('Card sync failed: $e');
    }
  }
}
