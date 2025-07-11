import 'package:smart_mutation/mutator.dart';

void main() {
  print('=== Testing getRulesByType Function ===\n');
  
  // Test individual rule types
  print('1. Arithmetic Rules:');
  List<MutationRule> arithmeticRules = Mutator.getRulesByType(MutationType.arithmetic);
  _printRules(arithmeticRules);
  
  print('\n2. Logical Rules:');
  List<MutationRule> logicalRules = Mutator.getRulesByType(MutationType.logical);
  _printRules(logicalRules);
  
  print('\n3. Relational Rules:');
  List<MutationRule> relationalRules = Mutator.getRulesByType(MutationType.relational);
  _printRules(relationalRules);
  
  print('\n4. Datatype Rules:');
  List<MutationRule> datatypeRules = Mutator.getRulesByType(MutationType.datatype);
  _printRules(datatypeRules);
  
  print('\n5. Function Call Rules:');
  List<MutationRule> functionRules = Mutator.getRulesByType(MutationType.functionCall);
  _printRules(functionRules);
  
  // Test multiple types
  print('\n6. Multiple Types (Arithmetic + Logical):');
  List<MutationRule> multipleRules = Mutator.getRulesByTypes([
    MutationType.arithmetic,
    MutationType.logical
  ]);
  _printRules(multipleRules);
  
  // Test all rules
  print('\n7. All Rules:');
  List<MutationRule> allRules = Mutator.getAllRules();
  print('Total rules: ${allRules.length}');
  print('Rule types: ${allRules.map((r) => r.type.toString()).toSet()}');
  
  print('\n✅ getRulesByType function test completed!');
}

void _printRules(List<MutationRule> rules) {
  print('  Count: ${rules.length}');
  for (MutationRule rule in rules) {
    print('  Type: ${rule.type}');
    print('  Mutations: ${rule.mutations.keys.take(3).join(', ')}${rule.mutations.length > 3 ? '...' : ''}');
  }
}
