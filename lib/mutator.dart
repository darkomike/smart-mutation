import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:smart_mutation/config_model.dart';
import 'package:smart_mutation/llm_mutator.dart';

/// Enum to define different types of mutations
enum MutationType {
  arithmetic,
  logical,
  datatype,
  functionCall,
  relational,
  conditional,
  increment,
  assignment;

  /// Returns a human-readable name for the mutation type
  String get displayName => name;
}

/// Immutable class to define mutation rules
class MutationRule {
  const MutationRule({
    required this.type,
    required this.mutations,
    this.pattern,
  });

  final MutationType type;
  final Map<String, List<String>> mutations;
  final RegExp? pattern;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MutationRule &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

/// Result of a mutation operation
class MutatedResult {
  const MutatedResult({
    required this.mutatedCode,
    required this.mutationType,
    this.outputPath,
  });

  final String mutatedCode;
  final MutationType mutationType;
  final String? outputPath;

  @override
  String toString() => 'MutatedResult(type: $mutationType, hasOutput: ${outputPath != null})';
}

/// Test result for mutation testing
class MutationTestResult {
  const MutationTestResult({
    required this.mutationType,
    required this.testPassed,
    required this.testOutput,
    this.mutationFile,
    this.executionTime,
  });

  final MutationType mutationType;
  final bool testPassed;
  final String testOutput;
  final String? mutationFile;
  final Duration? executionTime;

  bool get mutationDetected => !testPassed;

  @override
  String toString() => 'MutationTestResult(type: $mutationType, detected: $mutationDetected)';
}

/// Configuration for mutation operations
class MutationConfig {
  const MutationConfig({
    this.startLine,
    this.endLine,
    this.outputFilePath,
    this.trackMutations = false,
    this.verbose = false,
  });

  final int? startLine;
  final int? endLine;
  final String? outputFilePath;
  final bool trackMutations;
  final bool verbose;
}

/// Result of cumulative mutation operations
class CumulativeMutationResult {
  const CumulativeMutationResult({
    required this.mutatedCode,
    required this.mutationCount,
    required this.mutationTypes,
  });

  final String mutatedCode;
  final int mutationCount;
  final List<MutationType> mutationTypes;
}

/// Main mutator class with optimized performance and better error handling
class Mutator {
  /// Cache for compiled regex patterns to improve performance
  static final Map<String, RegExp> _regexCache = <String, RegExp>{};

  /// Thread-safe regex compilation with caching
  static RegExp _getRegex(String pattern) {
    return _regexCache.putIfAbsent(pattern, () => RegExp(pattern));
  }

  /// Perform mutation using specified engine (rule-based, LLM, or hybrid)
  Future<String?> performMutationWithEngine(
    String sourceCode,
    List<String> mutationTypes, {
    MutationEngine engine = MutationEngine.ruleBased,
    LLMConfig? llmConfig,
    String? filePath,
    int? startLine,
    int? endLine,
    bool trackMutations = false,
  }) async {
    if (sourceCode.isEmpty || mutationTypes.isEmpty) return null;

    try {
      switch (engine) {
        case MutationEngine.llm:
          final effectiveConfig = llmConfig ?? LLMConfig.defaultLocal;
          final llmMutator = LLMMutator(effectiveConfig);
          return await llmMutator.generateMutations(sourceCode, mutationTypes, filePath: filePath, startLine: startLine, endLine: endLine);

        case MutationEngine.hybrid:
          final effectiveConfig = llmConfig ?? LLMConfig.defaultLocal;
          final llmMutator = LLMMutator(effectiveConfig);
          return await llmMutator.generateHybridMutations(
            sourceCode, 
            mutationTypes, 
            (code, types) => _performRuleBasedMutation(code, types, startLine: startLine, endLine: endLine, trackMutations: trackMutations),
            filePath: filePath,
          );

        case MutationEngine.ruleBased:
        default:
          return _performRuleBasedMutation(sourceCode, mutationTypes, startLine: startLine, endLine: endLine, trackMutations: trackMutations);
      }
    } catch (e) {
      print('❌ Mutation failed: $e');
      print('🔄 Falling back to rule-based mutations');
      return _performRuleBasedMutation(sourceCode, mutationTypes, startLine: startLine, endLine: endLine);
    }
  }

  /// Internal rule-based mutation implementation
  String _performRuleBasedMutation(
    String sourceCode,
    List<String> mutationTypes, {
    int? startLine,
    int? endLine,
    bool trackMutations = false,
  }) {
    final rules = _getMutationRulesForTypes(mutationTypes);
    if (trackMutations) {
      return performMutationWithTracking(sourceCode, rules, startLine: startLine, endLine: endLine) ?? sourceCode;
    } else {
      return performMutation(sourceCode, rules, startLine: startLine, endLine: endLine) ?? sourceCode;
    }
  }

  /// Get mutation rules for specified types
  List<MutationRule> _getMutationRulesForTypes(List<String> mutationTypes) {
    final allRules = <MutationRule>[];
    
    for (final type in mutationTypes) {
      switch (type.toLowerCase()) {
        case 'arithmetic':
          allRules.addAll(getArithmeticRules());
          break;
        case 'logical':
          allRules.addAll(getLogicalRules());
          break;
        case 'relational':
          allRules.addAll(getRelationalRules());
          break;
        case 'datatype':
          allRules.addAll(getDatatypeRules());
          break;
        case 'increment':
          allRules.addAll(getIncrementRules());
          break;
        case 'functioncall':
          allRules.addAll(getFunctionCallRules());
          break;
      }
    }
    
    return allRules;
  }

  /// Legacy mutate method - maintained for backward compatibility
  @Deprecated('Use performMutation or performMultipleMutations instead')
  void mutate(String filePath) {
    final code = File(filePath).readAsStringSync();
    final mutation = performMutation(code, getArithmeticRules());
    
    if (mutation != null) {
      File('mutated_$filePath').writeAsStringSync(mutation);
    }
  }

  /// Optimized mutation function with better error handling and configuration
  String? performMutation(
    String sourceCode,
    List<MutationRule> mutationRules, {
    int? startLine,
    int? endLine,
    String? outputFilePath,
  }) {
    if (sourceCode.isEmpty || mutationRules.isEmpty) return null;

    var codeToMutate = sourceCode;
    
    // Handle line range extraction more efficiently
    if (startLine != null && endLine != null) {
      final lines = sourceCode.split('\n');
      if (_isValidLineRange(startLine, endLine, lines.length)) {
        final selectedLines = lines.sublist(startLine - 1, endLine);
        codeToMutate = selectedLines.join('\n');
      } else {
        if (outputFilePath != null) {
          print('Warning: Invalid line range [$startLine-$endLine]. Using entire source code.');
        }
      }
    }

    // Apply mutations with early return on first successful mutation
    for (final rule in mutationRules) {
      final mutatedCode = _applyMutationRule(codeToMutate, rule);
      if (mutatedCode != null) {
        // Reconstruct full source if line range was used
        final finalCode = _reconstructFullSource(
          sourceCode, mutatedCode, startLine, endLine);
        
        // Write output file if specified
        if (outputFilePath != null) {
          try {
            File(outputFilePath).writeAsStringSync(finalCode);
          } catch (e) {
            print('Warning: Failed to write to $outputFilePath: $e');
          }
        }
        
        return finalCode;
      }
    }
    
    return null;
  }

  /// Enhanced performMutation with mutation tracking comments
  String? performMutationWithTracking(
    String sourceCode,
    List<MutationRule> mutationRules, {
    int? startLine,
    int? endLine,
    String? outputFilePath,
  }) {
    final result = performMutation(sourceCode, mutationRules, 
        startLine: startLine, endLine: endLine);
    
    if (result != null && mutationRules.isNotEmpty) {
      final trackedResult = _addMutationComment(sourceCode, result, mutationRules.first.type);
      
      if (outputFilePath != null) {
        try {
          File(outputFilePath).writeAsStringSync(trackedResult);
        } catch (e) {
          print('Warning: Failed to write tracked result to $outputFilePath: $e');
        }
      }
      
      return trackedResult;
    }
    
    return result;
  }

  /// Optimized cumulative mutations with better tracking
  String? performCumulativeMutations(
    String sourceCode,
    List<MutationRule> mutationRules, {
    int? startLine,
    int? endLine,
    String? outputFilePath,
    bool trackMutations = false,
  }) {
    if (sourceCode.isEmpty || mutationRules.isEmpty) return null;

    var currentCode = sourceCode;
    final lineToMutations = <int, Set<MutationType>>{};
    
    // Group rules by type for efficiency
    final rulesByType = <MutationType, List<MutationRule>>{};
    for (final rule in mutationRules) {
      rulesByType.putIfAbsent(rule.type, () => []).add(rule);
    }
    
    // Apply mutations cumulatively with tracking
    for (final entry in rulesByType.entries) {
      final type = entry.key;
      final rulesForType = entry.value;
      final beforeMutation = currentCode;
      
      final mutatedCode = performMutation(
        currentCode, 
        rulesForType,
        startLine: startLine,
        endLine: endLine,
      );
      
      if (mutatedCode != null) {
        // Track affected lines efficiently
        _trackAffectedLines(beforeMutation, mutatedCode, type, lineToMutations);
        currentCode = mutatedCode;
      }
    }
    
    // Add tracking comments if requested and mutations were applied
    if (trackMutations && lineToMutations.isNotEmpty) {
      currentCode = _addSpecificTrackingComments(currentCode, lineToMutations);
    }
    
    // Write output file if mutations were applied
    if (lineToMutations.isNotEmpty) {
      if (outputFilePath != null) {
        try {
          File(outputFilePath).writeAsStringSync(currentCode);
        } catch (e) {
          print('Warning: Failed to write cumulative result to $outputFilePath: $e');
        }
      }
      return currentCode;
    }
    
    return null;
  }

  /// Optimized cumulative mutations with detailed tracking
  CumulativeMutationResult? performCumulativeMutationsWithCount(
    String sourceCode,
    List<MutationRule> mutationRules, {
    int? startLine,
    int? endLine,
    String? outputFilePath,
    bool trackMutations = false,
  }) {
    if (sourceCode.isEmpty || mutationRules.isEmpty) return null;

    var currentCode = sourceCode;
    final lineToMutations = <int, Set<MutationType>>{};
    final appliedMutationTypes = <MutationType>[];
    
    // Group rules by type for efficiency
    final rulesByType = <MutationType, List<MutationRule>>{};
    for (final rule in mutationRules) {
      rulesByType.putIfAbsent(rule.type, () => []).add(rule);
    }
    
    // Apply mutations cumulatively with tracking
    for (final entry in rulesByType.entries) {
      final type = entry.key;
      final rulesForType = entry.value;
      final beforeMutation = currentCode;
      
      final mutatedCode = performMutation(
        currentCode, 
        rulesForType,
        startLine: startLine,
        endLine: endLine,
      );
      
      if (mutatedCode != null) {
        // Track affected lines efficiently
        _trackAffectedLines(beforeMutation, mutatedCode, type, lineToMutations);
        appliedMutationTypes.add(type);
        currentCode = mutatedCode;
      }
    }
    
    // Add tracking comments if requested and mutations were applied
    if (trackMutations && lineToMutations.isNotEmpty) {
      currentCode = _addSpecificTrackingComments(currentCode, lineToMutations);
    }
    
    // Write output file if mutations were applied
    if (lineToMutations.isNotEmpty) {
      if (outputFilePath != null) {
        try {
          File(outputFilePath).writeAsStringSync(currentCode);
        } catch (e) {
          print('Warning: Failed to write cumulative result to $outputFilePath: $e');
        }
      }
      
      // Count total mutations by counting mutation comments in the final code
      final mutationCommentCount = '@ MUTATION:'.allMatches(currentCode).length;
      final totalMutations = mutationCommentCount > 0 ? mutationCommentCount : lineToMutations.values
          .map((mutations) => mutations.length)
          .fold(0, (sum, count) => sum + count);
    
      return CumulativeMutationResult(
        mutatedCode: currentCode,
        mutationCount: totalMutations,
        mutationTypes: appliedMutationTypes,
      );
    }
    
    return null;
  }

  /// Generate multiple mutations efficiently
  List<MutatedResult> performMultipleMutations(
    String sourceCode,
    List<MutationRule> mutationRules, {
    int? startLine,
    int? endLine,
    String? outputBasePath,
    bool trackMutations = false,
  }) {
    if (sourceCode.isEmpty || mutationRules.isEmpty) return [];

    final results = <MutatedResult>[];
    
    // Group rules by type to avoid duplicate mutations
    final rulesByType = <MutationType, List<MutationRule>>{};
    for (final rule in mutationRules) {
      rulesByType.putIfAbsent(rule.type, () => []).add(rule);
    }
    
    // Generate mutations in parallel where possible
    for (final entry in rulesByType.entries) {
      final type = entry.key;
      final rulesForType = entry.value;
      
      final mutatedCode = trackMutations
          ? performMutationWithTracking(
              sourceCode, 
              rulesForType,
              startLine: startLine,
              endLine: endLine,
            )
          : performMutation(
              sourceCode, 
              rulesForType,
              startLine: startLine,
              endLine: endLine,
            );
      
      if (mutatedCode != null) {
        String? outputPath;
        
        if (outputBasePath != null) {
          final baseName = outputBasePath.replaceAll('.dart', '');
          outputPath = '${baseName}_${type.displayName}_mutated.dart';
          
          try {
            File(outputPath).writeAsStringSync(mutatedCode);
          } catch (e) {
            print('Warning: Failed to write ${type.displayName} mutation to $outputPath: $e');
            outputPath = null;
          }
        }
        
        results.add(MutatedResult(
          mutatedCode: mutatedCode,
          mutationType: type,
          outputPath: outputPath,
        ));
      }
    }
    
    return results;
  }

  /// Helper method to validate line ranges
  bool _isValidLineRange(int startLine, int endLine, int totalLines) {
    return startLine >= 1 && 
           endLine <= totalLines && 
           startLine <= endLine;
  }

  /// Helper method to reconstruct full source code after line-range mutation
  String _reconstructFullSource(
    String originalSource, 
    String mutatedCode, 
    int? startLine, 
    int? endLine
  ) {
    if (startLine == null || endLine == null) return mutatedCode;
    
    final originalLines = originalSource.split('\n');
    final mutatedLines = mutatedCode.split('\n');
    
    // Validate line ranges to prevent index errors
    if (startLine < 1 || endLine > originalLines.length || startLine > endLine) {
      return mutatedCode; // Return mutated code as-is if ranges are invalid
    }
    
    // Replace the specified lines with mutated versions
    for (var i = 0; i < mutatedLines.length; i++) {
      final lineIndex = startLine - 1 + i;
      if (lineIndex >= 0 && lineIndex < originalLines.length) {
        originalLines[lineIndex] = mutatedLines[i];
      }
    }
    
    return originalLines.join('\n');
  }

  /// Helper method to track which lines were affected by mutations
  void _trackAffectedLines(
    String beforeCode, 
    String afterCode, 
    MutationType type,
    Map<int, Set<MutationType>> lineToMutations
  ) {
    final beforeLines = beforeCode.split('\n');
    final afterLines = afterCode.split('\n');
    
    final maxLength = beforeLines.length > afterLines.length 
        ? beforeLines.length 
        : afterLines.length;
    
    for (var i = 0; i < maxLength; i++) {
      final beforeLine = i < beforeLines.length ? beforeLines[i] : '';
      final afterLine = i < afterLines.length ? afterLines[i] : '';
      
      if (beforeLine != afterLine) {
        lineToMutations.putIfAbsent(i, () => <MutationType>{}).add(type);
      }
    }
  }

  /// Add mutation tracking comment to show where changes occurred
  String _addMutationComment(String originalCode, String mutatedCode, MutationType mutationType) {
    final originalLines = originalCode.split('\n');
    final mutatedLines = mutatedCode.split('\n');
    
    // Find the first line where mutation occurred
    for (var i = 0; i < mutatedLines.length && i < originalLines.length; i++) {
      if (originalLines[i] != mutatedLines[i]) {
        final mutationComment = ' // @ MUTATION: ${mutationType.displayName}';
        
        // Check if line already has a comment to avoid duplicates
        if (!mutatedLines[i].contains('// @ MUTATION')) {
          mutatedLines[i] += mutationComment;
        }
        break;
      }
    }
    
    return mutatedLines.join('\n');
  }

  /// Add specific tracking comments showing which mutations affected each line
  String _addSpecificTrackingComments(
    String mutatedCode, 
    Map<int, Set<MutationType>> lineToMutations
  ) {
    final mutatedLines = mutatedCode.split('\n');
    
    for (final entry in lineToMutations.entries) {
      final lineIndex = entry.key;
      final mutations = entry.value;
      
      if (lineIndex < mutatedLines.length && mutations.isNotEmpty) {
        final typeNames = mutations.map((type) => type.displayName).join(',');
        final mutationComment = ' // @ MUTATION: $typeNames';
        
        // Check if line already has a comment to avoid duplicates
        if (!mutatedLines[lineIndex].contains('// @ MUTATION')) {
          mutatedLines[lineIndex] += mutationComment;
        }
      }
    }
    
    return mutatedLines.join('\n');
  }

  /// Apply a specific mutation rule to the code with optimized pattern matching
  String? _applyMutationRule(String code, MutationRule rule) {
    switch (rule.type) {
      case MutationType.arithmetic:
        return _applyArithmeticMutation(code, rule.mutations);
      case MutationType.logical:
        return _applyLogicalMutation(code, rule.mutations);
      case MutationType.datatype:
        return _applyDatatypeMutation(code, rule.mutations);
      case MutationType.functionCall:
        return _applyFunctionCallMutation(code, rule.mutations);
      case MutationType.relational:
        return _applyRelationalMutation(code, rule.mutations);
      case MutationType.conditional:
        return _applyConditionalMutation(code, rule.mutations);
      case MutationType.increment:
        return _applyIncrementMutation(code, rule.mutations);
      case MutationType.assignment:
        return _applyAssignmentMutation(code, rule.mutations);
    }
  }

  /// Optimized arithmetic mutations with cached regex patterns
  String? _applyArithmeticMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final operator = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      final escapedOperator = RegExp.escape(operator);
      RegExp pattern;
      
      if (operator == '++' || operator == '--') {
        pattern = _getRegex('$escapedOperator\\w+|\\w+$escapedOperator');
      } else {
        pattern = _getRegex('(\\w+|\\))\\s*($escapedOperator)\\s*(\\w+|\\()');
      }
      
      final match = pattern.firstMatch(code);
      if (match != null) {
        final mutatedOperator = replacements.first;
        final fullMatch = match.group(0)!;
        final mutatedMatch = fullMatch.replaceAll(operator, mutatedOperator);
        return code.replaceRange(match.start, match.end, mutatedMatch);
      }
    }
    return null;
  }

  /// Optimized logical mutations
  String? _applyLogicalMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final operator = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      final escapedOperator = RegExp.escape(operator);
      RegExp pattern;
      
      if (operator == '!') {
        pattern = _getRegex('!(\\w+|\\()');
        final match = pattern.firstMatch(code);
        if (match != null) {
          final mutatedOperator = replacements.first;
          return code.replaceRange(match.start, match.start + 1, mutatedOperator);
        }
      } else {
        pattern = _getRegex('(\\w+|\\))\\s*($escapedOperator)\\s*(\\w+|\\()');
        final match = pattern.firstMatch(code);
        if (match != null) {
          final mutatedOperator = replacements.first;
          final fullMatch = match.group(0)!;
          final mutatedMatch = fullMatch.replaceAll(operator, mutatedOperator);
          return code.replaceRange(match.start, match.end, mutatedMatch);
        }
      }
    }
    return null;
  }

  /// Optimized datatype mutations
  String? _applyDatatypeMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final datatype = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      final pattern = _getRegex('\\b$datatype\\b');
      final match = pattern.firstMatch(code);
      if (match != null) {
        final mutatedDatatype = replacements.first;
        return code.replaceRange(match.start, match.end, mutatedDatatype);
      }
    }
    return null;
  }

  /// Optimized function call mutations
  String? _applyFunctionCallMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final function = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      final pattern = _getRegex('\\b$function\\s*\\(');
      final match = pattern.firstMatch(code);
      if (match != null) {
        final mutatedFunction = replacements.first;
        return code.replaceRange(
          match.start, 
          match.start + function.length, 
          mutatedFunction
        );
      }
    }
    return null;
  }

  /// Optimized relational mutations
  String? _applyRelationalMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final operator = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      final escapedOperator = RegExp.escape(operator);
      final pattern = _getRegex('(\\w+|\\))\\s*($escapedOperator)\\s*(\\w+|\\()');
      final match = pattern.firstMatch(code);
      if (match != null) {
        final mutatedOperator = replacements.first;
        final fullMatch = match.group(0)!;
        final mutatedMatch = fullMatch.replaceAll(operator, mutatedOperator);
        return code.replaceRange(match.start, match.end, mutatedMatch);
      }
    }
    return null;
  }

  /// Optimized conditional mutations - safer approach
  String? _applyConditionalMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final condition = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      // Use word boundaries for true/false to avoid partial matches
      RegExp pattern;
      if (condition == 'true' || condition == 'false') {
        pattern = _getRegex('\\b$condition\\b');
      } else {
        // For operators like == and !=, use more specific patterns
        final escapedCondition = RegExp.escape(condition);
        pattern = _getRegex('(\\w+|\\))\\s*($escapedCondition)\\s*(\\w+|\\()');
      }
      
      final match = pattern.firstMatch(code);
      if (match != null) {
        final mutatedCondition = replacements.first;
        if (condition == 'true' || condition == 'false') {
          return code.replaceRange(match.start, match.end, mutatedCondition);
        } else {
          final fullMatch = match.group(0)!;
          final mutatedMatch = fullMatch.replaceAll(condition, mutatedCondition);
          return code.replaceRange(match.start, match.end, mutatedMatch);
        }
      }
    }
    return null;
  }

  /// Optimized increment mutations - safer approach with loop detection
  String? _applyIncrementMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final operator = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      final escapedOperator = RegExp.escape(operator);
      RegExp pattern;
      
      // Only target standalone increment/decrement operators
      if (operator == '++' || operator == '--') {
        // Look for standalone pre/post increment: i++, ++i, counter--, --counter
        pattern = _getRegex('(?:^|[^\\w])($escapedOperator\\w+|\\w+$escapedOperator)(?:[^\\w]|\$)');
        
        final match = pattern.firstMatch(code);
        if (match != null) {
          final incrementPart = match.group(1)!;
          
          // Safety check: Don't mutate if this looks like a loop counter
          final lines = code.split('\n');
          var lineIndex = 0;
          var charCount = 0;
          
          // Find which line contains the match
          for (var i = 0; i < lines.length; i++) {
            if (charCount + lines[i].length >= match.start) {
              lineIndex = i;
              break;
            }
            charCount += lines[i].length + 1; // +1 for newline
          }
          
          // Check if this line or nearby lines contain loop keywords
          final contextStart = (lineIndex - 2).clamp(0, lines.length - 1);
          final contextEnd = (lineIndex + 2).clamp(0, lines.length - 1);
          final context = lines.sublist(contextStart, contextEnd + 1).join(' ').toLowerCase();
          
          // Skip mutation if it's likely in a loop context
          if (context.contains('for') || context.contains('while') || 
              context.contains('do ') || context.contains('i <=') || 
              context.contains('i <') || context.contains('i >=') || 
              context.contains('i >')) {
            continue; // Skip this mutation as it's likely a loop counter
          }
          
          final mutatedOperator = replacements.first;
          final mutatedIncrement = incrementPart.replaceAll(operator, mutatedOperator);
          return code.replaceRange(match.start + (match.group(0)!.indexOf(incrementPart)), 
                                 match.start + (match.group(0)!.indexOf(incrementPart)) + incrementPart.length, 
                                 mutatedIncrement);
        }
      } else {
        // For compound assignment operators, be more specific
        pattern = _getRegex('(\\w+)\\s*($escapedOperator)\\s*(\\w+|\\d+)');
        final match = pattern.firstMatch(code);
        if (match != null) {
          final mutatedOperator = replacements.first;
          final fullMatch = match.group(0)!;
          final mutatedMatch = fullMatch.replaceAll(operator, mutatedOperator);
          return code.replaceRange(match.start, match.end, mutatedMatch);
        }
      }
    }
    return null;
  }

  /// Optimized assignment mutations
  String? _applyAssignmentMutation(String code, Map<String, List<String>> mutations) {
    for (final entry in mutations.entries) {
      final operator = entry.key;
      final replacements = entry.value;
      if (replacements.isEmpty) continue;
      
      final escapedOperator = RegExp.escape(operator);
      final pattern = _getRegex('(\\w+)\\s*($escapedOperator)\\s*(\\w+|\\(|\\d+)');
      final match = pattern.firstMatch(code);
      if (match != null) {
        final mutatedOperator = replacements.first;
        final fullMatch = match.group(0)!;
        final mutatedMatch = fullMatch.replaceAll(operator, mutatedOperator);
        return code.replaceRange(match.start, match.end, mutatedMatch);
      }
    }
    return null;
  }

  /// Predefined mutation rules - now as static const for better performance
  static const List<MutationRule> _arithmeticRules = [
    MutationRule(
      type: MutationType.arithmetic,
      mutations: {
        '+': ['-', '*', '/', '%'],
        '-': ['+', '*', '/', '%'],
        '*': ['+', '-', '/', '%'],
        '/': ['+', '-', '*', '%'],
        '%': ['+', '-', '*', '/'],
        '++': ['--'],
        '--': ['++'],
      },
    ),
  ];

  static const List<MutationRule> _logicalRules = [
    MutationRule(
      type: MutationType.logical,
      mutations: {
        '&&': ['||'],
        '||': ['&&'],
        '!': [''],
      },
    ),
  ];

  static const List<MutationRule> _relationalRules = [
    MutationRule(
      type: MutationType.relational,
      mutations: {
        '==': ['!=', '>', '<', '>=', '<='],
        '!=': ['==', '>', '<', '>=', '<='],
        '>': ['<', '>=', '<=', '==', '!='],
        '<': ['>', '>=', '<=', '==', '!='],
        '>=': ['<=', '>', '<', '==', '!='],
        '<=': ['>=', '>', '<', '==', '!='],
      },
    ),
  ];

  static const List<MutationRule> _datatypeRules = [
    MutationRule(
      type: MutationType.datatype,
      mutations: {
        'int': ['double', 'String', 'bool'],
        'double': ['int', 'String', 'bool'],
        'String': ['int', 'double', 'bool'],
        'bool': ['int', 'double', 'String'],
        'List': ['Set', 'Map'],
        'Set': ['List', 'Map'],
        'Map': ['List', 'Set'],
      },
    ),
  ];

  static const List<MutationRule> _functionCallRules = [
    MutationRule(
      type: MutationType.functionCall,
      mutations: {
        'print': ['debugPrint'],
        'add': ['remove'],
        'insert': ['removeAt'],
        'length': ['isEmpty'],
        'toString': ['hashCode'],
      },
    ),
  ];

  static const List<MutationRule> _conditionalRules = [
    MutationRule(
      type: MutationType.conditional,
      mutations: {
        'true': ['false'],
        'false': ['true'],
        '==': ['!='],
        '!=': ['=='],
      },
    ),
  ];

  static const List<MutationRule> _incrementRules = [
    MutationRule(
      type: MutationType.increment,
      mutations: {
        '++': ['--'],
        '--': ['++'],
      },
    ),
  ];

  static const List<MutationRule> _assignmentRules = [
    MutationRule(
      type: MutationType.assignment,
      mutations: {
        '+=': ['-='],
        '-=': ['+='],
        '*=': ['/='],
        '/=': ['*='],
      },
    ),
  ];

  /// Public getters for mutation rules with caching
  static List<MutationRule> getArithmeticRules() => List.unmodifiable(_arithmeticRules);
  static List<MutationRule> getLogicalRules() => List.unmodifiable(_logicalRules);
  static List<MutationRule> getRelationalRules() => List.unmodifiable(_relationalRules);
  static List<MutationRule> getDatatypeRules() => List.unmodifiable(_datatypeRules);
  static List<MutationRule> getFunctionCallRules() => List.unmodifiable(_functionCallRules);
  static List<MutationRule> getConditionalRules() => List.unmodifiable(_conditionalRules);
  static List<MutationRule> getIncrementRules() => List.unmodifiable(_incrementRules);
  static List<MutationRule> getAssignmentRules() => List.unmodifiable(_assignmentRules);

  /// Generic function that accepts a rule type and returns the corresponding mutation rules
  static List<MutationRule> getRulesByType(MutationType type) {
    switch (type) {
      case MutationType.arithmetic:
        return getArithmeticRules();
      case MutationType.logical:
        return getLogicalRules();
      case MutationType.relational:
        return getRelationalRules();
      case MutationType.datatype:
        return getDatatypeRules();
      case MutationType.functionCall:
        return getFunctionCallRules();
      case MutationType.conditional:
        return getConditionalRules();
      case MutationType.increment:
        return getIncrementRules();
      case MutationType.assignment:
        return getAssignmentRules();
    }
  }

  /// Get rules for multiple types at once - optimized
  static List<MutationRule> getRulesByTypes(List<MutationType> types) {
    if (types.isEmpty) return [];
    
    final allRules = <MutationRule>[];
    for (final type in types) {
      allRules.addAll(getRulesByType(type));
    }
    return allRules;
  }

  /// Get all available mutation rules - cached for performance
  static List<MutationRule> getAllRules() {
    return getRulesByTypes(MutationType.values);
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use performMutation with getArithmeticRules() instead')
  String? arithmeticMutation(String code) {
    return performMutation(code, getArithmeticRules());
  }

  /// Run tests against mutated files to check mutation detection
  /// Returns true if the mutation was detected (tests failed)
  static Future<MutationTestResult> runTestsOnMutation({
    required String originalFilePath,
    required String mutatedFilePath,
    required MutationType mutationType,
    String? testCommand,
    String? workingDirectory,
    bool verbose = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Backup original file
      final originalFile = File(originalFilePath);
      final mutatedFile = File(mutatedFilePath);
      
      if (!await originalFile.exists()) {
        throw Exception('Original file not found: $originalFilePath');
      }
      
      if (!await mutatedFile.exists()) {
        throw Exception('Mutated file not found: $mutatedFilePath');
      }
      
      final originalContent = await originalFile.readAsString();
      final mutatedContent = await mutatedFile.readAsString();
      
      if (verbose) {
        print('Testing mutation: $mutationType');
        print('  Original: $originalFilePath');
        print('  Mutated: $mutatedFilePath');
      }
      
      // Replace original with mutated content
      await originalFile.writeAsString(mutatedContent);
      
      // Determine timeout based on mutation type (some mutations are more risky)
      Duration timeout;
      switch (mutationType) {
        case MutationType.increment:
        case MutationType.conditional:
          timeout = const Duration(seconds: 5); // Shorter for risky mutations
          break;
        case MutationType.assignment:
          timeout = const Duration(seconds: 7);
          break;
        default:
          timeout = const Duration(seconds: 8); // Standard timeout
      }
      
      // Run tests with enhanced timeout to prevent hanging
      final testCmd = testCommand ?? 'dart test';
      final testArgs = testCmd.split(' ').skip(1).toList();
      final executable = testCmd.split(' ').first;
      
      if (verbose) {
        print('  Running tests (timeout: ${timeout.inSeconds}s)...');
      }
      
      // Start the process
      final process = await Process.start(
        executable,
        testArgs,
        workingDirectory: workingDirectory,
      );
      
      // Set up timeout with process termination
      late ProcessResult result;
      
      try {
        result = await Future.wait([
          process.exitCode,
          process.stdout.transform(utf8.decoder).join(),
          process.stderr.transform(utf8.decoder).join(),
        ]).timeout(
          timeout,
          onTimeout: () {
            process.kill(ProcessSignal.sigkill); // Force kill the process
            throw TimeoutException('Test execution timed out', timeout);
          },
        ).then((results) {
          return ProcessResult(process.pid, results[0] as int, results[1] as String, results[2] as String);
        });
      } on TimeoutException {
        // Ensure process is killed
        try {
          process.kill(ProcessSignal.sigkill);
        } catch (_) {
          // Ignore kill errors
        }
        result = ProcessResult(0, 124, '', 'Test execution timed out after ${timeout.inSeconds} seconds - likely infinite loop detected');
      } catch (e) {
        // Handle other errors
        try {
          process.kill(ProcessSignal.sigkill);
        } catch (_) {
          // Ignore kill errors
        }
        result = ProcessResult(0, 1, '', 'Test execution failed: $e');
      }
      
      stopwatch.stop();
      
      // Restore original file
      await originalFile.writeAsString(originalContent);
      
      final testPassed = result.exitCode == 0;
      final output = '${result.stdout}\n${result.stderr}'.trim();
      
      if (verbose) {
        print('  Test result: ${testPassed ? 'PASSED' : 'FAILED'}');
        print('  Execution time: ${stopwatch.elapsed.inMilliseconds}ms');
        if (!testPassed) {
          print('  ✅ MUTATION DETECTED');
        } else {
          print('  ❌ MUTATION NOT DETECTED');
        }
      }
      
      return MutationTestResult(
        mutationType: mutationType,
        testPassed: testPassed,
        testOutput: output,
        mutationFile: mutatedFilePath,
        executionTime: stopwatch.elapsed,
      );
      
    } catch (e) {
      stopwatch.stop();
      
      // Try to restore original file in case of error
      try {
        final originalFile = File(originalFilePath);
        if (await originalFile.exists()) {
          // We can't restore without backup, but we can warn
          print('Warning: Error during mutation testing. Please verify file integrity: $originalFilePath');
        }
      } catch (_) {
        // Ignore restoration errors
      }
      
      return MutationTestResult(
        mutationType: mutationType,
        testPassed: false,
        testOutput: 'Error during test execution: $e',
        mutationFile: mutatedFilePath,
        executionTime: stopwatch.elapsed,
      );
    }
  }

  /// Run tests on all mutations and generate a comprehensive report
  static Future<List<MutationTestResult>> runMutationTestSuite({
    required String originalFilePath,
    required List<String> mutatedFilePaths,
    String? testCommand,
    String? workingDirectory,
    bool verbose = false,
  }) async {
    if (verbose) {
      print('🧬 Running Mutation Test Suite');
      print('==============================');
      print('Original file: $originalFilePath');
      print('Mutations to test: ${mutatedFilePaths.length}');
      print('Adaptive timeouts: 5-8 seconds based on mutation risk');
      print('');
    }
    
    final results = <MutationTestResult>[];
    var detectedCount = 0;
    var timeoutCount = 0;
    
    for (var i = 0; i < mutatedFilePaths.length; i++) {
      final mutatedFilePath = mutatedFilePaths[i];
      
      // Extract mutation type from filename
      final mutationType = _extractMutationTypeFromPath(mutatedFilePath);
      
      if (verbose) {
        print('Testing mutation ${i + 1}/${mutatedFilePaths.length}: ${mutationType.displayName}');
      }
      
      final result = await runTestsOnMutation(
        originalFilePath: originalFilePath,
        mutatedFilePath: mutatedFilePath,
        mutationType: mutationType,
        testCommand: testCommand,
        workingDirectory: workingDirectory,
        verbose: verbose,
      );
      
      results.add(result);
      
      if (result.testOutput.contains('timed out')) {
        timeoutCount++;
        if (verbose) {
          print('  ⏰ TIMEOUT - Infinite loop prevented');
        }
      } else if (result.mutationDetected) {
        detectedCount++;
        if (verbose) {
          print('  ✅ DETECTED (${result.executionTime?.inMilliseconds ?? 0}ms)');
        }
      } else {
        if (verbose) {
          print('  ❌ MISSED (${result.executionTime?.inMilliseconds ?? 0}ms)');
        }
      }
    }
    
    if (verbose) {
      if (timeoutCount > 0) {
        print('\n⏰ Timeout Summary:');
        print('  Prevented $timeoutCount potential infinite loops');
        print('  This shows the mutation tool is working correctly!');
      }
      _printMutationTestReport(results, detectedCount);
    }
    
    return results;
  }

  /// Extract mutation type from file path
  static MutationType _extractMutationTypeFromPath(String filePath) {
    final fileName = filePath.split('/').last.toLowerCase();
    
    if (fileName.contains('arithmetic')) return MutationType.arithmetic;
    if (fileName.contains('logical')) return MutationType.logical;
    if (fileName.contains('relational')) return MutationType.relational;
    if (fileName.contains('conditional')) return MutationType.conditional;
    if (fileName.contains('increment')) return MutationType.increment;
    if (fileName.contains('assignment')) return MutationType.assignment;
    if (fileName.contains('datatype')) return MutationType.datatype;
    if (fileName.contains('function')) return MutationType.functionCall;
    
    // Default fallback
    return MutationType.arithmetic;
  }

  /// Print comprehensive mutation test report
  static void _printMutationTestReport(List<MutationTestResult> results, int detectedCount) {
    print('\n🎯 Mutation Testing Report');
    print('==========================');
    
    final totalMutations = results.length;
    final detectionRate = totalMutations > 0 ? (detectedCount / totalMutations * 100) : 0;
    
    print('Total mutations tested: $totalMutations');
    print('Mutations detected: $detectedCount');
    print('Detection rate: ${detectionRate.toStringAsFixed(1)}%');
    print('');
    
    // Detailed results
    print('Detailed Results:');
    print('-' * 40);
    
    for (final result in results) {
      final status = result.mutationDetected ? '✅ DETECTED' : '❌ MISSED';
      final time = result.executionTime?.inMilliseconds ?? 0;
      
      print('${result.mutationType.displayName.padRight(12)} | $status | ${time}ms');
    }
    
    print('');
    
    // Quality assessment
    if (detectionRate == 100) {
      print('🏆 Excellent! All mutations were detected.');
      print('   Your test suite provides comprehensive coverage.');
    } else if (detectionRate >= 80) {
      print('👍 Good mutation detection rate.');
      print('   Consider adding tests for missed mutations.');
    } else if (detectionRate >= 60) {
      print('⚠️  Moderate mutation detection.');
      print('   Your test suite needs improvement.');
    } else {
      print('❌ Low mutation detection rate.');
      print('   Critical: Add more comprehensive tests.');
    }
    
    // Recommendations for missed mutations
    final missedTypes = results
        .where((r) => !r.mutationDetected)
        .map((r) => r.mutationType.displayName)
        .toSet();
    
    if (missedTypes.isNotEmpty) {
      print('');
      print('💡 Recommendations:');
      print('   Add tests covering: ${missedTypes.join(', ')} operations');
    }
  }

  /// Convenience method to run mutation testing on a directory of mutations
  static Future<List<MutationTestResult>> runMutationTestsFromDirectory({
    required String originalFilePath,
    required String mutationDirectory,
    String? testCommand,
    String? workingDirectory,
    bool verbose = false,
  }) async {
    // Find all mutation files in the directory
    final mutationDir = Directory(mutationDirectory);
    
    if (!await mutationDir.exists()) {
      throw Exception('Mutation directory not found: $mutationDirectory');
    }
    
    final mutationFiles = <String>[];
    
    await for (final entity in mutationDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        mutationFiles.add(entity.path);
      }
    }
    
    if (mutationFiles.isEmpty) {
      throw Exception('No mutation files found in: $mutationDirectory');
    }
    
    return runMutationTestSuite(
      originalFilePath: originalFilePath,
      mutatedFilePaths: mutationFiles,
      testCommand: testCommand,
      workingDirectory: workingDirectory,
      verbose: verbose,
    );
  }
}
