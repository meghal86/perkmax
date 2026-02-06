import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyCO8wHK9nhLCpfLuC9QlFFgIVdaa86lBbA'; // TODO: Move to secure storage
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? context,
  }) async {
    try {
      // Build context-aware prompt
      final prompt = _buildPrompt(message, context);

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          'I apologize, but I couldn\'t generate a response. Please try again.';
    } catch (e) {
      return 'Error communicating with AI: ${e.toString()}\n\nPlease check your API key configuration.';
    }
  }

  String _buildPrompt(String message, List<Map<String, String>>? context) {
    final buffer = StringBuffer();

    // System context
    buffer.writeln(
      '''You are PerkMax Advisor, an expert AI assistant specialized in credit card rewards optimization. 

Your role:
- Help users maximize credit card rewards and benefits
- Provide personalized recommendations based on spending patterns
- Explain annual fees, points values, and redemption strategies
- Suggest the best card for specific merchants or categories
- Be concise, friendly, and actionable

Keep responses brief (2-3 sentences max) and focused on credit card optimization.

''',
    );

    // Add conversation context if available
    if (context != null && context.isNotEmpty) {
      buffer.writeln('Recent conversation:');
      for (var msg in context) {
        buffer.writeln('${msg['role']}: ${msg['text']}');
      }
      buffer.writeln();
    }

    // User's current message
    buffer.writeln('User: $message');
    buffer.writeln('PerkMax Advisor:');

    return buffer.toString();
  }

  Future<String> getCreditCardAdvice({
    required String merchant,
    String? category,
  }) async {
    final prompt =
        '''What's the best credit card to use at $merchant${category != null ? ' (category: $category)' : ''}? 
Provide a brief recommendation with the card name and reward rate.''';

    return sendMessage(prompt);
  }

  Future<String> analyzeFees(List<String> cardNames) async {
    final prompt = '''I have these credit cards: ${cardNames.join(', ')}. 
Briefly analyze if the annual fees are worth it based on typical rewards.''';

    return sendMessage(prompt);
  }
}
