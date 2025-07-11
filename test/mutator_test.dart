import 'package:test/test.dart';
import 'package:smart_mutation/mutator.dart';

void main() {
  group('Optimized Mutator Tests', () {
    late Mutator mutator;
    
    setUp(() {
      mutator = Mutator();
    });

    test('should cache regex patterns for performance', () {
      const code = 'int a = 5 + 3;';
      
      // Multiple calls should use cached patterns
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        mutator.performMutation(code, Mutator.getArithmeticRules());
      }
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(100), 
          reason: 'Regex caching should improve performance');
    });

    test('should handle empty inputs gracefully', () {
      expect(mutator.performMutation('', Mutator.getArithmeticRules()), isNull);
      expect(mutator.performMutation('int a = 5;', []), isNull);
    });

    test('should validate line ranges correctly', () {
      const code = 'int a = 5 + 3;\\nint b = 10 - 2;\\nint c = 7 * 4;';
      
      // Valid range - should return a mutation
      final result1 = mutator.performMutation(
        code, Mutator.getArithmeticRules(), 
        startLine: 1, endLine: 2
      );
      expect(result1, isNotNull);
      
      // Invalid range - should still process full code
      final result2 = mutator.performMutation(
        code, Mutator.getArithmeticRules(),
        startLine: -1, endLine: 10
      );
      expect(result2, isNotNull);
    });

    test('should track mutations specifically per line', () {
      const code = '''
int calculate(int a, int b) {
  return a + b && true == false;
}''';
      
      final result = mutator.performCumulativeMutations(
        code,
        [
          ...Mutator.getArithmeticRules(),
          ...Mutator.getLogicalRules(),
          ...Mutator.getRelationalRules(),
        ],
        trackMutations: true,
      );
      
      expect(result, isNotNull);
      expect(result!, contains('@ MUTATION:'));
      
      // Should show specific mutations, not all types on every line
      final lines = result.split('\\n');
      final mutatedLines = lines.where((line) => line.contains('@ MUTATION:')).toList();
      
      for (final line in mutatedLines) {
        // Each line should only show relevant mutations
        expect(line.split('@ MUTATION:').length, equals(2), 
            reason: 'Should have exactly one mutation comment per line');
      }
    });

    test('should handle error cases gracefully', () {
      // Test with malformed mutation rules
      final emptyRule = MutationRule(
        type: MutationType.arithmetic,
        mutations: {},
      );
      
      const code = 'int a = 5 + 3;';
      final result = mutator.performMutation(code, [emptyRule]);
      expect(result, isNull);
    });

    test('should generate multiple mutations efficiently', () {
      const code = '''
int add(int a, int b) {
  return a + b;
}
bool check(bool x) {
  return x && true;
}''';
      
      final rules = [
        ...Mutator.getArithmeticRules(),
        ...Mutator.getLogicalRules(),
      ];
      
      final results = mutator.performMultipleMutations(
        code, rules, trackMutations: true
      );
      
      expect(results, hasLength(2)); // arithmetic and logical
      expect(results.map((r) => r.mutationType).toSet(), 
          equals({MutationType.arithmetic, MutationType.logical}));
    });

    test('should maintain immutability of mutation rules', () {
      final rules = Mutator.getArithmeticRules();
      final originalLength = rules.length;
      
      // Attempting to modify should throw an error due to immutability
      expect(() => rules.clear(), throwsUnsupportedError);
      
      // Original rules should remain unchanged
      final newRules = Mutator.getArithmeticRules();
      expect(newRules.length, equals(originalLength));
    });

    test('should handle cumulative mutations correctly', () {
      const code = '''
int calculate(int a, int b) {
  if (a > 0 && b == 5) {
    return a + b;
  }
  return 0;
}''';
      
      final result = mutator.performCumulativeMutations(
        code,
        [
          ...Mutator.getArithmeticRules(),
          ...Mutator.getLogicalRules(),
          ...Mutator.getRelationalRules(),
        ],
        trackMutations: true,
      );
      
      expect(result, isNotNull);
      
      // Should contain multiple mutations
      expect(result!, contains('- ')); // arithmetic mutation
      expect(result, contains('||')); // logical mutation  
      expect(result, contains('!=')); // relational mutation
    });

    test('should use display names for mutation types', () {
      expect(MutationType.arithmetic.displayName, equals('arithmetic'));
      expect(MutationType.logical.displayName, equals('logical'));
      expect(MutationType.relational.displayName, equals('relational'));
      expect(MutationType.datatype.displayName, equals('datatype'));
      expect(MutationType.functionCall.displayName, equals('functionCall'));
    });

    test('should provide immutable rule getters', () {
      final rules1 = Mutator.getArithmeticRules();
      final rules2 = Mutator.getArithmeticRules();
      
      // Should return different instances (unmodifiable views)
      expect(identical(rules1, rules2), isFalse);
      expect(rules1, equals(rules2));
    });
  });

  group('Performance Tests', () {
    test('should handle large files efficiently', () {
      // Generate a large code file
      final largeCode = StringBuffer();
      for (var i = 0; i < 1000; i++) {
        largeCode.writeln('int var$i = $i + ${i + 1};');
      }
      
      final stopwatch = Stopwatch()..start();
      final mutator = Mutator();
      final result = mutator.performMutation(
        largeCode.toString(), 
        Mutator.getArithmeticRules()
      );
      stopwatch.stop();
      
      expect(result, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(500), 
          reason: 'Should handle large files efficiently');
    });

    test('should cache all rules efficiently', () {
      final stopwatch = Stopwatch()..start();
      
      // Multiple calls should be fast due to caching
      for (var i = 0; i < 100; i++) {
        Mutator.getAllRules();
      }
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(50),
          reason: 'Rule caching should make repeated calls fast');
    });
  });
}
