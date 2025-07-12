import 'dart:io';
import 'package:smart_mutation/mutator.dart';
import 'package:path/path.dart' as path;
import 'config_model.dart';
import 'mutation_reporter.dart';

/// Result of processing with detailed information
class ProcessingResults {
  const ProcessingResults({
    required this.filesProcessed,
    required this.totalMutations,
    required this.errors,
    required this.outputFiles,
    required this.skippedFiles,
  });

  final int filesProcessed;
  final int totalMutations;
  final List<String> errors;
  final List<String> outputFiles;
  final List<String> skippedFiles;
}

/// Enhanced file processor using JSON configuration
class JsonConfigProcessor {
  const JsonConfigProcessor();

  /// Main processing method using JSON configuration
  Future<ProcessingResults> processWithConfig(SmartMutationConfig config) async {
    final stopwatch = Stopwatch()..start();
    
    if (config.verbose) {
      print('Smart Mutation Tool - JSON Configuration Mode');
      print('Configuration: $config');
      print('');
    }

    // Validate configuration
    final validationErrors = config.validate();
    if (validationErrors.isNotEmpty) {
      throw Exception('Configuration validation failed:\n${validationErrors.join('\n')}');
    }

    // Validate and create directories
    await _validateAndCreateDirectories(config);

    print('Processing files with JSON configuration...');
    
    final mutator = Mutator();
    
    // Find all Dart files from input paths
    final dartFiles = await _findDartFilesFromPaths(config);
    
    if (dartFiles.isEmpty) {
      print('No Dart files found matching the configuration.');
      return const ProcessingResults(
        filesProcessed: 0,
        totalMutations: 0,
        errors: [],
        outputFiles: [],
        skippedFiles: [],
      );
    }

    if (config.verbose) {
      print('Found ${dartFiles.length} Dart files to process.');
    }

    // Process files with configuration
    final results = await _processFilesWithConfig(dartFiles, mutator, config);
    
    stopwatch.stop();
    
    // Run mutation tests if configured
    if (config.runTests && results.outputFiles.isNotEmpty) {
      await _runMutationTests(results, config);
    } else if (results.outputFiles.isNotEmpty) {
      // Generate reports even without running tests
      await _generateStandaloneReport(results, config);
    }
    
    // Print comprehensive summary
    _printConfigSummary(results, stopwatch.elapsed, config);
    
    return results;
  }

  /// Validate input paths and create output directory
  Future<void> _validateAndCreateDirectories(SmartMutationConfig config) async {
    // Validate input paths
    for (final inputPath in config.inputPaths) {
      final entity = File(inputPath);
      final dir = Directory(inputPath);
      
      if (!await entity.exists() && !await dir.exists()) {
        throw Exception('Input path does not exist: $inputPath');
      }
    }

    // Create output directory
    final outputDirectory = Directory(config.outputDir);
    if (!await outputDirectory.exists()) {
      await outputDirectory.create(recursive: true);
      if (config.verbose) {
        print('Created output directory: ${config.outputDir}');
      }
    }
  }

  /// Find Dart files from multiple input paths with pattern matching
  Future<List<File>> _findDartFilesFromPaths(SmartMutationConfig config) async {
    final dartFiles = <File>[];
    final processedPaths = <String>{};
    
    for (final inputPath in config.inputPaths) {
      final entity = FileSystemEntity.typeSync(inputPath);
      
      if (entity == FileSystemEntityType.file) {
        // Single file
        if (inputPath.endsWith('.dart') && _shouldIncludeFile(inputPath, config)) {
          final file = File(inputPath);
          if (!processedPaths.contains(file.absolute.path)) {
            dartFiles.add(file);
            processedPaths.add(file.absolute.path);
          }
        }
      } else if (entity == FileSystemEntityType.directory) {
        // Directory - scan recursively
        final dirFiles = await _findDartFilesInDirectory(inputPath, config);
        for (final file in dirFiles) {
          if (!processedPaths.contains(file.absolute.path)) {
            dartFiles.add(file);
            processedPaths.add(file.absolute.path);
          }
        }
      }
    }
    
    return dartFiles;
  }

  /// Find Dart files in a specific directory with pattern matching
  Future<List<File>> _findDartFilesInDirectory(
    String dirPath, 
    SmartMutationConfig config
  ) async {
    final directory = Directory(dirPath);
    final dartFiles = <File>[];
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && 
          entity.path.endsWith('.dart') && 
          _shouldIncludeFile(entity.path, config)) {
        dartFiles.add(entity);
      }
    }
    
    return dartFiles;
  }

  /// Check if file should be included based on include/exclude patterns
  bool _shouldIncludeFile(String filePath, SmartMutationConfig config) {
    final relativePath = path.normalize(filePath);
    
    // Check exclude patterns first
    for (final excludePattern in config.excludePatterns) {
      if (_matchesGlobPattern(relativePath, excludePattern)) {
        return false;
      }
    }
    
    // Check include patterns
    for (final includePattern in config.includePatterns) {
      if (_matchesGlobPattern(relativePath, includePattern)) {
        return true;
      }
    }
    
    return false;
  }

  /// Simple glob pattern matching
  bool _matchesGlobPattern(String filePath, String pattern) {
    // Convert glob pattern to regex
    var regexPattern = pattern
        .replaceAll('**', '.*')
        .replaceAll('*', '[^/]*')
        .replaceAll('?', '[^/]');
    
    return RegExp(regexPattern).hasMatch(filePath);
  }

  /// Process files with JSON configuration settings
  Future<ProcessingResults> _processFilesWithConfig(
    List<File> dartFiles, 
    Mutator mutator, 
    SmartMutationConfig config
  ) async {
    var filesProcessed = 0;
    var totalMutations = 0;
    final errors = <String>[];
    final outputFiles = <String>[];
    final skippedFiles = <String>[];

    for (final dartFile in dartFiles) {
      try {
        if (config.verbose) {
          print('Processing: ${path.relative(dartFile.path)}');
        }
        
        final result = await _processSingleFileWithConfig(dartFile, mutator, config);
        
        if (result.mutationCount > 0) {
          totalMutations += result.mutationCount;
          outputFiles.addAll(result.outputPaths);
          filesProcessed++;
        } else {
          skippedFiles.add(dartFile.path);
        }
        
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
      outputFiles: outputFiles,
      skippedFiles: skippedFiles,
    );
  }

  /// Process a single file with configuration-specific settings
  Future<FileProcessingResult> _processSingleFileWithConfig(
    File dartFile, 
    Mutator mutator, 
    SmartMutationConfig config
  ) async {
    final code = await dartFile.readAsString();
    final relativePath = path.relative(dartFile.path);
    
    // Check if file has specific line range configuration
    final lineRange = config.lineRanges[relativePath] ?? 
                     config.lineRanges[dartFile.absolute.path];
    
    // Create flattened output structure (remove input path prefix)
    final fileName = path.basenameWithoutExtension(dartFile.path);
    final fileExtension = path.extension(dartFile.path);
    
    // Create output directory if needed
    await Directory(config.outputDir).create(recursive: true);
    
    final basePath = path.join(config.outputDir, fileName);
    
    if (config.useCumulative) {
      return await _processCumulativeWithConfig(
        code, mutator, config, basePath, fileExtension, dartFile, lineRange);
    } else {
      return await _processMultipleWithConfig(
        code, mutator, config, basePath, fileExtension, dartFile, lineRange);
    }
  }

  /// Handle cumulative mutations with configuration
  Future<FileProcessingResult> _processCumulativeWithConfig(
    String code, 
    Mutator mutator, 
    SmartMutationConfig config,
    String basePath,
    String fileExtension,
    File originalFile,
    LineRange? lineRange
  ) async {
    final cumulativeOutputPath = '$basePath${'_mutated'}$fileExtension';
    
    final cumulativeResult = mutator.performCumulativeMutationsWithCount(
      code,
      config.mutationRules,
      startLine: lineRange?.startLine,
      endLine: lineRange?.endLine,
      outputFilePath: cumulativeOutputPath,
      trackMutations: config.enableTracking,
    );
    
    if (cumulativeResult != null) {
      print('  Generated cumulative mutation for ${path.basename(originalFile.path)} (${cumulativeResult.mutationCount} mutations)');
      return FileProcessingResult(
        mutationCount: cumulativeResult.mutationCount, 
        outputPaths: [cumulativeOutputPath]
      );
    } else {
      if (config.verbose) {
        print('  No mutations found to apply in ${path.basename(originalFile.path)}');
      }
      return const FileProcessingResult(mutationCount: 0, outputPaths: []);
    }
  }

  /// Handle multiple separate mutations with configuration
  Future<FileProcessingResult> _processMultipleWithConfig(
    String code, 
    Mutator mutator, 
    SmartMutationConfig config,
    String basePath,
    String fileExtension,
    File originalFile,
    LineRange? lineRange
  ) async {
    final mutations = mutator.performMultipleMutations(
      code, 
      config.mutationRules,
      startLine: lineRange?.startLine,
      endLine: lineRange?.endLine,
      outputBasePath: '$basePath$fileExtension',
      trackMutations: config.enableTracking,
    );
    
    if (mutations.isNotEmpty) {
      final outputPaths = <String>[];
      for (final result in mutations) {
        final typeName = result.mutationType.displayName;
        print('  Generated $typeName mutation for ${path.basename(originalFile.path)}');
        if (result.outputPath != null) {
          outputPaths.add(result.outputPath!);
        }
      }
      return FileProcessingResult(
        mutationCount: mutations.length, 
        outputPaths: outputPaths
      );
    } else {
      if (config.verbose) {
        print('  No mutations found to apply in ${path.basename(originalFile.path)}');
      }
      return const FileProcessingResult(mutationCount: 0, outputPaths: []);
    }
  }

  Future<void> _runMutationTests(ProcessingResults results, SmartMutationConfig config) async {
    print('\n🧪 Running mutation tests...');
    
    if (config.testCommand == null) {
      print('⚠️  No test command specified in configuration');
      return;
    }
    
    if (results.outputFiles.isEmpty) {
      print('⚠️  No mutation files to test');
      return;
    }
    
    // Group mutation files by their original source
    final mutationsByOriginal = <String, List<String>>{};
    
    for (final mutationFile in results.outputFiles) {
      // Extract original file path from mutation file name
      final fileName = mutationFile.split('/').last;
      String originalFile;
      
      // Handle the flattened output structure - find corresponding input file
      if (fileName.contains('_arithmetic_') || 
          fileName.contains('_logical_') || 
          fileName.contains('_relational_') ||
          fileName.contains('_datatype_') ||
          fileName.contains('_function_')) {
        
        // Extract base name (remove mutation suffix)
        final baseName = fileName.split('_')[0] + '.dart';
        
        // Find matching original file from input paths
        String? matchingInput;
        for (final inputPath in config.inputPaths) {
          if (inputPath.endsWith(baseName) || inputPath.contains(baseName)) {
            matchingInput = inputPath;
            break;
          }
        }
        
        originalFile = matchingInput ?? config.inputPaths.first;
      } else {
        originalFile = config.inputPaths.first;
      }
      
      mutationsByOriginal.putIfAbsent(originalFile, () => []).add(mutationFile);
    }
    
    final allTestResults = <MutationTestResult>[];
    
    // Run tests for each original file and its mutations
    for (final entry in mutationsByOriginal.entries) {
      final originalFile = entry.key;
      final mutationFiles = entry.value;
      
      print('Testing mutations for: $originalFile');
      
      final testResults = await Mutator.runMutationTestSuite(
        originalFilePath: originalFile,
        mutatedFilePaths: mutationFiles,
        testCommand: config.testCommand,
        verbose: false,
      );
      
      // Expand cumulative results into individual mutation results
      final expandedResults = <MutationTestResult>[];
      for (final result in testResults) {
        if (config.useCumulative && result.mutationFile != null) {
          // For cumulative files, create separate results for each mutation
          final mutationCount = _countMutationsInFile(result.mutationFile!);
          final mutationTypes = _extractMutationTypesFromFile(result.mutationFile!);
          
          for (int i = 0; i < mutationCount; i++) {
            final mutationType = i < mutationTypes.length ? mutationTypes[i] : MutationType.arithmetic;
            expandedResults.add(MutationTestResult(
              mutationType: mutationType,
              testPassed: result.testPassed,
              testOutput: result.testOutput,
              mutationFile: result.mutationFile,
              executionTime: result.executionTime,
            ));
          }
        } else {
          expandedResults.add(result);
        }
      }
      
      allTestResults.addAll(expandedResults);
    }
    
    // Print comprehensive test results summary
    await _printEnhancedMutationTestSummary(allTestResults, config);
  }
  
  Future<void> _printEnhancedMutationTestSummary(
    List<MutationTestResult> results, 
    SmartMutationConfig config
  ) async {
    if (results.isEmpty) {
      print('\n📊 No mutation tests were executed.');
      return;
    }

    // Get the primary original file for the report
    final primaryOriginalFile = _getPrimaryOriginalFile(results, config);

    // Generate comprehensive report
    final report = await MutationTestReporter.generateReport(
      results: results,
      mutatedFiles: results.map((r) => r.mutationFile ?? '').where((f) => f.isNotEmpty).toList(),
      originalFile: primaryOriginalFile,
      includeDetailedAnalysis: true,
    );

    // Print detailed console report
    MutationTestReporter.printDetailedReport(report);

    // Save detailed report as HTML file (primary format)
    final htmlReportPath = '${config.outputDir}/mutation_test_report.html';
    await MutationTestReporter.generateReport(
      results: results,
      mutatedFiles: results.map((r) => r.mutationFile ?? '').where((f) => f.isNotEmpty).toList(),
      originalFile: primaryOriginalFile,
      outputPath: htmlReportPath,
      includeDetailedAnalysis: true,
      format: 'html',
    );
    print('\n🌐 Interactive HTML report saved to: $htmlReportPath');

    // Also save JSON report if verbose mode for backwards compatibility
    if (config.verbose) {
      final jsonReportPath = '${config.outputDir}/mutation_test_report.json';
      await MutationTestReporter.generateReport(
        results: results,
        mutatedFiles: results.map((r) => r.mutationFile ?? '').where((f) => f.isNotEmpty).toList(),
        originalFile: config.inputPaths.first,
        outputPath: jsonReportPath,
        includeDetailedAnalysis: true,
        format: 'json',
      );
      print('📄 JSON report also saved to: $jsonReportPath');
    }
  }

  /// Generate standalone HTML/JSON reports without running mutation tests
  Future<void> _generateStandaloneReport(ProcessingResults results, SmartMutationConfig config) async {
    if (results.outputFiles.isEmpty) {
      print('\n📊 No mutations generated - skipping report generation.');
      return;
    }

    print('\n📊 Generating mutation analysis report...');

    // Create mock mutation test results for report generation
    final mockResults = <MutationTestResult>[];
    
    for (final outputFile in results.outputFiles) {
      if (config.useCumulative) {
        // For cumulative files, create separate results for each mutation
        final mutationCount = _countMutationsInFile(outputFile);
        final mutationTypes = _extractMutationTypesFromFile(outputFile);
        
        for (int i = 0; i < mutationCount; i++) {
          final mutationType = i < mutationTypes.length ? mutationTypes[i] : MutationType.arithmetic;
          mockResults.add(MutationTestResult(
            mutationType: mutationType,
            testPassed: true, // Unknown without actual testing - assume no detection
            testOutput: 'No tests run - mutation analysis only',
            mutationFile: outputFile,
            executionTime: Duration.zero,
          ));
        }
      } else {
        // For separate mutation files, create one result per file
        mockResults.add(MutationTestResult(
          mutationType: MutationType.arithmetic, // Default type
          testPassed: true, // Unknown without actual testing - assume no detection
          testOutput: 'No tests run - mutation analysis only',
          mutationFile: outputFile,
          executionTime: Duration.zero,
        ));
      }
    }

    // Find the actual original file path for the mutations
    String originalFilePath = config.inputPaths.first;
    
    if (results.outputFiles.isNotEmpty) {
      final outputFile = results.outputFiles.first;
      final fileName = path.basenameWithoutExtension(outputFile);
      
      // Remove mutation suffixes to get original file name
      final originalFileName = fileName
          .replaceAll('_mutated', '')
          .replaceAll('_cumulative', '');
      
      // Try to find the matching original file
      for (final inputPath in config.inputPaths) {
        if (inputPath == '.') {
          // Search in current directory
          final candidateFile = '$originalFileName.dart';
          if (await File(candidateFile).exists()) {
            originalFilePath = candidateFile;
            break;
          }
        } else if (inputPath.contains(originalFileName)) {
          originalFilePath = inputPath;
          break;
        }
      }
    }

    // Print basic console report
    print('\n📊 MUTATION ANALYSIS SUMMARY');
    print('=' * 50);
    print('Total mutations generated: ${results.totalMutations}');
    print('Files processed: ${results.filesProcessed}');
    print('Output files created: ${results.outputFiles.length}');
    if (results.skippedFiles.isNotEmpty) {
      print('Files skipped: ${results.skippedFiles.length}');
    }

    // Generate comprehensive report for HTML file (primary format)
    final htmlReportPath = '${config.outputDir}/mutation_analysis_report.html';
    await MutationTestReporter.generateReport(
      results: mockResults,
      mutatedFiles: results.outputFiles,
      originalFile: originalFilePath,
      outputPath: htmlReportPath,
      includeDetailedAnalysis: true,
      format: 'html',
    );
    print('\n🌐 HTML mutation analysis report saved to: $htmlReportPath');

    // Also save JSON report if verbose mode
    if (config.verbose) {
      final jsonReportPath = '${config.outputDir}/mutation_analysis_report.json';
      await MutationTestReporter.generateReport(
        results: mockResults,
        mutatedFiles: results.outputFiles,
        originalFile: originalFilePath,
        outputPath: jsonReportPath,
        includeDetailedAnalysis: true,
        format: 'json',
      );
      print('📄 JSON analysis report also saved to: $jsonReportPath');
    }
  }

  /// Print comprehensive summary for JSON configuration processing
  void _printConfigSummary(
    ProcessingResults results, 
    Duration elapsed, 
    SmartMutationConfig config
  ) {
    print('\n🎯 Smart Mutation Complete!');
    print('Files processed: ${results.filesProcessed}');
    print('Files skipped: ${results.skippedFiles.length}');
    print('Total mutations generated: ${results.totalMutations}');
    print('Output files created: ${results.outputFiles.length}');
    print('Processing time: ${elapsed.inMilliseconds}ms');
    print('Output directory: ${config.outputDir}');
    
    if (config.verbose && results.outputFiles.isNotEmpty) {
      print('\nGenerated files:');
      for (final outputFile in results.outputFiles) {
        print('  - $outputFile');
      }
    }
    
    if (results.skippedFiles.isNotEmpty && config.verbose) {
      print('\nSkipped files (no mutations found):');
      for (final skippedFile in results.skippedFiles) {
        print('  - ${path.relative(skippedFile)}');
      }
    }
    
    if (results.errors.isNotEmpty) {
      print('\n⚠️  Errors encountered: ${results.errors.length}');
      if (config.verbose) {
        for (final error in results.errors) {
          print('  - $error');
        }
      }
    }
  }

  /// Map mutated files back to their original source files
  String _getOriginalFileForMutation(String mutatedFilePath, SmartMutationConfig config) {
    // Extract base filename from mutated file
    final basename = path.basenameWithoutExtension(mutatedFilePath);
    
    // Remove mutation suffixes to get original name (order matters!)
    String originalName = basename
        .replaceAll('_arithmetic_mutated', '')
        .replaceAll('_logical_mutated', '')
        .replaceAll('_relational_mutated', '')
        .replaceAll('_datatype_mutated', '')
        .replaceAll('_functionCall_mutated', '')
        .replaceAll('_mutated', ''); // General fallback
    
    // Search for the original file in input paths
    for (final inputPath in config.inputPaths) {
      final entity = FileSystemEntity.typeSync(inputPath);
      
      if (entity == FileSystemEntityType.file && inputPath.endsWith('$originalName.dart')) {
        return inputPath;
      } else if (entity == FileSystemEntityType.directory) {
        final originalFile = path.join(inputPath, '$originalName.dart');
        if (File(originalFile).existsSync()) {
          return originalFile;
        }
      }
    }
    
    // Enhanced fallback: try to find any file with the base name
    for (final inputPath in config.inputPaths) {
      if (FileSystemEntity.typeSync(inputPath) == FileSystemEntityType.directory) {
        final dir = Directory(inputPath);
        try {
          final files = dir.listSync().whereType<File>();
          for (final file in files) {
            final fileName = path.basenameWithoutExtension(file.path);
            if (fileName == originalName) {
              return file.path;
            }
          }
        } catch (e) {
          // Continue to next input path
        }
      }
    }
    
    // Final fallback: return the first input path if it's a file, or construct path
    if (config.inputPaths.isNotEmpty) {
      final firstPath = config.inputPaths.first;
      if (FileSystemEntity.typeSync(firstPath) == FileSystemEntityType.file) {
        return firstPath;
      } else {
        return path.join(firstPath, '$originalName.dart');
      }
    }
    
    return mutatedFilePath; // Last resort
  }

  /// Get the primary original file for report generation
  String _getPrimaryOriginalFile(List<MutationTestResult> results, SmartMutationConfig config) {
    // Try to find the most relevant original file
    for (final result in results) {
      if (result.mutationFile != null) {
        final originalFile = _getOriginalFileForMutation(result.mutationFile!, config);
        if (File(originalFile).existsSync()) {
          return originalFile;
        }
      }
    }
    
    // Fallback to first valid file in input paths
    for (final inputPath in config.inputPaths) {
      if (File(inputPath).existsSync()) {
        return inputPath;
      }
    }
    
    return config.inputPaths.first;
  }

  /// Count mutations in a cumulative file by analyzing mutation comments
  int _countMutationsInFile(String filePath) {
    try {
      final content = File(filePath).readAsStringSync();
      final mutationComments = RegExp(r'//\s*@\s*MUTATION:\s*\w+').allMatches(content);
      return mutationComments.length;
    } catch (e) {
      return 1; // Fallback to 1 if unable to count
    }
  }

  /// Extract mutation types from a cumulative file
  List<MutationType> _extractMutationTypesFromFile(String filePath) {
    try {
      final content = File(filePath).readAsStringSync();
      final mutationTypes = <MutationType>[];
      final mutationComments = RegExp(r'//\s*@\s*MUTATION:\s*(\w+)').allMatches(content);
      
      for (final match in mutationComments) {
        final typeName = match.group(1)?.toLowerCase();
        switch (typeName) {
          case 'arithmetic':
            mutationTypes.add(MutationType.arithmetic);
            break;
          case 'logical':
            mutationTypes.add(MutationType.logical);
            break;
          case 'relational':
            mutationTypes.add(MutationType.relational);
            break;
          case 'datatype':
            mutationTypes.add(MutationType.datatype);
            break;
          case 'functioncall':
            mutationTypes.add(MutationType.functionCall);
            break;
          case 'increment':
            mutationTypes.add(MutationType.arithmetic); // Treat increment as arithmetic
            break;
          default:
            mutationTypes.add(MutationType.arithmetic); // Default fallback
        }
      }
      
      return mutationTypes.isNotEmpty ? mutationTypes : [MutationType.arithmetic];
    } catch (e) {
      return [MutationType.arithmetic]; // Fallback
    }
  }

  /// Generate comprehensive mutation reports with proper file mappings
  Future<void> _generateComprehensiveReports(ProcessingResults results, SmartMutationConfig config) async {
    print('\n📊 Generating comprehensive mutation reports...');

    for (final outputFile in results.outputFiles) {
      final originalFile = _getOriginalFileForMutation(outputFile, config);
      
      // Generate detailed report for each mutated file
      await MutationTestReporter.generateReport(
        results: [MutationTestResult(
          mutationType: MutationType.arithmetic, // Default type
          testPassed: true, // Unknown without actual testing - assume no detection
          testOutput: 'No tests run - mutation analysis only',
          mutationFile: outputFile,
          executionTime: Duration.zero,
        )],
        mutatedFiles: [outputFile],
        originalFile: originalFile,
        includeDetailedAnalysis: true,
      );
      
      // Save report as HTML file
      final htmlReportPath = '${config.outputDir}/mutation_report_${path.basenameWithoutExtension(outputFile)}.html';
      await MutationTestReporter.generateReport(
        results: [MutationTestResult(
          mutationType: MutationType.arithmetic, // Default type
          testPassed: true, // Unknown without actual testing - assume no detection
          testOutput: 'No tests run - mutation analysis only',
          mutationFile: outputFile,
          executionTime: Duration.zero,
        )],
        mutatedFiles: [outputFile],
        originalFile: originalFile,
        outputPath: htmlReportPath,
        includeDetailedAnalysis: true,
        format: 'html',
      );
      print('  - HTML report saved to: $htmlReportPath');
    }
  }
}

/// Result of processing a single file
class FileProcessingResult {
  const FileProcessingResult({
    required this.mutationCount,
    required this.outputPaths,
  });

  final int mutationCount;
  final List<String> outputPaths;
}
