import '../models/credit_card.dart';

class CardRecommendation {
  final CreditCard card;
  final double cashbackRate;
  final String reason;

  CardRecommendation({
    required this.card,
    required this.cashbackRate,
    required this.reason,
  });
}

class RecommendationService {
  static const Map<String, RewardCategory> vendorCategoryMapping = {
    'Restaurants': RewardCategory.dining,
    'Coffee Shops': RewardCategory.dining,
    'Fast Food': RewardCategory.dining,
    'Airlines': RewardCategory.travel,
    'Hotels': RewardCategory.travel,
    'Car Rental': RewardCategory.travel,
    'Gas Stations': RewardCategory.gas,
    'Supermarkets': RewardCategory.groceries,
    'Grocery Stores': RewardCategory.groceries,
    'Netflix': RewardCategory.streaming,
    'Spotify': RewardCategory.streaming,
    'Amazon': RewardCategory.online,
    'Online Shopping': RewardCategory.online,
    'Utilities': RewardCategory.utilities,
    'Electric': RewardCategory.utilities,
    'Water': RewardCategory.utilities,
    'General': RewardCategory.general,
  };

  List<CardRecommendation> getRecommendations({
    required List<CreditCard> cards,
    required RewardCategory category,
  }) {
    if (cards.isEmpty) return [];

    final recommendations = cards.map((card) {
      final rate = card.getRewardRate(category);
      return CardRecommendation(
        card: card,
        cashbackRate: rate,
        reason: _generateReason(card, category, rate),
      );
    }).toList();

    // Sort by cashback rate descending
    recommendations.sort((a, b) => b.cashbackRate.compareTo(a.cashbackRate));

    return recommendations;
  }

  String _generateReason(
    CreditCard card,
    RewardCategory category,
    double rate,
  ) {
    final categoryName =
        category.name[0].toUpperCase() + category.name.substring(1);
    if (rate >= 5) {
      return 'Excellent ${rate.toStringAsFixed(1)}% cashback on $categoryName!';
    } else if (rate >= 3) {
      return 'Great ${rate.toStringAsFixed(1)}% cashback on $categoryName purchases.';
    } else if (rate >= 2) {
      return 'Good ${rate.toStringAsFixed(1)}% cashback on $categoryName.';
    } else {
      return 'Standard ${rate.toStringAsFixed(1)}% cashback rate.';
    }
  }

  RewardCategory? getCategoryForVendor(String vendorType) {
    return vendorCategoryMapping[vendorType];
  }

  List<String> getVendorTypes() {
    return vendorCategoryMapping.keys.toList();
  }
}
