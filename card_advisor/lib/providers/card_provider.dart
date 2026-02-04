import 'package:flutter/foundation.dart';
import '../models/credit_card.dart';
import '../models/card_feature.dart';
import '../models/card_points.dart';
import '../services/card_repository.dart';

class CardProvider with ChangeNotifier {
  final CardRepository _repository = CardRepository();
  List<CreditCard> _cards = [];
  final Map<String, List<CardFeature>> _features = {};
  final Map<String, CardPoints?> _points = {};
  bool _isLoading = true;

  List<CreditCard> get cards => _cards;
  bool get isLoading => _isLoading;

  CardProvider() {
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _repository.getAllCards();

      // Load features and points for each card
      for (final card in _cards) {
        _features[card.id] = await _repository.getCardFeatures(card.id);
        _points[card.id] = await _repository.getCardPoints(card.id);
      }
    } catch (e) {
      debugPrint('Error loading cards: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(CreditCard card) async {
    await _repository.insertCard(card);
    _cards.add(card);
    _features[card.id] = [];
    _points[card.id] = null;
    notifyListeners();
  }

  Future<void> removeCard(String cardId) async {
    await _repository.deleteCard(cardId);
    _cards.removeWhere((c) => c.id == cardId);
    _features.remove(cardId);
    _points.remove(cardId);
    notifyListeners();
  }

  Future<void> updateCard(CreditCard updatedCard) async {
    await _repository.updateCard(updatedCard);
    final index = _cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      _cards[index] = updatedCard;
      notifyListeners();
    }
  }

  // ==================== FEATURES ====================

  List<CardFeature> getFeatures(String cardId) {
    return _features[cardId] ?? [];
  }

  Future<void> addFeature(CardFeature feature) async {
    final id = await _repository.addFeature(feature);
    final newFeature = feature.copyWith(id: id);
    _features[feature.cardId] ??= [];
    _features[feature.cardId]!.add(newFeature);
    notifyListeners();
  }

  Future<void> removeFeature(String cardId, int featureId) async {
    await _repository.deleteFeature(featureId);
    _features[cardId]?.removeWhere((f) => f.id == featureId);
    notifyListeners();
  }

  bool hasFeature(String cardId, String featureName) {
    return _features[cardId]?.any((f) => f.featureName == featureName) ?? false;
  }

  // Find all cards with a specific feature
  List<CreditCard> cardsWithFeature(String featureName) {
    return _cards.where((card) => hasFeature(card.id, featureName)).toList();
  }

  // ==================== POINTS ====================

  CardPoints? getPoints(String cardId) => _points[cardId];

  int get totalPointsBalance {
    return _points.values.fold(0, (sum, p) => sum + (p?.pointsBalance ?? 0));
  }

  double get totalPointsValue {
    return _points.values.fold(
      0.0,
      (sum, p) => sum + (p?.totalValueDollars ?? 0),
    );
  }

  Future<void> setPoints(CardPoints points) async {
    await _repository.setCardPoints(points);
    _points[points.cardId] = points;
    notifyListeners();
  }

  Future<void> updatePointsBalance(String cardId, int newBalance) async {
    await _repository.updatePointsBalance(cardId, newBalance);
    if (_points[cardId] != null) {
      _points[cardId] = _points[cardId]!.copyWith(
        pointsBalance: newBalance,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // ==================== QUERIES ====================

  /// Get cards sorted by reward rate for a specific category
  List<CreditCard> getCardsByCategory(RewardCategory category) {
    return List.from(_cards)..sort((a, b) {
      final rateA = a.rewardRates[category] ?? 0;
      final rateB = b.rewardRates[category] ?? 0;
      return rateB.compareTo(rateA);
    });
  }

  /// Get the best card for a category
  CreditCard? getBestCardForCategory(RewardCategory category) {
    if (_cards.isEmpty) return null;
    return getCardsByCategory(category).first;
  }

  /// Get cards with rate above threshold
  List<CreditCard> getCardsWithMinRate(
    RewardCategory category,
    double minRate,
  ) {
    return _cards.where((card) {
      final rate = card.rewardRates[category] ?? 0;
      return rate >= minRate;
    }).toList();
  }
}
