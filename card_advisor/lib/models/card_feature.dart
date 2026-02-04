class CardFeature {
  final int? id;
  final String cardId;
  final String featureName;
  final String? featureValue;
  final String? featureCategory;

  CardFeature({
    this.id,
    required this.cardId,
    required this.featureName,
    this.featureValue,
    this.featureCategory,
  });

  factory CardFeature.fromMap(Map<String, dynamic> map) {
    return CardFeature(
      id: map['id'] as int?,
      cardId: map['card_id'] as String,
      featureName: map['feature_name'] as String,
      featureValue: map['feature_value'] as String?,
      featureCategory: map['feature_category'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_id': cardId,
      'feature_name': featureName,
      'feature_value': featureValue,
      'feature_category': featureCategory,
    };
  }

  CardFeature copyWith({
    int? id,
    String? cardId,
    String? featureName,
    String? featureValue,
    String? featureCategory,
  }) {
    return CardFeature(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      featureName: featureName ?? this.featureName,
      featureValue: featureValue ?? this.featureValue,
      featureCategory: featureCategory ?? this.featureCategory,
    );
  }
}

// Common feature categories
class FeatureCategory {
  static const String travel = 'travel';
  static const String insurance = 'insurance';
  static const String shopping = 'shopping';
  static const String dining = 'dining';
  static const String entertainment = 'entertainment';
  static const String other = 'other';
}

// Common feature names
class FeatureNames {
  // Travel features
  static const String airportLounge = 'Airport Lounge Access';
  static const String travelInsurance = 'Travel Insurance';
  static const String tripCancellation = 'Trip Cancellation Protection';
  static const String noForeignTxFee = 'No Foreign Transaction Fee';
  static const String globalEntry = 'Global Entry Credit';
  static const String tsaPrecheck = 'TSA PreCheck Credit';

  // Shopping features
  static const String purchaseProtection = 'Purchase Protection';
  static const String extendedWarranty = 'Extended Warranty';
  static const String priceProtection = 'Price Protection';
  static const String returnProtection = 'Return Protection';

  // Insurance features
  static const String rentalCarInsurance = 'Rental Car Insurance';
  static const String cellPhoneProtection = 'Cell Phone Protection';
  static const String lostLuggageInsurance = 'Lost Luggage Insurance';

  // Dining & Entertainment
  static const String diningCredits = 'Dining Credits';
  static const String streamingCredits = 'Streaming Credits';
  static const String conciergeService = 'Concierge Service';

  // Other
  static const String annualFee = 'Annual Fee';
  static const String signupBonus = 'Signup Bonus';
  static const String apr = 'APR';
}
