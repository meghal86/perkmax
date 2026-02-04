import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/credit_card.dart';

class CardStorageService {
  static const _storageKey = 'user_credit_cards';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<List<CreditCard>> loadCards() async {
    final jsonStr = await _storage.read(key: _storageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    return CreditCard.decodeCards(jsonStr);
  }

  Future<void> saveCards(List<CreditCard> cards) async {
    final jsonStr = CreditCard.encodeCards(cards);
    await _storage.write(key: _storageKey, value: jsonStr);
  }

  Future<void> addCard(CreditCard card) async {
    final cards = await loadCards();
    cards.add(card);
    await saveCards(cards);
  }

  Future<void> removeCard(String cardId) async {
    final cards = await loadCards();
    cards.removeWhere((c) => c.id == cardId);
    await saveCards(cards);
  }

  Future<void> updateCard(CreditCard updatedCard) async {
    final cards = await loadCards();
    final index = cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      cards[index] = updatedCard;
      await saveCards(cards);
    }
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _storageKey);
  }
}
