# Gemini API Setup Guide

## Getting Your Gemini API Key

1. **Visit Google AI Studio**
   - Go to [https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account

2. **Create an API Key**
   - Click "Create API Key"
   - Select or create a Google Cloud project
   - Copy your API key

3. **Add API Key to the App**
   - Open `lib/services/gemini_service.dart`
   - Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:
   
   ```dart
   static const String _apiKey = 'your-actual-api-key-here';
   ```

## Important Security Notes

⚠️ **For Production**: The API key should NOT be hardcoded in the app!

### Recommended approach for production:
1. Store API key in environment variables
2. Use flutter_secure_storage to encrypt the key
3. Or use a backend API to proxy Gemini requests

### Quick Fix for Testing:
For now, hardcoding works fine for local testing. Just make sure:
- Never commit your API key to git
- Add `lib/services/gemini_service.dart` to `.gitignore` if needed

## Testing the Chatbot

1. Run the app: `flutter run -d macos`
2. Click the gold AI sparkle button in the center of the navigation bar
3. Ask questions like:
   - "What's the best card for groceries?"
   - "Should I keep my Amex Gold with the annual fee?"
   - "Which card gives best rewards at Starbucks?"

## Features

- **Real-time AI responses** powered by Gemini Pro
- **Context-aware** conversations (remembers last 3 exchanges)
- **Card optimization** focused prompts
- **Error handling** with friendly messages

## API Usage Limits

Gemini API free tier includes:
- 60 requests per minute
- 1,500 requests per day

Perfect for personal use!

## Troubleshooting

**Error: "Invalid API key"**
- Double-check you copied the full API key
- Ensure no extra spaces before/after the key

**Error: "Quota exceeded"**
- You've hit the free tier limit
- Wait until the next day or upgrade to paid tier

**Slow responses**
- Normal - Gemini can take 2-5 seconds to respond
- Shows typing indicator while waiting
