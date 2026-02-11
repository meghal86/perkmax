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

  /// Fuzzy match a category string to a RewardCategory
  RewardCategory matchCategory(String input) {
    // 1. Direct match check
    if (vendorCategoryMapping.containsKey(input)) {
      return vendorCategoryMapping[input]!;
    }

    final lower = input.toLowerCase();

    // 2. Keyword matching
    if (lower.contains('restaurant') ||
        lower.contains('food') ||
        lower.contains('cafe') ||
        lower.contains('coffee') ||
        lower.contains('bar')) {
      return RewardCategory.dining;
    }
    if (lower.contains('grocery') ||
        lower.contains('supermarket') ||
        lower.contains('market') ||
        lower.contains('whole foods') ||
        lower.contains('trader joe')) {
      return RewardCategory.groceries;
    }
    if (lower.contains('gas') ||
        lower.contains('fuel') ||
        lower.contains('station')) {
      return RewardCategory.gas;
    }
    if (lower.contains('travel') ||
        lower.contains('hotel') ||
        lower.contains('airline') ||
        lower.contains('flight') ||
        lower.contains('airport')) {
      return RewardCategory.travel;
    }
    if (lower.contains('drug') ||
        lower.contains('pharmacy') ||
        lower.contains('cvs') ||
        lower.contains('walgreens')) {
      return RewardCategory.drugstore;
    }
    if (lower.contains('online') || lower.contains('amazon')) {
      return RewardCategory.online;
    }
    if (lower.contains('department') ||
        lower.contains('clothing') ||
        lower.contains('shoe') ||
        lower.contains('wear') ||
        lower.contains('macy') ||
        lower.contains('nordstrom')) {
      // Could be general or online, let's say general for now unless we have a specific 'shopping' category
      // We don't have a specific 'fashion' category in the seed, so map to general or perhaps online if unclear.
      // Actually, checking RewardCategory enum context, 'general' is safer (1x/1.5x)
      return RewardCategory.general;
    }
    if (lower.contains('electronic') ||
        lower.contains('tech') ||
        lower.contains('best buy') ||
        lower.contains('apple')) {
      return RewardCategory.general; // Or specific if we add it
    }

    // Default
    return RewardCategory.general;
  }
}
