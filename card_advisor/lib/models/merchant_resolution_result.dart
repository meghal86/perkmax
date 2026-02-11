import 'package:card_advisor/models/merchant.dart';

enum ConfidenceBand { HIGH, MEDIUM, LOW }

class MerchantResolutionResult {
  final Merchant? merchant;
  final int confidenceScore;
  final ConfidenceBand confidenceBand;
  final String reason;
  final List<Merchant> alternatives;
  final bool usedAI;

  MerchantResolutionResult({
    this.merchant,
    required this.confidenceScore,
    required this.confidenceBand,
    required this.reason,
    required this.alternatives,
    this.usedAI = false,
  });

  @override
  String toString() {
    return 'Result(merchant: ${merchant?.name}, score: $confidenceScore, band: $confidenceBand, reason: $reason, ai: $usedAI)';
  }
}
