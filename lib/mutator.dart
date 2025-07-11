import 'dart:io';

// Enum to define different types of mutations
enum MutationType {
  arithmetic,
  logical,
  datatype,
  functionCall,
  relational,
}

// Class to define mutation rules
class MutationRule {
  final MutationType type;
  final Map<String, List<String>> mutations;
  final RegExp? pattern;

  MutationRule({
    required this.type,
    required this.mutations,
    this.pattern,
  });
}

class Mutator {
  void mutate(String filePath) {
    String code = File(filePath).readAsStringSync();
    
    // Apply arithmetic mutation (get single mutation)
    String? mutation =   performMutation(code, getArithmeticRules());
    
    // Save the mutation to a file if one was generated
    if (mutation != null) {
      File('mutated_$filePath').writeAsStringSync(mutation);
    }
  }

  /// Generic mutation function that accepts source code, mutation rules, and optional line range
  /// Returns the mutated source code and saves it to a file
  String? performMutation(
    String sourceCode,
    List<MutationRule> mutationRules, {
    int? startLine,
    int? endLine,
    String? outputFilePath,
  }) {
    String codeToMutate = sourceCode;
    
    // If line range is specified, extract only those lines
    if (startLine != null && endLine != null) {
      List<String> lines = sourceCode.split('\n');
      if (startLine >= 1 && endLine <= lines.length && startLine <= endLine) {
        // Extract the specified lines (1-based indexing)
        List<String> selectedLines = lines.sublist(startLine - 1, endLine);
        codeToMutate = selectedLines.join('\n');
      } else {
        print('Warning: Invalid line range. Using entire source code.');
      }
    }

    // Apply mutations based on the provided rules
    for (MutationRule rule in mutationRules) {
      String? mutatedCode = _applyMutationRule(codeToMutate, rule);
      if (mutatedCode != null) {
        // If line range was specified, reconstruct the full source code
        if (startLine != null && endLine != null) {
          List<String> originalLines = sourceCode.split('\n');
          List<String> mutatedLines = mutatedCode.split('\n');
          
          // Replace the specified lines with mutated versions
          for (int i = 0; i < mutatedLines.length; i++) {
            if (startLine - 1 + i < originalLines.length) {
              originalLines[startLine - 1 + i] = mutatedLines[i];
            }
          }
          mutatedCode = originalLines.join('\n');
        }
        
        // Save to file if output path is provided
        if (outputFilePath != null) {
          File(outputFilePath).writeAsStringSync(mutatedCode);
        }
        
        return mutatedCode;
      }
    }
    
    return null; // No mutations applied
  }

  /// Apply a specific mutation rule to the code
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

  /// Apply arithmetic mutations
  String? _applyArithmeticMutation(String code, Map<String, List<String>> mutations) {
    for (String operator in mutations.keys) {
      String escapedOperator = RegExp.escape(operator);
      RegExp pattern;
      
      if (operator == '++' || operator == '--') {
        pattern = RegExp(escapedOperator + r'\w+|\w+' + escapedOperator);
      } else {
        pattern = RegExp(r'(\w+|\))\s*(' + escapedOperator + r')\s*(\w+|\()');
      }
      
      RegExpMatch? match = pattern.firstMatch(code);
      if (match != null) {
        String mutatedOperator = mutations[operator]!.first;
        
        if (operator == '++' || operator == '--') {
          String mutatedCode = code.replaceRange(match.start, match.end, 
              match.group(0)!.replaceAll(operator, mutatedOperator));
          return mutatedCode;
        } else {
          String mutatedCode = code.replaceRange(
            match.start + match.group(1)!.length,
            match.start + match.group(1)!.length + operator.length,
            mutatedOperator
          );
          return mutatedCode;
        }
      }
    }
    return null;
  }

  /// Apply logical mutations
  String? _applyLogicalMutation(String code, Map<String, List<String>> mutations) {
    for (String operator in mutations.keys) {
      String escapedOperator = RegExp.escape(operator);
      RegExp pattern = RegExp(r'(\w+|\))\s*(' + escapedOperator + r')\s*(\w+|\()');
      
      RegExpMatch? match = pattern.firstMatch(code);
      if (match != null) {
        String mutatedOperator = mutations[operator]!.first;
        String mutatedCode = code.replaceRange(
          match.start + match.group(1)!.length,
          match.start + match.group(1)!.length + operator.length,
          mutatedOperator
        );
        return mutatedCode;
      }
    }
    return null;
  }

  /// Apply datatype mutations
  String? _applyDatatypeMutation(String code, Map<String, List<String>> mutations) {
    for (String datatype in mutations.keys) {
      RegExp pattern = RegExp(r'\b' + datatype + r'\b');
      
      RegExpMatch? match = pattern.firstMatch(code);
      if (match != null) {
        String mutatedDatatype = mutations[datatype]!.first;
        String mutatedCode = code.replaceRange(match.start, match.end, mutatedDatatype);
        return mutatedCode;
      }
    }
    return null;
  }

  /// Apply function call mutations
  String? _applyFunctionCallMutation(String code, Map<String, List<String>> mutations) {
    for (String function in mutations.keys) {
      RegExp pattern = RegExp(r'\b' + function + r'\s*\(');
      
      RegExpMatch? match = pattern.firstMatch(code);
      if (match != null) {
        String mutatedFunction = mutations[function]!.first;
        String mutatedCode = code.replaceRange(
          match.start, 
          match.start + function.length, 
          mutatedFunction
        );
        return mutatedCode;
      }
    }
    return null;
  }

  /// Apply relational mutations
  String? _applyRelationalMutation(String code, Map<String, List<String>> mutations) {
    for (String operator in mutations.keys) {
      String escapedOperator = RegExp.escape(operator);
      RegExp pattern = RegExp(r'(\w+|\))\s*(' + escapedOperator + r')\s*(\w+|\()');
      
      RegExpMatch? match = pattern.firstMatch(code);
      if (match != null) {
        String mutatedOperator = mutations[operator]!.first;
        String mutatedCode = code.replaceRange(
          match.start + match.group(1)!.length,
          match.start + match.group(1)!.length + operator.length,
          mutatedOperator
        );
        return mutatedCode;
      }
    }
    return null;
  }

  /// Predefined mutation rules for convenience
  static List<MutationRule> getArithmeticRules() {
    return [
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
  }

  static List<MutationRule> getLogicalRules() {
    return [
      MutationRule(
        type: MutationType.logical,
        mutations: {
          '&&': ['||'],
          '||': ['&&'],
          '!': [''],
        },
      ),
    ];
  }

  static List<MutationRule> getRelationalRules() {
    return [
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
  }

  static List<MutationRule> getDatatypeRules() {
    return [
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
  }

  static List<MutationRule> getFunctionCallRules() {
    return [
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
  }

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

  /// Get rules for multiple types at once
  static List<MutationRule> getRulesByTypes(List<MutationType> types) {
    List<MutationRule> allRules = [];
    for (MutationType type in types) {
      allRules.addAll(getRulesByType(type));
    }
    return allRules;
  }

  /// Get all available mutation rules
  static List<MutationRule> getAllRules() {
    return getRulesByTypes([
      MutationType.arithmetic,
      MutationType.logical,
      MutationType.relational,
      MutationType.datatype,
      MutationType.functionCall,
    ]);
  }

  /// Legacy method for backward compatibility
  String? arithmeticMutation(String code) {
    return performMutation(code, getArithmeticRules());
  }
}
