# ✅ Standalone App Setup (No Python Backend!)

## 🎉 Good News!

**The app now works completely standalone!** No Python backend server needed.

## What Changed?

- ✅ **Before:** Flutter → Python Backend → OpenRouter API
- ✅ **Now:** Flutter → OpenRouter API (direct)

## Quick Setup (3 Steps)

### Step 1: Install Dependencies

```bash
flutter pub get
```

### Step 2: Configure API Key (Optional)

The API key is already configured, but if you want to use your own:

Edit `lib/config/api_config.dart`:

```dart
static const String openRouterApiKey = 'your-api-key-here';
```

Get your API key from: https://openrouter.ai/keys

### Step 3: Run the App

```bash
flutter run
```

**That's it!** The app works standalone. Just need internet connection for API calls.

## How It Works Now

```
User Input
  ↓
Flutter App (OpenRouterService)
  ↓
OpenRouter API (Direct HTTP call)
  ↓
DeepSeek AI Model
  ↓
Mermaid Flowchart Code
  ↓
Flutter WebView
  ↓
Visual Flowchart 🎉
```

## Benefits

- ✅ **No backend server needed** - works anywhere
- ✅ **Simpler setup** - just run Flutter app
- ✅ **Works on any device** - no network configuration needed
- ✅ **Faster** - one less hop in the request chain
- ✅ **More reliable** - fewer points of failure

## Configuration

All configuration is in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // API Key (get from https://openrouter.ai/keys)
  static const String openRouterApiKey = '...';
  
  // Model to use
  static const String model = 'deepseek/deepseek-chat';  // Free, no rate limits
  
  // Timeout
  static const int requestTimeout = 60;
}
```

## Available Models

You can change the model in `api_config.dart`:

- `deepseek/deepseek-chat` - **FREE**, recommended (no rate limits)
- `deepseek/deepseek-r1:free` - FREE, but rate-limited
- `google/gemini-flash-1.5` - FREE alternative
- `deepseek/deepseek-r1` - Paid, advanced reasoning
- `anthropic/claude-3-haiku` - Paid, excellent quality

## Troubleshooting

### "Error: API returned status code 429"
- Rate limit exceeded
- Solution: Wait a few minutes, or change model to `deepseek/deepseek-chat`

### "Error: Invalid API Key (401)"
- API key is wrong
- Solution: Check `lib/config/api_config.dart` and update the key

### "Error connecting..."
- No internet connection
- Solution: Check your internet connection

## Old Python Backend (Optional)

The Python backend is still in the `backend/` folder if you want to use it for testing, but it's **not required** for the app to work.

To use Python backend (optional):
```bash
python backend/deepseek_api.py server
```

But you don't need to! The app works standalone now. 🎉

