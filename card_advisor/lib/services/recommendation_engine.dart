import '../database/daos/cards_dao.dart';
import '../database/daos/user_wallet_dao.dart';
import '../database/daos/merchants_dao.dart';
import '../database/daos/spend_dao.dart';
import 'recommendation_result.dart';
import '../models/credit_card.dart'; // For RewardCategory enum if needed

class RecommendationEngine {
  final CardsDao cardsDao;
  final UserWalletDao userWalletDao;
  final MerchantsDao merchantsDao;
  final SpendDao spendDao;

  RecommendationEngine({
    required this.cardsDao,
    required this.userWalletDao,
    required this.merchantsDao,
    required this.spendDao,
  });

  Future<RecommendationResult?> recommendForMerchant({
    required String merchantId,
    double? amount,
  }) async {
    final merchant = await merchantsDao.getMerchantById(merchantId);
    if (merchant == null) return null; // Or handle unknown merchant

    return _recommend(
      merchantId: merchantId,
      merchantName: merchant['name'],
      category: merchant['category'], // e.g., 'groceries'
      mcc: merchant['mcc'],
      amount: amount,
    );
  }

  Future<RecommendationResult?> recommendForCategory({
    required String category,
    double? amount,
  }) async {
    return _recommend(
      merchantId: 'unknown',
      merchantName: 'Unknown Merchant', // Generic
      category: category,
      amount: amount,
    );
  }

  Future<RecommendationResult?> _recommend({
    required String merchantId,
    required String merchantName,
    required String? category,
    String? mcc,
    double? amount,
  }) async {
    final userCards = await userWalletDao.getUserCards();
    if (userCards.isEmpty) return null;

    RecommendationResult? bestCard;
    double maxScore = -1.0;

    for (var cardData in userCards) {
      final cardId = cardData['id'] as String;
      final cardName = cardData['product_name'] as String;

      // Fetch rewards for this card
      final rewards = await cardsDao.getRewardsForCard(cardId);

      // Calculate scores
      final double categoryScore = _calculateCategoryMatchScore(
        rewards,
        category,
        mcc,
      );
      // Simplify: spend pattern score based on previous visits
      final double spendPatternScore = await _calculateSpendPatternScore(
        cardId,
        category ?? 'general',
      );
      final double repeatMerchantScore = await _calculateRepeatMerchantScore(
        merchantId,
      );

      // Determine confidence
      final String confidence = _calculateConfidence(
        categoryScore,
        spendPatternScore,
        repeatMerchantScore,
      );

      // Estimate value (points multiplier)
      // For now, let's say 'categoryScore' effectively represents the earn rate * 20 (scale 0-100 where 5x = 100)
      // So estimatedEarnValue could be the raw multiplier
      final double earnMultiplier = categoryScore / 20.0;
      final double estimatedValue =
          (amount ?? 0) * (earnMultiplier / 100.0); // Simple % return value

      // Total weighted score for sorting/selection
      final double totalScore =
          (categoryScore * 0.6) +
          (spendPatternScore * 0.2) +
          (repeatMerchantScore * 0.2);

      if (totalScore > maxScore) {
        maxScore = totalScore;
        bestCard = RecommendationResult(
          cardId: cardId,
          cardName: cardName,
          confidenceBand: confidence,
          categoryMatchScore: categoryScore,
          spendPatternScore: spendPatternScore,
          repeatMerchantScore: repeatMerchantScore,
          estimatedEarnValue: estimatedValue,
          explanation: _generateExplanation(
            cardName,
            earnMultiplier,
            category,
            merchantName,
            repeatMerchantScore > 50,
          ),
        );
      }
    }

    return bestCard;
  }

  double _calculateCategoryMatchScore(
    List<Map<String, dynamic>> rewards,
    String? category,
    String? mcc,
  ) {
    double maxRate = 1.0; // Base 1x

    for (var r in rewards) {
      final rCategory = r['category'];
      final rMcc = r['mcc'];
      final rate = r['earn_rate'] as double;

      // Exact context match (e.g. if we had MCC specific logic)
      if (mcc != null && rMcc == mcc) {
        if (rate > maxRate) maxRate = rate;
      }

      // Category match
      if (category != null && rCategory == category) {
        if (rate > maxRate) maxRate = rate;
      }

      // Base match
      if (rCategory == 'all_other') {
        if (rate > maxRate) maxRate = rate;
      }
    }

    // Normalize to 0-100. Let's say 5x = 100, 1x = 20.
    return (maxRate * 20.0).clamp(0.0, 100.0);
  }

  Future<double> _calculateSpendPatternScore(
    String cardId,
    String category,
  ) async {
    // Logic: Has the user used this card for this category before?
    // Stubbed for now as we don't track *which* card was used in `spend` table yet (only merchant/amount)
    // To implement fully we'd need `spend.card_id`
    return 0.0;
  }

  Future<double> _calculateRepeatMerchantScore(String merchantId) async {
    final visits = await spendDao.getMerchantVisitCount(merchantId);
    // 0 visits = 0, 1 visit = 20, 5+ visits = 100
    if (visits == 0) return 0.0;
    if (visits == 1) return 20.0;
    if (visits >= 5) return 100.0;
    return (visits * 20.0).clamp(0.0, 100.0);
  }

  String _calculateConfidence(double s1, double s2, double s3) {
    int highCount = 0;
    if (s1 >= 75) highCount++;
    if (s2 >= 75) highCount++;
    if (s3 >= 75) highCount++;

    if (highCount == 3) return 'HIGH'; // Strict high
    if (highCount >= 1)
      return 'MED'; // Relaxed for 'MED' if mainly category match is high
    return 'LOW';
  }

  String _generateExplanation(
    String cardName,
    double multiplier,
    String? category,
    String merchantName,
    bool isRepeat,
  ) {
    final String multiplierStr =
        '${multiplier.toStringAsFixed(1)}x'; // e.g. "3.0x"
    final String catStr = category != null
        ? category.replaceAll('_', ' ')
        : 'general spend';

    if (isRepeat) {
      return '$cardName earns $multiplierStr on $catStr at $merchantName (a repeat spot for you).';
    }
    return '$cardName earns $multiplierStr on $catStr.';
  }
}
