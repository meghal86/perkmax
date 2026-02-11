import 'package:flutter/material.dart';
import '../models/credit_card.dart';
import '../models/card_feature.dart';
import '../models/card_points.dart';
import '../database/app_database.dart';
import '../database/daos/cards_dao.dart';
import '../database/daos/user_wallet_dao.dart';

class CardProvider with ChangeNotifier {
  late final CardsDao _cardsDao;
  late final UserWalletDao _userWalletDao;

  List<CreditCard> _cards = [];
  final Map<String, List<CardFeature>> _features = {};
  final Map<String, CardPoints?> _points = {};
  bool _isLoading = true;

  List<CreditCard> get cards => _cards;
  bool get isLoading => _isLoading;

  CardProvider() {
    final dbHelper = DatabaseHelper.instance;
    _cardsDao = CardsDao(dbHelper: dbHelper);
    _userWalletDao = UserWalletDao(dbHelper: dbHelper);
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCardsData = await _userWalletDao.getUserCards();
      final List<CreditCard> loadedCards = [];

      for (final data in userCardsData) {
        final cardId = data['id'] as String;
        final rewardsData = await _cardsDao.getRewardsForCard(cardId);

        loadedCards.add(_mapToCreditCard(data, rewardsData));
      }
      _cards = loadedCards;
    } catch (e) {
      debugPrint('Error loading cards: $e');
    }

    _isLoading = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<List<CreditCard>> getAvailableCards() async {
    try {
      final allCardsData = await _cardsDao.getAllCards();
      final List<CreditCard> allCards = [];

      for (final data in allCardsData) {
        final cardId = data['id'] as String;
        final rewardsData = await _cardsDao.getRewardsForCard(cardId);
        allCards.add(_mapToCreditCard(data, rewardsData));
      }
      return allCards;
    } catch (e) {
      debugPrint('Error loading all cards: $e');
      return [];
    }
  }

  CreditCard _mapToCreditCard(
    Map<String, dynamic> cardData,
    List<Map<String, dynamic>> rewardsData,
  ) {
    // Map rewards
    final Map<RewardCategory, double> rewardRates = {};
    for (final r in rewardsData) {
      final categoryStr = r['category'] as String?;
      final rate = (r['earn_rate'] as num?)?.toDouble() ?? 1.0;

      if (categoryStr != null) {
        final category = RewardCategory.values.firstWhere(
          (e) => e.name == categoryStr,
          orElse: () => RewardCategory.general,
        );
        rewardRates[category] = rate;
      }
    }

    // Map Card Type
    final network = (cardData['network'] as String? ?? 'other').toLowerCase();
    CardType type = CardType.other;
    if (network.contains('visa'))
      type = CardType.visa;
    else if (network.contains('master'))
      type = CardType.mastercard;
    else if (network.contains('amex') || network.contains('american'))
      type = CardType.amex;
    else if (network.contains('discover'))
      type = CardType.discover;

    // Determine color based on issuer (simple heuristic)
    String color = '#2C3E50'; // Default dark
    final issuer = (cardData['issuer'] as String? ?? '').toLowerCase();
    if (issuer.contains('chase'))
      color = '#114499';
    else if (issuer.contains('amex'))
      color = '#D4AF37'; // Gold-ish
    else if (issuer.contains('citi'))
      color = '#003B70';
    else if (issuer.contains('capital'))
      color = '#004D40';

    return CreditCard(
      id: cardData['id'] as String,
      issuer: cardData['issuer'] as String? ?? 'Unknown',
      cardholderName: 'Valued Member', // Default
      lastFourDigits: '••••', // Default
      expiryDate: '12/28', // Default
      cardType: type,
      cardNickname:
          cardData['user_nickname'] as String? ??
          cardData['product_name'] as String,
      cardColor: color,
      rewardRates: rewardRates,
    );
  }

  Future<void> addCard(CreditCard card) async {
    // 1. Insert into cards table (Custom card)
    await _cardsDao.insertCard({
      'id': card.id,
      'issuer': 'Custom',
      'product_name': card.cardNickname,
      'network': card.cardType.name,
      'annual_fee_cents': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'card_color': card.cardColor,
    });

    // 2. Insert rewards
    final List<Map<String, dynamic>> rewards = [];
    card.rewardRates.forEach((category, rate) {
      rewards.add({
        'card_id': card.id,
        'category': category.name,
        'earn_rate': rate,
        'reward_type': 'cashback', // Assume cashback for custom
      });
    });
    await _cardsDao.insertCardRewards(card.id, rewards);

    // 3. Add to wallet
    await _userWalletDao.addToWallet(card.id, card.cardNickname);

    // 4. Refresh
    await loadCards();
  }

  Future<void> addCardToWallet(String cardId) async {
    await _userWalletDao.addToWallet(cardId, null);
    await loadCards();
  }

  Future<void> removeCard(String cardId) async {
    await _userWalletDao.removeFromWallet(cardId);
    await loadCards();
  }

  // ==================== FEATURES & POINTS (STUBS) ====================
  // These would need separate tables or further expansion of the DB schema
  // For now, returning empty/defaults to satisfy UI

  List<CardFeature> getFeatures(String cardId) {
    return _features[cardId] ?? [];
  }

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

  // ==================== QUERIES ====================

  List<CreditCard> getCardsByCategory(RewardCategory category) {
    return List.from(_cards)..sort((a, b) {
      final rateA = a.rewardRates[category] ?? 0;
      final rateB = b.rewardRates[category] ?? 0;
      return rateB.compareTo(rateA);
    });
  }

  CreditCard? getBestCardForCategory(RewardCategory category) {
    if (_cards.isEmpty) return null;
    return getCardsByCategory(category).first;
  }
}
