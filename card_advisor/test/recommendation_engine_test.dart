import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:card_advisor/database/daos/cards_dao.dart';
import 'package:card_advisor/database/daos/user_wallet_dao.dart';
import 'package:card_advisor/database/daos/merchants_dao.dart';
import 'package:card_advisor/database/daos/spend_dao.dart';
import 'package:card_advisor/services/recommendation_engine.dart';
import 'package:card_advisor/services/recommendation_result.dart';

// Import generated mocks
import 'recommendation_engine_test.mocks.dart';

@GenerateMocks([CardsDao, UserWalletDao, MerchantsDao, SpendDao])
void main() {
  late RecommendationEngine engine;
  late MockCardsDao mockCardsDao;
  late MockUserWalletDao mockUserWalletDao;
  late MockMerchantsDao mockMerchantsDao;
  late MockSpendDao mockSpendDao;

  setUp(() {
    mockCardsDao = MockCardsDao();
    mockUserWalletDao = MockUserWalletDao();
    mockMerchantsDao = MockMerchantsDao();
    mockSpendDao = MockSpendDao();

    engine = RecommendationEngine(
      cardsDao: mockCardsDao,
      userWalletDao: mockUserWalletDao,
      merchantsDao: mockMerchantsDao,
      spendDao: mockSpendDao,
    );
  });

  // Helper to create basic card data
  Map<String, dynamic> createCard(String id, String name) {
    return {'id': id, 'product_name': name};
  }

  // Helper to create reward rule
  Map<String, dynamic> createReward(
    String category,
    double rate, {
    String? mcc,
  }) {
    return {'category': category, 'earn_rate': rate, 'mcc': mcc};
  }

  test('recommendForCategory returns null if wallet is empty', () async {
    when(mockUserWalletDao.getUserCards()).thenAnswer((_) async => []);

    final result = await engine.recommendForCategory(category: 'dining');
    expect(result, isNull);
  });

  test('recommendForCategory picks highest earn rate card', () async {
    // Setup 2 cards
    when(mockUserWalletDao.getUserCards()).thenAnswer(
      (_) async => [
        createCard('card_a', 'Card A'),
        createCard('card_b', 'Card B'),
      ],
    );

    // Card A: 3x on dining
    when(mockCardsDao.getRewardsForCard('card_a')).thenAnswer(
      (_) async => [
        createReward('dining', 3.0),
        createReward('all_other', 1.0),
      ],
    );

    // Card B: 1x on dining (via all_other)
    when(
      mockCardsDao.getRewardsForCard('card_b'),
    ).thenAnswer((_) async => [createReward('all_other', 1.5)]);

    // Spend history stubs (0 visits/usage)
    // IMPORTANT: The engine calls _calculateSpendPatternScore and _calculateRepeatMerchantScore
    // We need to verify what mock calls are made.
    // _calculateSpendPatternScore currently returns 0.0 directly, so no DAO calls.
    // _calculateRepeatMerchantScore calls spendDao.getMerchantVisitCount.

    // recommendForCategory passes 'unknown' as merchantId
    when(mockSpendDao.getMerchantVisitCount(any)).thenAnswer((_) async => 0);

    final result = await engine.recommendForCategory(category: 'dining');

    expect(result, isNotNull);
    expect(result!.cardId, 'card_a');
    expect(result.categoryMatchScore, equals(60.0)); // 3.0 * 20 = 60
    // Card B score = 1.5 * 20 = 30.0
  });

  test('Confidence bands calculation', () async {
    when(
      mockUserWalletDao.getUserCards(),
    ).thenAnswer((_) async => [createCard('card_high', 'Card High')]);

    // Setup for High Score > 75
    // Category: 5x -> 100 score
    when(
      mockCardsDao.getRewardsForCard('card_high'),
    ).thenAnswer((_) async => [createReward('dining', 5.0)]);

    // Merchant visits: 5 -> 100 score
    when(
      mockSpendDao.getMerchantVisitCount('my_fav_restaurant'),
    ).thenAnswer((_) async => 5);

    // Mock merchant lookup
    when(
      mockMerchantsDao.getMerchantById('my_fav_restaurant'),
    ).thenAnswer((_) async => {'name': 'My Fav Rest', 'category': 'dining'});

    final result = await engine.recommendForMerchant(
      merchantId: 'my_fav_restaurant',
    );

    expect(result!.cardId, 'card_high');
    expect(
      result.confidenceBand,
      'MED',
    ); // 2 scores >= 75 (Cat=100, Merch=100, Spend=0). So HighCount=2 -> MED.
    // To get HIGH, we need all 3. SpendPattern is hardcoded to 0 currently.
  });
}
