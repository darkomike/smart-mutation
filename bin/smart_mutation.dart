import 'dart:io';
import 'package:args/args.dart';
import 'package:smart_mutation/mutator.dart';
import 'package:path/path.dart' as path;

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

/// Main entry point with enhanced error handling and performance
Future<void> main(List<String> arguments) async {
  try {
    final config = await _parseArguments(arguments);
    await _runMutationTesting(config);
  } catch (e) {
    print('Fatal error: $e');
    exit(1);
  }
}

/// Parse and validate command line arguments
Future<CliConfig> _parseArguments(List<String> arguments) async {
  final parser = _createArgParser();
  
  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    print('');
    _printUsage(parser);
    exit(1);
  }

  // Show help if requested
  if (results['help'] as bool) {
    _printUsage(parser);
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
    _printUsage(parser);
    exit(1);
  }

  final verbose = results['verbose'] as bool;
  final enableTracking = results['track'] as bool;
  final useCumulative = results['cumulative'] as bool;

  // Parse mutation rule types with validation
  final ruleTypesString = results['rules'] as String;
  final mutationRules = _parseMutationRules(ruleTypesString);
  
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
ArgParser _createArgParser() {
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

/// Run the mutation testing process with enhanced performance
Future<void> _runMutationTesting(CliConfig config) async {
  // Validate and create directories
  await _validateDirectories(config);

  print('Mutating Dart files from "${config.inputDir}" to "${config.outputDir}"...');
  
  final mutator = Mutator();
  final stopwatch = Stopwatch()..start();
  
  // Find all Dart files efficiently
  final dartFiles = await _findDartFiles(config.inputDir, config.verbose);
  
  if (dartFiles.isEmpty) {
    print('No Dart files found in input directory.');
    return;
  }

  if (config.verbose) {
    print('Found ${dartFiles.length} Dart files to process.');
  }

  // Process files with performance monitoring
  final results = await _processFiles(dartFiles, mutator, config);
  
  stopwatch.stop();
  
  // Print summary
  _printSummary(results, stopwatch.elapsed, config);
}

/// Validate input directory and create output directory
Future<void> _validateDirectories(CliConfig config) async {
  final inputDirectory = Directory(config.inputDir);
  if (!await inputDirectory.exists()) {
    throw Exception('Input directory "${config.inputDir}" does not exist.');
  }

  final outputDirectory = Directory(config.outputDir);
  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
    if (config.verbose) {
      print('Created output directory: ${config.outputDir}');
    }
  }
}

/// Find all Dart files in the input directory efficiently
Future<List<File>> _findDartFiles(String inputDir, bool verbose) async {
  final inputDirectory = Directory(inputDir);
  final dartFiles = <File>[];
  
  await for (final entity in inputDirectory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity);
    }
  }
  
  return dartFiles;
}

/// Process files with better error handling and performance
Future<ProcessingResults> _processFiles(
  List<File> dartFiles, 
  Mutator mutator, 
  CliConfig config
) async {
  var filesProcessed = 0;
  var totalMutations = 0;
  final errors = <String>[];

  for (final dartFile in dartFiles) {
    try {
      if (config.verbose) {
        print('Processing: ${path.relative(dartFile.path, from: config.inputDir)}');
      }
      
      final mutationCount = await _processSingleFile(dartFile, mutator, config);
      totalMutations += mutationCount;
      filesProcessed++;
      
    } catch (e, stackTrace) {
      final errorMsg = 'Error processing ${dartFile.path}: $e';
      errors.add(errorMsg);
      print(errorMsg);
      
      if (config.verbose) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  return ProcessingResults(
    filesProcessed: filesProcessed,
    totalMutations: totalMutations,
    errors: errors,
  );
}

/// Process a single file with optimized mutation handling
Future<int> _processSingleFile(File dartFile, Mutator mutator, CliConfig config) async {
  final code = await dartFile.readAsString();
  
  // Create relative path structure in output directory
  final relativePath = path.relative(dartFile.path, from: config.inputDir);
  final outputFileDir = path.dirname(path.join(config.outputDir, relativePath));
  
  // Create subdirectories if needed
  await Directory(outputFileDir).create(recursive: true);
  
  // Prepare file paths
  final fileName = path.basenameWithoutExtension(dartFile.path);
  final fileExtension = path.extension(dartFile.path);
  final basePath = path.join(outputFileDir, fileName);
  
  if (config.useCumulative) {
    return await _processCumulativeMutation(
      code, mutator, config, basePath, fileExtension, dartFile);
  } else {
    return await _processMultipleMutations(
      code, mutator, config, basePath, fileExtension, dartFile);
  }
}

/// Handle cumulative mutations for a single file
Future<int> _processCumulativeMutation(
  String code, 
  Mutator mutator, 
  CliConfig config,
  String basePath,
  String fileExtension,
  File originalFile
) async {
  final cumulativeOutputPath = '$basePath${'_mutated'}$fileExtension';
  
  final cumulativeMutation = mutator.performCumulativeMutations(
    code,
    config.mutationRules,
    outputFilePath: cumulativeOutputPath,
    trackMutations: config.enableTracking,
  );
  
  if (cumulativeMutation != null) {
    print('  Generated cumulative mutation for ${path.basename(originalFile.path)}');
    return 1;
  } else {
    if (config.verbose) {
      print('  No mutations found to apply in ${path.basename(originalFile.path)}');
    }
    return 0;
  }
}

/// Handle multiple separate mutations for a single file
Future<int> _processMultipleMutations(
  String code, 
  Mutator mutator, 
  CliConfig config,
  String basePath,
  String fileExtension,
  File originalFile
) async {
  final mutations = mutator.performMultipleMutations(
    code, 
    config.mutationRules,
    outputBasePath: '$basePath$fileExtension',
    trackMutations: config.enableTracking,
  );
  
  if (mutations.isNotEmpty) {
    for (final result in mutations) {
      final typeName = result.mutationType.displayName;
      print('  Generated $typeName mutation for ${path.basename(originalFile.path)}');
    }
    return mutations.length;
  } else {
    if (config.verbose) {
      print('  No mutations found to apply in ${path.basename(originalFile.path)}');
    }
    return 0;
  }
}

/// Print comprehensive summary with performance metrics
void _printSummary(ProcessingResults results, Duration elapsed, CliConfig config) {
  print('\\nMutation complete!');
  print('Files processed: ${results.filesProcessed}');
  print('Total mutations generated: ${results.totalMutations}');
  print('Processing time: ${elapsed.inMilliseconds}ms');
  print('Output directory: ${config.outputDir}');
  
  if (results.errors.isNotEmpty) {
    print('\\nErrors encountered: ${results.errors.length}');
    if (config.verbose) {
      for (final error in results.errors) {
        print('  - $error');
      }
    }
  }
}

/// Print optimized usage information
void _printUsage(ArgParser parser) {
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

/// Enhanced mutation rule parsing with validation
List<MutationRule> _parseMutationRules(String ruleTypesString) {
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
        print('Warning: Unknown mutation type \"$typeName\". Ignoring.');
    }
  }
  
  if (types.isEmpty) {
    print('Warning: No valid mutation types specified. Using arithmetic as default.');
    return Mutator.getRulesByType(MutationType.arithmetic);
  }
  
  return Mutator.getRulesByTypes(types);
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
