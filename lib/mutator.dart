import 'dart:io';

/// Enum to define different types of mutations
enum MutationType {
  arithmetic,
  logical,
  datatype,
  functionCall,
  relational;

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

/// Main mutator class with optimized performance and better error handling
class Mutator {
  /// Cache for compiled regex patterns to improve performance
  static final Map<String, RegExp> _regexCache = <String, RegExp>{};

  /// Thread-safe regex compilation with caching
  static RegExp _getRegex(String pattern) {
    return _regexCache.putIfAbsent(pattern, () => RegExp(pattern));
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
    
    // Replace the specified lines with mutated versions
    for (var i = 0; i < mutatedLines.length; i++) {
      final lineIndex = startLine - 1 + i;
      if (lineIndex < originalLines.length) {
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

  /// Public getters for mutation rules with caching
  static List<MutationRule> getArithmeticRules() => List.unmodifiable(_arithmeticRules);
  static List<MutationRule> getLogicalRules() => List.unmodifiable(_logicalRules);
  static List<MutationRule> getRelationalRules() => List.unmodifiable(_relationalRules);
  static List<MutationRule> getDatatypeRules() => List.unmodifiable(_datatypeRules);
  static List<MutationRule> getFunctionCallRules() => List.unmodifiable(_functionCallRules);

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
}
