class CardPoints {
  final int? id;
  final String cardId;
  final int pointsBalance;
  final String pointsCurrency;
  final double? pointsValueCents; // value per point in cents
  final DateTime lastUpdated;

  CardPoints({
    this.id,
    required this.cardId,
    required this.pointsBalance,
    required this.pointsCurrency,
    this.pointsValueCents,
    required this.lastUpdated,
  });

  // Calculate total value in dollars
  double get totalValueDollars {
    if (pointsValueCents == null) return 0;
    return (pointsBalance * pointsValueCents!) / 100;
  }

  factory CardPoints.fromMap(Map<String, dynamic> map) {
    return CardPoints(
      id: map['id'] as int?,
      cardId: map['card_id'] as String,
      pointsBalance: map['points_balance'] as int? ?? 0,
      pointsCurrency: map['points_currency'] as String,
      pointsValueCents: map['points_value_cents'] as double?,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'card_id': cardId,
      'points_balance': pointsBalance,
      'points_currency': pointsCurrency,
      'points_value_cents': pointsValueCents,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  CardPoints copyWith({
    int? id,
    String? cardId,
    int? pointsBalance,
    String? pointsCurrency,
    double? pointsValueCents,
    DateTime? lastUpdated,
  }) {
    return CardPoints(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      pointsCurrency: pointsCurrency ?? this.pointsCurrency,
      pointsValueCents: pointsValueCents ?? this.pointsValueCents,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Common points currencies
class PointsCurrency {
  static const String chaseUR = 'Chase Ultimate Rewards';
  static const String amexMR = 'Amex Membership Rewards';
  static const String citiTYP = 'Citi ThankYou Points';
  static const String capitalOneM = 'Capital One Miles';
  static const String cashback = 'Cash Back';
  static const String deltaSkymiles = 'Delta SkyMiles';
  static const String unitedMiles = 'United Miles';
  static const String aaAdvantage = 'AAdvantage Miles';
  static const String marriottBonvoy = 'Marriott Bonvoy Points';
  static const String hiltonHonors = 'Hilton Honors Points';

  // Approximate value per point in cents
  static const Map<String, double> estimatedValues = {
    chaseUR: 2.0,
    amexMR: 2.0,
    citiTYP: 1.8,
    capitalOneM: 1.85,
    cashback: 1.0,
    deltaSkymiles: 1.2,
    unitedMiles: 1.3,
    aaAdvantage: 1.4,
    marriottBonvoy: 0.8,
    hiltonHonors: 0.5,
  };
}
