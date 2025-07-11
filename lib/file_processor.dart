import 'dart:io';
import 'package:smart_mutation/mutator.dart';
import 'package:path/path.dart' as path;
import 'cli_config.dart';
import 'output_utils.dart';

/// Run the mutation testing process with enhanced performance
Future<void> runMutationTesting(CliConfig config) async {
  // Validate required fields for legacy mode
  if (config.inputDir == null || config.outputDir == null) {
    throw Exception('Input and output directories are required for legacy mode');
  }

  // Validate and create directories
  await validateDirectories(config);

  print('Mutating Dart files from "${config.inputDir}" to "${config.outputDir}"...');
  
  final mutator = Mutator();
  final stopwatch = Stopwatch()..start();
  
  // Find all Dart files efficiently
  final dartFiles = await findDartFiles(config.inputDir!, config.verbose);
  
  if (dartFiles.isEmpty) {
    print('No Dart files found in input directory.');
    return;
  }

  if (config.verbose) {
    print('Found ${dartFiles.length} Dart files to process.');
  }

  // Process files with performance monitoring
  final results = await processFiles(dartFiles, mutator, config);
  
  stopwatch.stop();
  
  // Print summary
  printSummary(results, stopwatch.elapsed, config);
}

/// Validate input directory and create output directory
Future<void> validateDirectories(CliConfig config) async {
  if (config.inputDir == null || config.outputDir == null) {
    throw Exception('Input and output directories are required');
  }

  final inputDirectory = Directory(config.inputDir!);
  if (!await inputDirectory.exists()) {
    throw Exception('Input directory "${config.inputDir}" does not exist.');
  }

  final outputDirectory = Directory(config.outputDir!);
  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
    if (config.verbose) {
      print('Created output directory: ${config.outputDir}');
    }
  }
}

/// Find all Dart files in the input directory efficiently
Future<List<File>> findDartFiles(String inputDir, bool verbose) async {
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
Future<ProcessingResults> processFiles(
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
        print('Processing: ${path.relative(dartFile.path, from: config.inputDir!)}');
      }
      
      final mutationCount = await processSingleFile(dartFile, mutator, config);
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
Future<int> processSingleFile(File dartFile, Mutator mutator, CliConfig config) async {
  if (config.inputDir == null || config.outputDir == null) {
    throw Exception('Input and output directories are required');
  }

  final code = await dartFile.readAsString();
  
  // Create relative path structure in output directory
  final relativePath = path.relative(dartFile.path, from: config.inputDir!);
  final outputFileDir = path.dirname(path.join(config.outputDir!, relativePath));
  
  // Create subdirectories if needed
  await Directory(outputFileDir).create(recursive: true);
  
  // Prepare file paths
  final fileName = path.basenameWithoutExtension(dartFile.path);
  final fileExtension = path.extension(dartFile.path);
  final basePath = path.join(outputFileDir, fileName);
  
  if (config.useCumulative) {
    return await processCumulativeMutation(
      code, mutator, config, basePath, fileExtension, dartFile);
  } else {
    return await processMultipleMutations(
      code, mutator, config, basePath, fileExtension, dartFile);
  }
}

/// Handle cumulative mutations for a single file
Future<int> processCumulativeMutation(
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
Future<int> processMultipleMutations(
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
