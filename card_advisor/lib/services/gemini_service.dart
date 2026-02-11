import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:card_advisor/models/merchant.dart';
import 'dart:convert';

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
      print("GeminiService: sendMessage error: $e");
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

  Future<Map<String, dynamic>> disambiguateMerchant({
    required double lat,
    required double lng,
    required double accuracy,
    required List<Merchant> candidates,
  }) async {
    // 1. Construct the input JSON
    final inputJson = {
      "user_location": {"lat": lat, "lng": lng, "accuracy_m": accuracy},
      "candidate_merchants": candidates.map((m) => m.toMap()).toList(),
    };

    // 2. Build the system instruction and user prompt
    final prompt =
        '''
System Instruction:
You are an expert merchant resolution engine.
- Use only the given candidate list.
- Never invent new merchants or coordinates.
- Prefer closer merchants and ones with more visits.
- When ambiguous, explicitly say it and keep confidence MED/LOW.

Output Schema:
{
  "merchant_id": "string (id from candidates) or null if none match",
  "confidence_score": number (0-100),
  "confidence_band": "HIGH" | "MED" | "LOW",
  "reason": "string",
  "alternatives": [
    {
      "merchant_id": "string",
      "explanation": "string"
    }
  ]
}

Input:
${jsonEncode(inputJson)}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null) {
        return {
          "merchant_id": null,
          "confidence_score": 0,
          "confidence_band": "LOW",
          "reason": "No response from AI",
        };
      }

      // Clean up markdown code blocks if present
      final cleanText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleanText);
    } catch (e) {
      return {
        "merchant_id": null,
        "confidence_score": 0,
        "confidence_band": "LOW",
        "reason": "Error parsing AI response: $e",
      };
    }
  }

  Future<Map<String, String?>> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final prompt =
        '''
Identify the most likely address or place name for coordinates: $lat, $lat.
Return a simple JSON: {"name": "Place Name or Street", "street": "Street Address", "locality": "City"}.
If uncertain, just describe the location type (e.g. "Residential Area").
''';

    try {
      final response = await sendMessage(prompt);
      final cleanText = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      try {
        final json = jsonDecode(cleanText) as Map<String, dynamic>;
        return {
          "name": json['name'] as String?,
          "street": json['street'] as String?,
          "locality": json['locality'] as String?,
        };
      } catch (_) {
        // Fallback if not JSON
        return {
          "name": response.split('\n').first,
          "street": "",
          "locality": "",
        };
      }
    } catch (e) {
      print("GeminiService: Reverse geocode error: $e");
      return {};
    }
  }
}
