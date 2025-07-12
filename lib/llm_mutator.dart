import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:smart_mutation/config_model.dart';

/// LLM-powered mutation engine for AI-generated mutations
class LLMMutator {
  final LLMConfig config;

  LLMMutator(this.config);

  /// Generate mutations using LLM
  Future<String?> generateMutations(
    String sourceCode, 
    List<String> mutationTypes, {
    String? filePath,
    int? startLine,
    int? endLine,
  }) async {
    try {
      print('🤖 Generating LLM-powered mutations using ${config.provider.name}/${config.model}');
      
      final prompt = _buildMutationPrompt(sourceCode, mutationTypes, filePath);
      final response = await _callLLM(prompt);
      
      if (response != null && response.isNotEmpty) {
        return _processMutationResponse(response, sourceCode);
      }
      
      print('⚠️  LLM generated empty response, falling back to rule-based mutations');
      return null;
    } catch (e) {
      print('❌ LLM mutation failed: $e');
      print('⚠️  Falling back to rule-based mutations');
      return null;
    }
  }

  /// Build the mutation prompt for the LLM
  String _buildMutationPrompt(String sourceCode, List<String> mutationTypes, String? filePath) {
    final customPrompt = config.customPrompt;
    if (customPrompt != null) {
      final optimizedCode = _optimizeSourceCode(sourceCode);
      return customPrompt
          .replaceAll('{source_code}', optimizedCode)
          .replaceAll('{mutation_types}', mutationTypes.join(', '))
          .replaceAll('{file_path}', filePath ?? 'unknown');
    }

    // Optimize the source code before sending to LLM
    final optimizedCode = _optimizeSourceCode(sourceCode);

    return '''
You are an expert Dart mutation testing assistant. Your task is to create intelligent mutations of the provided Dart code to test the effectiveness of the test suite.

MUTATION TYPES TO APPLY: ${mutationTypes.join(', ')}

CRITICAL RULES:
1. ACTUALLY CHANGE THE CODE - don't just add comments!
2. For arithmetic: change + to -, * to /, etc.
3. For relational: change < to <=, == to !=, etc.
4. For logical: change && to ||, ! to empty, etc.
5. For functionCall: swap function names, change parameters
6. For datatype: change types, constants, return values
7. Add comment "@ MUTATION: type" AFTER each actual change
8. Each mutation should break the original logic
9. Make subtle but meaningful changes that could reveal bugs
10. Return the COMPLETE mutated code with actual changes

EXAMPLES OF GOOD MUTATIONS:
- return a + b; → return a - b; // @ MUTATION: arithmetic
- if (x > 0) → if (x >= 0) // @ MUTATION: relational  
- math.sin(x) → math.cos(x) // @ MUTATION: functionCall
- return true; → return false; // @ MUTATION: datatype

ORIGINAL CODE:
```dart
$optimizedCode
```

Generate the COMPLETE code with ACTUAL mutations applied. Make real changes, not just comments!

MUTATED CODE:''';
  }

  /// Call the LLM API (Free Cloud-based AI)
  Future<String?> _callLLM(String prompt) async {
    return await _callGemini(prompt);
  }

  /// Call Google Gemini API (real cloud-based LLM)
  Future<String?> _callGemini(String prompt) async {
    final client = HttpClient();
    client.connectionTimeout = Duration(seconds: config.timeout);

    try {
      // Use Google Gemini free API
      final apiKey = config.apiKey ?? 'demo'; // Users can provide their own key
      final model = config.model.startsWith('gemini-') ? config.model : 'gemini-${config.model}';
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
      
      final request = await client.postUrl(Uri.parse(url));
      request.headers.contentType = ContentType.json;

      final requestBody = {
        'contents': [{
          'parts': [{
            'text': prompt
          }]
        }],
        'generationConfig': {
          'temperature': config.temperature,
          'maxOutputTokens': config.maxTokens,
          'topP': 0.95,
          'topK': 64,
        }
      };

      request.write(jsonEncode(requestBody));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        print('📤 Gemini API Response:');
        print('Status: ${response.statusCode}');
        print('Raw Response Body:');
        print(responseBody);
        print('─' * 60);
        
        final responseData = jsonDecode(responseBody) as Map<String, dynamic>;
        
        if (responseData.containsKey('candidates') && 
            responseData['candidates'] is List &&
            (responseData['candidates'] as List).isNotEmpty) {
          
          final candidate = (responseData['candidates'] as List)[0] as Map<String, dynamic>;
          if (candidate.containsKey('content') &&
              candidate['content']['parts'] is List &&
              (candidate['content']['parts'] as List).isNotEmpty) {
            
            final text = (candidate['content']['parts'] as List)[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              print('✨ Gemini AI generated intelligent mutation');
              return text.trim();
            }
          }
        }
        
        print('⚠️ Unexpected response format from Gemini: $responseData');
        return null;
      } else if (response.statusCode == 400) {
        final errorBody = await response.transform(utf8.decoder).join();
        if (errorBody.contains('API_KEY_INVALID') || errorBody.contains('PERMISSION_DENIED')) {
          print('❌ API key required for Gemini. Set your free API key from https://aistudio.google.com/app/apikey');
          print('💡 Add "apiKey": "your-key-here" to your llmConfig');
        } else {
          print('❌ Gemini API error: $errorBody');
        }
        return null;
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        print('❌ Gemini API error: ${response.statusCode} - $errorBody');
        return null;
      }
    } catch (e) {
      print('❌ Gemini connection error: $e');
      print('💡 Get your free API key from: https://aistudio.google.com/app/apikey');
      return null;
    } finally {
      client.close();
    }
  }

  /// Process the LLM response to extract clean code
  String _processMutationResponse(String response, String originalCode) {
    // Extract code blocks if present
    final codeBlockRegex = RegExp(r'```(?:dart)?\s*(.*?)\s*```', dotAll: true);
    final match = codeBlockRegex.firstMatch(response);
    
    if (match != null) {
      return match.group(1)?.trim() ?? response.trim();
    }
    
    // If no code blocks, clean up the response
    final lines = response.split('\n');
    final codeLines = <String>[];
    bool inCodeSection = false;
    
    for (final line in lines) {
      if (line.trim().toLowerCase().contains('mutated code') || 
          line.trim().toLowerCase().contains('mutation')) {
        inCodeSection = true;
        continue;
      }
      
      if (inCodeSection && line.trim().isNotEmpty) {
        // Skip explanation lines
        if (!line.trim().startsWith('//') || line.contains('@ MUTATION:')) {
          codeLines.add(line);
        }
      }
    }
    
    return codeLines.isEmpty ? response.trim() : codeLines.join('\n');
  }

  /// Generate hybrid mutations (LLM + rule-based)
  Future<String?> generateHybridMutations(
    String sourceCode,
    List<String> mutationTypes,
    String Function(String, List<String>) ruleBasedMutator, {
    String? filePath,
  }) async {
    print('🔍 Starting hybrid mutation generation...');
    
    // Try LLM first
    final llmResult = await generateMutations(sourceCode, mutationTypes, filePath: filePath);
    
    if (llmResult != null && llmResult.trim().isNotEmpty) {
      print('✅ LLM generated result (${llmResult.length} characters)');
      print('🔍 Validating LLM mutation...');
      
      // Validate LLM result by checking if it's significantly different
      if (_isValidMutation(sourceCode, llmResult)) {
        print('✅ LLM mutation validation PASSED - Using LLM-generated mutations');
        return llmResult;
      } else {
        print('❌ LLM mutation validation FAILED - reasons:');
        print('   - Length check: original=${sourceCode.length}, mutated=${llmResult.length}');
        print('   - Contains @ MUTATION: ${llmResult.contains('@ MUTATION:')}');
        print('   - Different from original: ${sourceCode.trim() != llmResult.trim()}');
      }
    } else {
      print('❌ LLM generated null or empty result');
    }
    
    // Fallback to rule-based
    print('🔄 Falling back to rule-based mutations');
    final ruleResult = ruleBasedMutator(sourceCode, mutationTypes);
    return ruleResult;
  }

  /// Validate if LLM mutation is significantly different from original
  bool _isValidMutation(String original, String mutated) {
    print('🔍 Validating mutation:');
    
    // Basic validation checks
    final lengthRatio = mutated.length / original.length;
    print('   Length ratio: ${lengthRatio.toStringAsFixed(2)} (mutated: ${mutated.length}, original: ${original.length})');
    
    if (lengthRatio < 0.1 || lengthRatio > 5.0) {
      print('   ❌ Length ratio out of range (0.1 - 5.0)');
      return false;
    }
    
    // Check if it contains mutation comments
    final hasMutationComments = mutated.contains('@ MUTATION:');
    final mutationCount = '@ MUTATION:'.allMatches(mutated).length;
    print('   Has mutation comments: $hasMutationComments (count: $mutationCount)');
    if (!hasMutationComments) {
      print('   ❌ No mutation comments found');
      return false;
    }
    
    // Check for actual code differences (not just comments)
    final originalLines = original.split('\n');
    final mutatedLines = mutated.split('\n');
    int actualChanges = 0;
    
    for (int i = 0; i < originalLines.length && i < mutatedLines.length; i++) {
      final origLine = originalLines[i].replaceAll(RegExp(r'//.*'), '').trim();
      final mutLine = mutatedLines[i].replaceAll(RegExp(r'//.*'), '').trim();
      
      if (origLine != mutLine && origLine.isNotEmpty && mutLine.isNotEmpty) {
        actualChanges++;
        print('   🔄 Line ${i + 1}: "$origLine" → "$mutLine"');
      }
    }
    
    print('   Actual code changes: $actualChanges');
    if (actualChanges < mutationCount / 2) {
      print('   ⚠️ Too few actual changes compared to mutation comments');
    }
    
    // Check if it's not identical to original
    final isDifferent = original.trim() != mutated.trim();
    print('   Is different from original: $isDifferent');
    if (!isDifferent) {
      print('   ❌ Identical to original');
      return false;
    }
    
    print('   ✅ All validation checks passed');
    return true;
  }

  /// Optimize source code before sending to LLM (preserving line structure)
  String _optimizeSourceCode(String sourceCode) {
    print('🔧 Optimizing source code for LLM...');
    
    // Split into lines for processing
    final lines = sourceCode.split('\n');
    final optimizedLines = <String>[];
    
    bool inMultiLineComment = false;
    
    for (String line in lines) {
      String processedLine = line;
      
      // Handle multi-line comments
      if (inMultiLineComment) {
        if (line.contains('*/')) {
          inMultiLineComment = false;
          processedLine = line.substring(line.indexOf('*/') + 2);
        } else {
          // Keep empty line to preserve line numbers
          optimizedLines.add('');
          continue;
        }
      }
      
      // Start of multi-line comment
      if (processedLine.contains('/*')) {
        inMultiLineComment = true;
        processedLine = processedLine.substring(0, processedLine.indexOf('/*'));
      }
      
      // Remove single-line comments (but preserve mutation comments)
      if (processedLine.contains('//')) {
        final commentIndex = processedLine.indexOf('//');
        final comment = processedLine.substring(commentIndex);
        
        // Keep mutation comments and important annotations
        if (comment.contains('@ MUTATION:') || 
            comment.contains('TODO') || 
            comment.contains('FIXME') ||
            comment.contains('NOTE')) {
          // Keep the comment
        } else {
          processedLine = processedLine.substring(0, commentIndex).trimRight();
        }
      }
      
      // Skip documentation comments but preserve line
      final trimmed = processedLine.trim();
      if (trimmed.startsWith('///')) {
        optimizedLines.add('');
        continue;
      }
      
      // Clean up whitespace but preserve the line
      processedLine = processedLine.replaceAll(RegExp(r'[ \t]+'), ' ');
      optimizedLines.add(processedLine);
    }
    
    final optimized = optimizedLines.join('\n');
    final originalLength = sourceCode.length;
    final optimizedLength = optimized.length;
    final reduction = ((originalLength - optimizedLength) / originalLength * 100).round();
    
    print('✅ Code optimized: ${originalLength} → ${optimizedLength} chars (${reduction}% reduction)');
    
    return optimized;
  }
}
