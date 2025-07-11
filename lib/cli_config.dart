import 'dart:io';
import 'package:args/args.dart';
import 'package:smart_mutation/mutator.dart';
import 'config_model.dart';

/// Configuration class for CLI arguments
class CliConfig {
  const CliConfig({
    this.inputDir,
    this.outputDir,
    this.mutationRules = const [],
    this.enableTracking = true,
    this.useCumulative = false,
    this.verbose = false,
    this.configFile,
    this.generateExample = false,
  });

  final String? inputDir;
  final String? outputDir;
  final List<MutationRule> mutationRules;
  final bool enableTracking;
  final bool useCumulative;
  final bool verbose;
  final String? configFile;
  final bool generateExample;

  /// Check if this is JSON configuration mode
  bool get isJsonMode => configFile != null;
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

  // Generate example configuration if requested
  if (results['generate-example'] as bool) {
    final outputPath = results['example-output'] as String? ?? 'smart_mutation_config.json';
    print('Generating example configuration file: $outputPath');
    
    await SmartMutationConfig.generateExample(outputPath);
    
    print('Example configuration file generated successfully!');
    print('Edit the file and run with: dart run smart_mutation --config $outputPath');
    exit(0);
  }

  // Check for JSON configuration mode
  final configFile = results['config'] as String?;
  if (configFile != null) {
    return CliConfig(
      configFile: configFile,
      verbose: results['verbose'] as bool,
    );
  }

  // Legacy directory mode
  var inputDir = results['input'] as String?;
  var outputDir = results['output'] as String?;

  // Handle positional arguments for backward compatibility
  if (inputDir == null && outputDir == null && results.rest.length >= 2) {
    inputDir = results.rest[0];
    outputDir = results.rest[1];
  }

  // Validate required arguments for legacy mode
  if (inputDir == null || outputDir == null) {
    print('Error: For directory mode, both input and output directories are required.');
    print('       For JSON mode, use --config <config-file.json>');
    print('       To generate example config, use --generate-example');
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
    print('Configuration (Legacy Directory Mode):');
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
    ..addOption('config',
        abbr: 'c',
        help: 'Path to JSON configuration file. When used, other options are ignored.',
        valueHelp: 'CONFIG_FILE')
    ..addFlag('generate-example',
        abbr: 'g',
        negatable: false,
        help: 'Generate an example JSON configuration file and exit.')
    ..addOption('example-output',
        help: 'Output path for example configuration file.',
        defaultsTo: 'smart_mutation_config.json',
        valueHelp: 'FILE')
    ..addOption('input',
        abbr: 'i',
        help: 'Input directory containing Dart files to mutate (legacy mode).',
        valueHelp: 'DIR')
    ..addOption('output',
        abbr: 'o',
        help: 'Output directory for mutated files (legacy mode).',
        defaultsTo: 'docs/mutations',
        valueHelp: 'DIR')
    ..addOption('rules',
        abbr: 'r',
        help: 'Comma-separated list of mutation types (legacy mode): arithmetic,logical,relational,datatype,functionCall,all',
        defaultsTo: 'arithmetic',
        valueHelp: 'TYPES')
    ..addFlag('track',
        abbr: 't',
        defaultsTo: true,
        help: 'Add @ MUTATION comments to track where mutations occurred (legacy mode).')
    ..addFlag('cumulative',
        defaultsTo: false,
        help: 'Apply all mutations cumulatively to a single file (legacy mode).')
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
  print('Usage:');
  print('  JSON Mode (Recommended):');
  print('    dart run smart_mutation --config <config-file.json>');
  print('  Legacy Directory Mode:');
  print('    dart run smart_mutation [options] [input_directory] [output_directory]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('JSON Configuration Mode:');
  print('  Use --config to specify a JSON configuration file with advanced settings.');
  print('  Generate example: dart run smart_mutation --generate-example');
  print('');
  print('Legacy Directory Mode - Available mutation types:');
  print('  arithmetic   - Mutate arithmetic operators (+, -, *, /, %, ++, --)');
  print('  logical      - Mutate logical operators (&&, ||, !)');
  print('  relational   - Mutate relational operators (==, !=, >, <, >=, <=)');
  print('  datatype     - Mutate data types (int, double, String, bool, List, etc.)');
  print('  functionCall - Mutate function calls (print, add, length, etc.)');
  print('  all          - Apply all mutation types');
  print('');
  print('Examples:');
  print('  # JSON mode (recommended)');
  print('  dart run smart_mutation --generate-example');
  print('  dart run smart_mutation --config my_config.json');
  print('');
  print('  # Legacy directory mode');
  print('  dart run smart_mutation --input ./src --output ./mutations');
  print('  dart run smart_mutation -i ./src -o ./mutations --rules arithmetic,logical');
  print('  dart run smart_mutation -i ./src -o ./mutations -r all --verbose');
  print('  dart run smart_mutation -i ./src -o ./mutations -r all --cumulative');
  print('  dart run smart_mutation ./src ./mutations  # Positional arguments');
}
