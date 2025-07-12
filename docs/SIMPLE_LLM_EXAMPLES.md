# Simple LLM Examples - Google Gemini AI

**Real Cloud-Based AI Mutation Testing with Google Gemini**

Get started with intelligent mutations in minutes - just get a free API key!

## ✨ Quick Start (2 Steps)

```bash
# 1. Get free API key from Google AI Studio (2 minutes)
# 2. Create config and run
echo '{
  "inputPaths": ["lib/"],
  "outputDir": "mutations",
  "mutationEngine": "llm",
  "llmConfig": {
    "apiKey": "your-free-api-key"
  }
}' > config.json && dart bin/smart_mutation.dart config.json
```

**Free API Key**: Get yours at [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

## 🎯 Simple Examples

### Example 1: Basic LLM Mutations
```json
{
  "inputPaths": ["lib/calculate.dart"],
  "outputDir": "mutations",
  "mutationEngine": "llm",
  "llmConfig": {
    "apiKey": "your-free-api-key"
  }
}
```

### Example 2: Hybrid Mode (Recommended)
```json
{
  "inputPaths": ["lib/"],
  "outputDir": "mutations", 
  "mutationEngine": "hybrid",
  "llmConfig": {
    "apiKey": "your-free-api-key"
  }
}
```

### Example 3: Custom Settings
```json
{
  "inputPaths": ["lib/"],
  "outputDir": "mutations",
  "mutationEngine": "llm",
  "llmConfig": {
    "apiKey": "your-free-api-key",
    "temperature": 0.5,
    "maxTokens": 500
  }
}
```

## 🚀 Google Gemini (Free)

| Model | Speed | Quality | Use Case |
|-------|-------|---------|----------|
| `gemini-pro` | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Default - Best for code |

**Free Limits:**
- 60 requests/minute
- 1,500 requests/day
- Forever free!

## 💡 Pro Tips

1. **Get API key first** - Takes 2 minutes at [aistudio.google.com](https://aistudio.google.com/app/apikey)
2. **Start with `hybrid`** - Best of both worlds
3. **Monitor quota** - Check usage in Google AI Studio
4. **Multiple runs** give different mutations

## 🔗 Free API Key Setup

```bash
# 1. Go to: https://aistudio.google.com/app/apikey
# 2. Sign in with Google (free)
# 3. Click "Create API Key"
# 4. Add to your config:
{
  "mutationEngine": "llm",
  "llmConfig": {
    "apiKey": "AIza...your-key-here"
  }
}
```

## 🎉 Real Example Output

**Before:**
```dart
int add(int a, int b) {
  return a + b;
}
```

**After (Gemini Generated):**
```dart
// Mutation 1: Off-by-one error
int add(int a, int b) {
  return a + b + 1;
}

// Mutation 2: Wrong operator
int add(int a, int b) {
  return a - b;
}

// Mutation 3: Edge case
int add(int a, int b) {
  return a * b;
}
```

**Real AI, real mutations, completely free!**