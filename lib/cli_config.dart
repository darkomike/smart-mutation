import 'dart:io';
import 'package:args/args.dart';
import 'package:smart_mutation/mutator.dart';

/// Configuration class for CLI arguments
class CliConfig {
  const CliConfig({
    required this.inputDir,
    required this.outputDir,
    required this.mutationRules,
    required this.enableTracking,
    required this.useCumulative,
    required this.verbose,
  });

  final String inputDir;
  final String outputDir;
  final List<MutationRule> mutationRules;
  final bool enableTracking;
  final bool useCumulative;
  final bool verbose;
}

/// Data class for processing results
class ProcessingResults {
  const ProcessingResults({
    required this.filesProcessed,
    required this.totalMutations,
    required this.errors,
  });

  final int filesProcessed;
  final int totalMutations;
  final List<String> errors;
}

/// Parse and validate command line arguments
Future<CliConfig> parseArguments(List<String> arguments) async {
  final parser = createArgParser();
  
  ArgResults? results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    print('');
    printUsage(parser);
    exit(1);
  }

  // Show help if requested
  if (results['help'] as bool) {
    printUsage(parser);
    exit(0);
  }

  // Extract configuration values
  var inputDir = results['input'] as String?;
  var outputDir = results['output'] as String?;

  // Handle positional arguments for backward compatibility
  if (inputDir == null && outputDir == null && results.rest.length >= 2) {
    inputDir = results.rest[0];
    outputDir = results.rest[1];
  }

  // Validate required arguments
  if (inputDir == null || outputDir == null) {
    print('Error: Both input and output directories are required.');
    print('');
    printUsage(parser);
    exit(1);
  }

  final verbose = results['verbose'] as bool;
  final enableTracking = results['track'] as bool;
  final useCumulative = results['cumulative'] as bool;

  // Parse mutation rule types with validation
  final ruleTypesString = results['rules'] as String;
  final mutationRules = parseMutationRules(ruleTypesString);
  
  if (verbose) {
    print('Configuration:');
    print('  Input directory: $inputDir');
    print('  Output directory: $outputDir');
    print('  Mutation rules: $ruleTypesString');
    print('  Tracking: ${enableTracking ? 'enabled' : 'disabled'}');
    print('  Cumulative: ${useCumulative ? 'enabled' : 'disabled'}');
    print('');
  }

  return CliConfig(
    inputDir: inputDir,
    outputDir: outputDir,
    mutationRules: mutationRules,
    enableTracking: enableTracking,
    useCumulative: useCumulative,
    verbose: verbose,
  );
}

/// Create optimized argument parser
ArgParser createArgParser() {
  return ArgParser()
    ..addFlag('help',
        abbr: 'h',
        negatable: false,
        help: 'Show this help message.')
    ..addFlag('verbose',
        abbr: 'v',
        negatable: false,
        help: 'Show verbose output.')
    ..addOption('input',
        abbr: 'i',
        help: 'Input directory containing Dart files to mutate.',
        valueHelp: 'DIR')
    ..addOption('output',
        abbr: 'o',
        help: 'Output directory for mutated files.',
        defaultsTo: 'docs/mutations',
        valueHelp: 'DIR')
    ..addOption('rules',
        abbr: 'r',
        help: 'Comma-separated list of mutation types: arithmetic,logical,relational,datatype,functionCall,all',
        defaultsTo: 'arithmetic',
        valueHelp: 'TYPES')
    ..addFlag('track',
        abbr: 't',
        defaultsTo: true,
        help: 'Add @ MUTATION comments to track where mutations occurred.')
    ..addFlag('cumulative',
        abbr: 'c',
        defaultsTo: false,
        help: 'Apply all mutations cumulatively to a single file instead of creating separate files.')
    ..addFlag('parallel',
        abbr: 'p',
        defaultsTo: true,
        help: 'Enable parallel processing for better performance.')
    ..addOption('threads',
        help: 'Number of parallel threads to use (default: auto-detect).',
        valueHelp: 'NUM');
}

/// Enhanced mutation rule parsing with validation
List<MutationRule> parseMutationRules(String ruleTypesString) {
  final typeNames = ruleTypesString
      .split(',')
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .toList();
  
  if (typeNames.isEmpty) {
    print('Warning: No mutation types specified. Using arithmetic as default.');
    return Mutator.getRulesByType(MutationType.arithmetic);
  }
  
  final types = <MutationType>[];
  
  for (final typeName in typeNames) {
    switch (typeName) {
      case 'arithmetic':
        types.add(MutationType.arithmetic);
        break;
      case 'logical':
        types.add(MutationType.logical);
        break;
      case 'relational':
        types.add(MutationType.relational);
        break;
      case 'datatype':
        types.add(MutationType.datatype);
        break;
      case 'functioncall':
        types.add(MutationType.functionCall);
        break;
      case 'all':
        return Mutator.getAllRules();
      default:
        print('Warning: Unknown mutation type "$typeName". Ignoring.');
    }
  }
  
  if (types.isEmpty) {
    print('Warning: No valid mutation types specified. Using arithmetic as default.');
    return Mutator.getRulesByType(MutationType.arithmetic);
  }
  
  return Mutator.getRulesByTypes(types);
}

/// Print optimized usage information
void printUsage(ArgParser parser) {
  print('Smart Mutation - Dart Mutation Testing Tool');
  print('');
  print('Usage: dart run smart_mutation [options] [input_directory] [output_directory]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Available mutation types:');
  print('  arithmetic   - Mutate arithmetic operators (+, -, *, /, %, ++, --)');
  print('  logical      - Mutate logical operators (&&, ||, !)');
  print('  relational   - Mutate relational operators (==, !=, >, <, >=, <=)');
  print('  datatype     - Mutate data types (int, double, String, bool, List, etc.)');
  print('  functionCall - Mutate function calls (print, add, length, etc.)');
  print('  all          - Apply all mutation types');
  print('');
  print('Note: By default, when multiple rule types are specified, separate mutation');
  print('      files are generated for each type (e.g., file_arithmetic_mutated.dart,');
  print('      file_logical_mutated.dart, etc.). Use --cumulative to apply all');
  print('      mutations to a single file instead.');
  print('');
  print('Examples:');
  print('  dart run smart_mutation --input ./src --output ./mutations');
  print('  dart run smart_mutation -i ./src -o ./mutations --rules arithmetic,logical');
  print('  dart run smart_mutation -i ./src -o ./mutations -r all --verbose');
  print('  dart run smart_mutation -i ./src -o ./mutations -r all --cumulative  # All mutations in one file');
  print('  dart run smart_mutation -i ./src -o ./mutations --no-track  # Disable tracking');
  print('  dart run smart_mutation ./src ./mutations  # Positional arguments');
  print('  dart run smart_mutation --help  # Show this help');
}
