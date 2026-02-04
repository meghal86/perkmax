import '../models/credit_card.dart';
import '../models/chat_message.dart';

class AIChatService {
  final List<CreditCard> _userCards;

  AIChatService(this._userCards);

  Future<ChatMessage> getResponse(
    String userMessage,
    List<ChatMessage> history,
  ) async {
    // Simulated AI responses for purchase assistance
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerMessage = userMessage.toLowerCase();
    String response;

    if (lowerMessage.contains('buy') || lowerMessage.contains('purchase')) {
      response = _generatePurchaseAdvice(userMessage);
    } else if (lowerMessage.contains('card') && lowerMessage.contains('best')) {
      response = _generateBestCardAdvice();
    } else if (lowerMessage.contains('cashback') ||
        lowerMessage.contains('reward')) {
      response = _generateRewardsAdvice();
    } else if (lowerMessage.contains('travel') ||
        lowerMessage.contains('vacation')) {
      response = _generateTravelAdvice();
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      response = _generateGreeting();
    } else {
      response = _generateGeneralAdvice(userMessage);
    }

    return ChatMessage.assistant(response);
  }

  String _generateGreeting() {
    if (_userCards.isEmpty) {
      return "Hello! I'm your Credit Card Advisor AI. I can help you decide which card to use for purchases, maximize your rewards, and make smart financial decisions.\n\n"
          "It looks like you haven't added any cards yet. Head to the Cards tab to add your credit cards, then I can give you personalized recommendations!";
    }
    return "Hello! I'm your Credit Card Advisor AI. I can help you decide which card to use for purchases and maximize your rewards.\n\n"
        "You have ${_userCards.length} card(s) registered. Ask me about any purchase you're planning, and I'll suggest the best card to use!";
  }

  String _generatePurchaseAdvice(String message) {
    if (_userCards.isEmpty) {
      return "I'd love to help you with that purchase, but you haven't added any cards yet. Please add your credit cards first, and I'll be able to recommend the best one for your purchase.";
    }

    final buffer = StringBuffer();
    buffer.writeln("💳 **Purchase Analysis**\n");

    if (message.toLowerCase().contains('dining') ||
        message.toLowerCase().contains('restaurant') ||
        message.toLowerCase().contains('food')) {
      buffer.writeln("For dining purchases, here are your best options:\n");
      _addCardRecommendations(buffer, RewardCategory.dining);
    } else if (message.toLowerCase().contains('gas') ||
        message.toLowerCase().contains('fuel')) {
      buffer.writeln("For gas station purchases:\n");
      _addCardRecommendations(buffer, RewardCategory.gas);
    } else if (message.toLowerCase().contains('travel') ||
        message.toLowerCase().contains('flight') ||
        message.toLowerCase().contains('hotel')) {
      buffer.writeln("For travel-related purchases:\n");
      _addCardRecommendations(buffer, RewardCategory.travel);
    } else if (message.toLowerCase().contains('grocery') ||
        message.toLowerCase().contains('supermarket')) {
      buffer.writeln("For grocery purchases:\n");
      _addCardRecommendations(buffer, RewardCategory.groceries);
    } else {
      buffer.writeln("For general purchases:\n");
      _addCardRecommendations(buffer, RewardCategory.general);
    }

    buffer.writeln(
      "\n💡 **Tip**: Always pay your balance in full to maximize rewards without paying interest!",
    );

    return buffer.toString();
  }

  void _addCardRecommendations(StringBuffer buffer, RewardCategory category) {
    final sortedCards = List<CreditCard>.from(_userCards)
      ..sort(
        (a, b) =>
            b.getRewardRate(category).compareTo(a.getRewardRate(category)),
      );

    for (int i = 0; i < sortedCards.length && i < 3; i++) {
      final card = sortedCards[i];
      final rate = card.getRewardRate(category);
      final medal = i == 0 ? '🥇' : (i == 1 ? '🥈' : '🥉');
      buffer.writeln(
        "$medal **${card.cardNickname}** - ${rate.toStringAsFixed(1)}% cashback",
      );
    }
  }

  String _generateBestCardAdvice() {
    if (_userCards.isEmpty) {
      return "You haven't added any cards yet. Add your credit cards to get personalized recommendations on which card is best for different purchase categories.";
    }

    final buffer = StringBuffer();
    buffer.writeln("📊 **Your Best Cards by Category**\n");

    for (final category in RewardCategory.values) {
      final bestCard = _userCards.reduce(
        (a, b) => a.getRewardRate(category) > b.getRewardRate(category) ? a : b,
      );
      final categoryName =
          category.name[0].toUpperCase() + category.name.substring(1);
      buffer.writeln(
        "• **$categoryName**: ${bestCard.cardNickname} (${bestCard.getRewardRate(category).toStringAsFixed(1)}%)",
      );
    }

    return buffer.toString();
  }

  String _generateRewardsAdvice() {
    if (_userCards.isEmpty) {
      return "Add your credit cards to learn how to maximize your rewards! I can analyze your cards and tell you exactly where each one shines.";
    }

    return "🎯 **Maximizing Your Rewards**\n\n"
        "Here are some tips:\n\n"
        "1. **Match your spending**: Use the right card for each category\n"
        "2. **Check rotating categories**: Some cards offer quarterly bonus categories\n"
        "3. **Use shopping portals**: Many card issuers have bonus online portals\n"
        "4. **Pay in full**: Never carry a balance - interest eats your rewards\n"
        "5. **Track your rewards**: Don't let points expire!\n\n"
        "Ask me about any specific purchase, and I'll tell you the best card to use!";
  }

  String _generateTravelAdvice() {
    if (_userCards.isEmpty) {
      return "Planning a trip? Add your cards and I can help you determine the best ones for flights, hotels, and travel purchases.";
    }

    final buffer = StringBuffer();
    buffer.writeln("✈️ **Travel Purchase Strategy**\n");
    buffer.writeln("For your upcoming travel, consider:\n");

    _addCardRecommendations(buffer, RewardCategory.travel);

    buffer.writeln("\n**Pro Tips**:");
    buffer.writeln("• Book directly with airlines/hotels for max rewards");
    buffer.writeln("• Use cards with no foreign transaction fees abroad");
    buffer.writeln("• Check if your card offers travel insurance");

    return buffer.toString();
  }

  String _generateGeneralAdvice(String message) {
    return "I'm here to help you make smart credit card decisions! You can ask me:\n\n"
        "• \"What's the best card for [purchase type]?\"\n"
        "• \"I want to buy [item], which card should I use?\"\n"
        "• \"How can I maximize my cashback?\"\n"
        "• \"What are my best cards by category?\"\n\n"
        "Just describe what you're planning to purchase, and I'll analyze your cards to find the best option!";
  }
}
