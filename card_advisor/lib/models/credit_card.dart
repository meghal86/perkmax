import 'dart:convert';

enum CardType { visa, mastercard, amex, discover, other }

enum RewardCategory {
  general,
  dining,
  drugstore,
  gas,
  groceries,
  online,
  rent,
  streaming,
  transit,
  travel,
  utilities,
  // Business
  advertising,
  officeSupply,
  shipping,
  telecom,
  // Shopping / Wholesale
  wholesaleClub,
  amazon,
  costco,
  // Travel Specifics
  airline,
  hotel,
  carRental,
  travelPortal,
  // Other
  mobileWallet,
  rotating,
  entertainment,
  military,
  medical,
  education,
  fitness,
  flexible, // For 'top spend' or 'user selected'
}

class CreditCard {
  final String id;
  final String issuer;
  final String cardholderName;
  final String lastFourDigits;
  final String expiryDate;
  final CardType cardType;
  final String cardNickname;
  final String cardColor;
  final Map<RewardCategory, double> rewardRates;

  CreditCard({
    required this.id,
    required this.issuer,
    required this.cardholderName,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.cardType,
    required this.cardNickname,
    required this.cardColor,
    required this.rewardRates,
  });

  double getRewardRate(RewardCategory category) {
    return rewardRates[category] ?? rewardRates[RewardCategory.general] ?? 1.0;
  }

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] as String,
      issuer: json['issuer'] as String? ?? 'Unknown',
      cardholderName: json['cardholderName'] as String,
      lastFourDigits: json['lastFourDigits'] as String,
      expiryDate: json['expiryDate'] as String,
      cardType: CardType.values.firstWhere(
        (e) => e.name == json['cardType'],
        orElse: () => CardType.other,
      ),
      cardNickname: json['cardNickname'] as String,
      cardColor: json['cardColor'] as String,
      rewardRates: (json['rewardRates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          RewardCategory.values.firstWhere(
            (e) => e.name == key,
            orElse: () => RewardCategory.general,
          ),
          (value as num).toDouble(),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'issuer': issuer,
      'cardholderName': cardholderName,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'cardType': cardType.name,
      'cardNickname': cardNickname,
      'cardColor': cardColor,
      'rewardRates': rewardRates.map((key, value) => MapEntry(key.name, value)),
    };
  }

  CreditCard copyWith({
    String? id,
    String? issuer,
    String? cardholderName,
    String? lastFourDigits,
    String? expiryDate,
    CardType? cardType,
    String? cardNickname,
    String? cardColor,
    Map<RewardCategory, double>? rewardRates,
  }) {
    return CreditCard(
      id: id ?? this.id,
      issuer: issuer ?? this.issuer,
      cardholderName: cardholderName ?? this.cardholderName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryDate: expiryDate ?? this.expiryDate,
      cardType: cardType ?? this.cardType,
      cardNickname: cardNickname ?? this.cardNickname,
      cardColor: cardColor ?? this.cardColor,
      rewardRates: rewardRates ?? this.rewardRates,
    );
  }

  static String encodeCards(List<CreditCard> cards) {
    return jsonEncode(cards.map((c) => c.toJson()).toList());
  }

  static List<CreditCard> decodeCards(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((e) => CreditCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
