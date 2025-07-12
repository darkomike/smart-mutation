# LLM-Powered Mutation Testing Guide

## Overview

Smart Mutation now supports AI-powered mutation generation using **Google Gemini**, a free cloud-based LLM. This provides intelligent, context-aware mutations without requiring local setup.

## ✨ Benefits of Cloud-Based LLM

- **Zero Setup**: No local installation required
- **Free to Use**: Google Gemini provides free access with generous limits
- **Always Updated**: Access to latest Google AI models
- **No Hardware Requirements**: Works on any machine
- **Instant Start**: Just get a free API key and go

## 🚀 Quick Start

1. **Get your free API key** (2 minutes):
   - Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
   - Click "Create API Key"
   - Copy your free key

2. **Enable LLM mutations**:
```json
{
  "inputPaths": ["lib/"],
  "outputDir": "mutations",
  "mutationEngine": "llm",
  "llmConfig": {
    "apiKey": "your-free-api-key-here"
  }
}
```

3. **Run Smart Mutation**:
```bash
dart bin/smart_mutation.dart
```

That's it! The system will automatically:
- Use Google's free Gemini Pro model
- Generate intelligent mutations
- Provide detailed explanations

## ⚙️ Configuration Options

### Basic LLM Configuration
```json
{
  "mutationEngine": "llm",
  "llmConfig": {
    "provider": "gemini",
    "model": "gemini-pro",
    "apiKey": "your-free-api-key",
    "temperature": 0.7,
    "maxTokens": 1000
  }
}
```

### Hybrid Mode (Recommended)
```json
{
  "mutationEngine": "hybrid",
  "llmConfig": {
    "provider": "gemini",
    "model": "gemini-pro",
    "apiKey": "your-free-api-key"
  }
}
```

## 🤖 Available Models

### Google Gemini Models
- **gemini-pro** (Default) - Best for code mutations, free with generous limits
- **gemini-pro-vision** - For future image-based mutations

## 🔧 Advanced Configuration

### Performance Tuning
```json
{
  "llmConfig": {
    "temperature": 0.3,     // Lower = more deterministic
    "maxTokens": 500,       // Shorter responses
    "timeout": 15,          // Faster timeout
    "retryAttempts": 1      // Fewer retries
  }
}
```

### Custom Prompts
```json
{
  "llmConfig": {
    "customPrompt": "Create subtle but meaningful mutations for this Dart code that test edge cases:"
  }
}
```

## 📊 Mutation Engine Comparison

| Feature | Rule-Based | LLM | Hybrid |
|---------|------------|-----|--------|
| Setup | ✅ Instant | 🔑 API Key | 🔑 API Key |
| Speed | ⚡ Very Fast | 🐌 Moderate | ⚖️ Balanced |
| Intelligence | 📋 Basic | 🧠 High | 🎯 Best |
| Context Awareness | ❌ No | ✅ Yes | ✅ Yes |
| Cost | 💰 Free | 💰 Free | 💰 Free |

## 🔍 LLM Mutation Examples

### Before (Original Code)
```dart
int calculate(int a, int b) {
  return a + b;
}
```

### After (LLM-Generated Mutations)
```dart
// Mutation 1: Boundary condition
int calculate(int a, int b) {
  return a + b + 1;  // Off-by-one error
}

// Mutation 2: Logic error
int calculate(int a, int b) {
  return a - b;  // Wrong operation
}

// Mutation 3: Edge case
int calculate(int a, int b) {
  return a * b;  // Multiplication instead
}
```

## 🚨 Troubleshooting

### API Key Required
```
❌ API key required for Gemini. Set your free API key from https://aistudio.google.com/app/apikey
💡 Add "apiKey": "your-key-here" to your llmConfig
```
**Solution**: Get your free API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

### Rate Limiting
```
❌ Gemini API error: 429
```
**Solution**: 
1. Wait a few minutes (free tier has generous limits)
2. Reduce `maxTokens` to use less quota per request

### Connection Issues
```
❌ Gemini connection error
```
**Solution**: Check your internet connection and API key

## 💡 Best Practices

1. **Get API Key First**: Free and takes 2 minutes at [aistudio.google.com](https://aistudio.google.com/app/apikey)
2. **Use Hybrid Mode**: Best balance of speed and intelligence
3. **Start Small**: Begin with few files, then scale up
4. **Custom Prompts**: Tailor mutations to your specific needs
5. **Monitor Quota**: Free tier is generous but has limits

## 🔄 Fallback Behavior

If the LLM service is unavailable:
1. **Hybrid Mode**: Falls back to rule-based mutations
2. **LLM-Only Mode**: Reports the issue and skips mutations
3. **Graceful Degradation**: Never crashes your testing pipeline

## 🎯 Use Cases

- **Smart Testing**: Generate edge cases you might miss
- **Code Quality**: Find subtle logical errors
- **Documentation**: Get explanations for each mutation
- **Learning**: Understand different failure modes
- **CI/CD Integration**: Cloud-based testing with API key in secrets

## 🔗 Getting Your Free Google Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account (free)
3. Click "Create API Key"
4. Copy the key and add it to your configuration:

```json
{
  "llmConfig": {
    "apiKey": "AIza...your-key-here"
  }
}
```

**Free Tier Limits:**
- 60 requests per minute
- 1,500 requests per day
- Completely free forever

## 📈 Performance Tips

- **Optimize Prompts**: Shorter prompts = faster responses
- **Batch Processing**: Run multiple files efficiently
- **Use Timeouts**: Set reasonable timeout values
- **Monitor Usage**: Check your quota in Google AI Studio

## 🌟 Example Configurations

### Minimal Setup
```json
{
  "inputPaths": ["lib/"],
  "outputDir": "mutations",
  "mutationEngine": "llm",
  "llmConfig": {
    "apiKey": "your-free-api-key"
  }
}
```

### Production Setup
```json
{
  "inputPaths": ["lib/", "src/"],
  "outputDir": "docs/mutations",
  "mutationEngine": "hybrid",
  "llmConfig": {
    "provider": "gemini",
    "model": "gemini-pro",
    "apiKey": "your-free-api-key",
    "temperature": 0.3,
    "maxTokens": 500,
    "timeout": 20
  },
  "parallel": true,
  "verbose": true
}
```

### Fast Testing
```json
{
  "inputPaths": ["lib/"],
  "outputDir": "mutations",
  "mutationEngine": "hybrid",
  "llmConfig": {
    "apiKey": "your-free-api-key",
    "temperature": 0.5,
    "maxTokens": 200,
    "timeout": 10
  }
}
```

Google Gemini makes AI-powered mutation testing accessible to everyone with a simple, free API key!