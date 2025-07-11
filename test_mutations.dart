import 'dart:io';
import 'package:smart_mutation/mutator.dart';

void main() {
  final mutator = Mutator();
  
  // Read the test file
  String sourceCode = File('test_input/complex_test.dart').readAsStringSync();
  print('Original code:');
  print('=' * 50);
  print(sourceCode);
  print('=' * 50);
  
  // Example 1: Arithmetic mutations
  print('\n1. Arithmetic Mutation:');
  String? arithmeticMutation = mutator.performMutation(
    sourceCode,
    Mutator.getArithmeticRules(),
    outputFilePath: 'mutations_output/arithmetic_mutated.dart',
  );
  
  if (arithmeticMutation != null) {
    print('✓ Arithmetic mutation applied and saved to arithmetic_mutated.dart');
  }
  
  // Example 2: Logical mutations
  print('\n2. Logical Mutation:');
  String? logicalMutation = mutator.performMutation(
    sourceCode,
    Mutator.getLogicalRules(),
    outputFilePath: 'mutations_output/logical_mutated.dart',
  );
  
  if (logicalMutation != null) {
    print('✓ Logical mutation applied and saved to logical_mutated.dart');
  }
  
  // Example 3: Relational mutations
  print('\n3. Relational Mutation:');
  String? relationalMutation = mutator.performMutation(
    sourceCode,
    Mutator.getRelationalRules(),
    outputFilePath: 'mutations_output/relational_mutated.dart',
  );
  
  if (relationalMutation != null) {
    print('✓ Relational mutation applied and saved to relational_mutated.dart');
  }
  
  // Example 4: Datatype mutations
  print('\n4. Datatype Mutation:');
  String? datatypeMutation = mutator.performMutation(
    sourceCode,
    Mutator.getDatatypeRules(),
    outputFilePath: 'mutations_output/datatype_mutated.dart',
  );
  
  if (datatypeMutation != null) {
    print('✓ Datatype mutation applied and saved to datatype_mutated.dart');
  }
  
  // Example 5: Function call mutations
  print('\n5. Function Call Mutation:');
  String? functionMutation = mutator.performMutation(
    sourceCode,
    Mutator.getFunctionCallRules(),
    outputFilePath: 'mutations_output/function_mutated.dart',
  );
  
  if (functionMutation != null) {
    print('✓ Function call mutation applied and saved to function_mutated.dart');
  }
  
  // Example 6: Multiple mutation types combined
  print('\n6. Combined Mutations:');
  List<MutationRule> combinedRules = [];
  combinedRules.addAll(Mutator.getArithmeticRules());
  combinedRules.addAll(Mutator.getLogicalRules());
  combinedRules.addAll(Mutator.getRelationalRules());
  
  String? combinedMutation = mutator.performMutation(
    sourceCode,
    combinedRules,
    outputFilePath: 'mutations_output/combined_mutated.dart',
  );
  
  if (combinedMutation != null) {
    print('✓ Combined mutations applied and saved to combined_mutated.dart');
  }
  
  // Example 7: Line-specific mutation (only mutate lines 8-12)
  print('\n7. Line-Specific Mutation (lines 8-12):');
  String? lineSpecificMutation = mutator.performMutation(
    sourceCode,
    Mutator.getArithmeticRules(),
    startLine: 8,
    endLine: 12,
    outputFilePath: 'mutations_output/line_specific_mutated.dart',
  );
  
  if (lineSpecificMutation != null) {
    print('✓ Line-specific mutation applied and saved to line_specific_mutated.dart');
  }
  
  // Example 8: Custom mutation rule
  print('\n8. Custom Mutation Rule:');
  MutationRule customRule = MutationRule(
    type: MutationType.functionCall,
    mutations: {
      'calculate': ['compute', 'process'],
      'compare': ['check', 'validate'],
    },
  );
  
  String? customMutation = mutator.performMutation(
    sourceCode,
    [customRule],
    outputFilePath: 'mutations_output/custom_mutated.dart',
  );
  
  if (customMutation != null) {
    print('✓ Custom mutation applied and saved to custom_mutated.dart');
  }
  
  print('\n🎉 All mutation demonstrations completed!');
  print('Check the mutations_output directory for generated files.');
}
