class RecommendationResult {
  final String cardId;
  final String cardName;
  final String confidenceBand; // 'HIGH', 'MED', 'LOW'
  final double categoryMatchScore;
  final double spendPatternScore;
  final double repeatMerchantScore;
  final double estimatedEarnValue;
  final String explanation;

  RecommendationResult({
    required this.cardId,
    required this.cardName,
    required this.confidenceBand,
    required this.categoryMatchScore,
    required this.spendPatternScore,
    required this.repeatMerchantScore,
    required this.estimatedEarnValue,
    required this.explanation,
  });

  @override
  String toString() {
    return 'RecommendationResult(cardId: $cardId, confidence: $confidenceBand, explanation: $explanation)';
  }
}
