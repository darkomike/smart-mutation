import 'dart:io';
import 'package:args/args.dart';
import 'config_model.dart';

/// Configuration class for CLI arguments
class CliConfig {
  const CliConfig({
    this.configFile,
    this.verbose = false,
    this.generateExample = false,
    this.useDefault = false,
  });

  final String? configFile;
  final bool verbose;
  final bool generateExample;
  final bool useDefault;
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

  // Get configuration file path
  final configFile = results['config'] as String?;
  
  // Handle positional argument for config file
  if (configFile == null && results.rest.length == 1) {
    final configPath = results.rest[0];
    if (configPath.endsWith('.json')) {
      return CliConfig(
        configFile: configPath,
        verbose: results['verbose'] as bool,
      );
    }
  }

  // Use default configuration if no config file provided
  if (configFile == null && results.rest.isEmpty) {
    if (results['verbose'] as bool) {
      print('No configuration file provided. Using default configuration.');
      print('Target directories: lib/, bin/');
      print('Mutation types: arithmetic, logical, relational');
      print('Output directory: mutations/');
      print('');
      print('To use custom configuration:');
      print('  - Generate example: dart run smart_mutation --generate-example');
      print('  - Use custom config: dart run smart_mutation --config <file.json>');
      print('');
    }
    
    return CliConfig(
      configFile: null,
      verbose: results['verbose'] as bool,
      useDefault: true,
    );
  }

  // Error if config file is required but not provided
  if (configFile == null) {
    print('Error: Invalid argument provided.');
    print('');
    print('Usage: dart run smart_mutation [options] [config-file.json]');
    print('');
    print('Options:');
    print('  --config <file.json>     Use specific configuration file');
    print('  --generate-example       Generate example configuration');
    print('  --verbose               Show verbose output');
    print('  --help                  Show this help');
    print('');
    print('No arguments: Use default configuration (lib/, bin/ → mutations/)');
    print('');
    exit(1);
  }

  final verbose = results['verbose'] as bool;
  
  if (verbose) {
    print('Configuration file: $configFile');
    print('');
  }

  return CliConfig(
    configFile: configFile,
    verbose: verbose,
  );
}

/// Create streamlined argument parser for JSON-only mode
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
        help: 'Path to JSON configuration file.',
        valueHelp: 'CONFIG_FILE')
    ..addFlag('generate-example',
        abbr: 'g',
        negatable: false,
        help: 'Generate an example JSON configuration file and exit.')
    ..addOption('example-output',
        help: 'Output path for example configuration file.',
        defaultsTo: 'smart_mutation_config.json',
        valueHelp: 'FILE');
}

/// Print usage information for JSON-only mode
void printUsage(ArgParser parser) {
  print('Smart Mutation - Dart Mutation Testing Tool');
  print('');
  print('Usage:');
  print('  dart run smart_mutation [--config <config-file.json>]');
  print('  dart run smart_mutation <config-file.json>');
  print('  dart run smart_mutation                              # Use default config');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('JSON Configuration:');
  print('  All mutation settings can be configured through a JSON file.');
  print('  Generate example: dart run smart_mutation --generate-example');
  print('  No config file: Uses default settings (lib/, bin/ → mutations/)');
  print('');
  print('Configuration Options (in JSON file):');
  print('  inputPaths       - Array of files/directories to mutate');
  print('  outputDir        - Directory for mutated files');
  print('  mutationTypes    - Types: arithmetic, logical, relational, datatype, functionCall, all');
  print('  enableTracking   - Add @ MUTATION comments (true/false)');
  print('  useCumulative    - Apply all mutations to single file (true/false)');
  print('  verbose          - Show detailed output (true/false)');
  print('  excludePatterns  - Glob patterns to exclude files');
  print('  includePatterns  - Glob patterns to include files');
  print('  lineRanges       - Target specific line ranges in files');
  print('  parallel         - Enable parallel processing (true/false)');
  print('  maxThreads       - Number of threads for parallel processing');
  print('');
  print('Examples:');
  print('  # Use default configuration (lib/, bin/ → mutations/)');
  print('  dart run smart_mutation');
  print('');
  print('  # Generate example configuration');
  print('  dart run smart_mutation --generate-example');
  print('');
  print('  # Use configuration file');
  print('  dart run smart_mutation --config my_config.json');
  print('  dart run smart_mutation my_config.json');
  print('');
  print('  # Verbose output with default config');
  print('  dart run smart_mutation --verbose');
}
