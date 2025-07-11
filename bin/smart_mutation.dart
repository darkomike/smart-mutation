import 'dart:io';
import 'package:args/args.dart';
import 'package:smart_mutation/mutator.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {

  
  final parser = ArgParser()
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
        valueHelp: 'TYPES');

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

  // Get input and output directories
  String? inputDir = results['input'] as String?;
  String? outputDir = results['output'] as String?;

  // If no options provided, try positional arguments for backward compatibility
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

  final bool verbose = results['verbose'] as bool;

  // Parse mutation rule types
  String ruleTypesString = results['rules'] as String;
  List<MutationRule> mutationRules = _parseMutationRules(ruleTypesString);
  
  if (verbose) {
    print('Using mutation rules: $ruleTypesString');
  }

  // Validate input directory
  final inputDirectory = Directory(inputDir);
  if (!inputDirectory.existsSync()) {
    print('Error: Input directory "$inputDir" does not exist.');
    exit(1);
  }

  // Create output directory if it doesn't exist
  final outputDirectory = Directory(outputDir);
  if (!outputDirectory.existsSync()) {
    outputDirectory.createSync(recursive: true);
    if (verbose) print('Created output directory: $outputDir');
  }

  print('Mutating Dart files from "$inputDir" to "$outputDir"...');
  
  final mutator = Mutator();
  int filesProcessed = 0;
  int totalMutations = 0;

  // Find all Dart files in the input directory recursively
  final dartFiles = inputDirectory
      .listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>();

  for (File dartFile in dartFiles) {
    try {
      if (verbose) print('Processing: ${dartFile.path}');
      
      // Read the file content
      String code = dartFile.readAsStringSync();
      
      // Generate mutation
      String? mutation = mutator.performMutation(code, mutationRules);
      
      if (mutation != null) {
        // Create relative path structure in output directory
        String relativePath = path.relative(dartFile.path, from: inputDir);
        String outputFileDir = path.dirname(path.join(outputDir, relativePath));
        
        // Create subdirectories if needed
        Directory(outputFileDir).createSync(recursive: true);
        
        // Save the mutation
        String fileName = path.basenameWithoutExtension(dartFile.path);
        String fileExtension = path.extension(dartFile.path);
        String mutationPath = path.join(
          outputFileDir, 
          '${fileName}_mutated$fileExtension'
        );
        
        File(mutationPath).writeAsStringSync(mutation);
        
        print('  Generated mutation for ${path.basename(dartFile.path)}');
        totalMutations++;
      } else {
        if (verbose) print('  No mutations found to apply in ${path.basename(dartFile.path)}');
      }
      
      filesProcessed++;
    } catch (e) {
      print('Error processing ${dartFile.path}: $e');
    }
  }

  print('\nMutation complete!');
  print('Files processed: $filesProcessed');
  print('Total mutations generated: $totalMutations');
  print('Output directory: $outputDir');
}

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
  print('Examples:');
  print('  dart run smart_mutation --input ./src --output ./mutations');
  print('  dart run smart_mutation -i ./src -o ./mutations --rules arithmetic,logical');
  print('  dart run smart_mutation -i ./src -o ./mutations -r all --verbose');
  print('  dart run smart_mutation ./src ./mutations  # Positional arguments');
  print('  dart run smart_mutation --help  # Show this help');
}

/// Parse mutation rule types from command line string
List<MutationRule> _parseMutationRules(String ruleTypesString) {
  List<String> typeNames = ruleTypesString.split(',').map((s) => s.trim().toLowerCase()).toList();
  List<MutationType> types = [];
  
  for (String typeName in typeNames) {
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
