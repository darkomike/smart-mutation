import 'dart:io';
import 'package:smart_mutation/cli_config.dart';
import 'package:smart_mutation/config_model.dart';
import 'package:smart_mutation/json_processor.dart';

/// Optimized main entry point with enhanced performance and error handling
Future<void> main(List<String> arguments) async {
  final stopwatch = Stopwatch()..start();
  
  try {
    print('🚀 Smart Mutation Tool v2.1 - GitHub-Style Mutation Testing');
    
    final config = await parseArguments(arguments);
    await _runOptimizedJsonMode(config);
    
    stopwatch.stop();
    print('\n✅ Mutation testing completed in ${stopwatch.elapsedMilliseconds}ms');
    
  } catch (e, stackTrace) {
    stopwatch.stop();
    print('\n❌ Fatal error after ${stopwatch.elapsedMilliseconds}ms: $e');
    if (arguments.contains('--verbose') || arguments.contains('-v')) {
      print('Stack trace: $stackTrace');
    }
    exit(1);
  }
}

/// Optimized JSON configuration mode with performance enhancements
Future<void> _runOptimizedJsonMode(CliConfig cliConfig) async {
  SmartMutationConfig jsonConfig;
  
  if (cliConfig.useDefault) {
    jsonConfig = SmartMutationConfig.defaultConfig();
    
    if (cliConfig.verbose) {
      print('\n📋 Using optimized default configuration:');
      _printConfigDetails(jsonConfig);
    }
  } else {
    print('📂 Loading configuration from: ${cliConfig.configFile}');
    jsonConfig = await SmartMutationConfig.fromFile(cliConfig.configFile!);
    
    if (cliConfig.verbose) {
      print('\n📋 Loaded configuration:');
      _printConfigDetails(jsonConfig);
    }
  }
  
  // Apply CLI overrides efficiently
  if (cliConfig.verbose && !jsonConfig.verbose) {
    jsonConfig = _applyVerboseOverride(jsonConfig);
  }
  
  // Determine optimal processing strategy
  final processingStrategy = _determineOptimalStrategy(jsonConfig);
  print('🎯 Using $processingStrategy processing strategy');
  
  // Process with optimized configuration
  final processor = JsonConfigProcessor();
  await processor.processWithConfig(jsonConfig);
}

/// Apply verbose override efficiently
SmartMutationConfig _applyVerboseOverride(SmartMutationConfig config) {
  return SmartMutationConfig(
    inputPaths: config.inputPaths,
    outputDir: config.outputDir,
    mutationTypes: config.mutationTypes,
    enableTracking: config.enableTracking,
    useCumulative: config.useCumulative,
    verbose: true,
    excludePatterns: config.excludePatterns,
    includePatterns: config.includePatterns,
    lineRanges: config.lineRanges,
    parallel: config.parallel,
    maxThreads: config.maxThreads,
    runTests: config.runTests,
    testCommand: config.testCommand,
    mutationEngine: config.mutationEngine,
    llmConfig: config.llmConfig,
  );
}

/// Print configuration details in a clean format
void _printConfigDetails(SmartMutationConfig config) {
  print('  📁 Input paths: ${config.inputPaths.join(", ")}');
  print('  📤 Output directory: ${config.outputDir}');
  print('  🧬 Mutation types: ${config.mutationTypes.join(", ")}');
  print('  📊 Tracking enabled: ${config.enableTracking}');
  print('  🔄 Cumulative mode: ${config.useCumulative}');
  print('  ⚡ Parallel processing: ${config.parallel}');
  if (config.parallel) {
    print('  🧵 Max threads: ${config.maxThreads}');
  }
}

/// Determine optimal processing strategy based on configuration
String _determineOptimalStrategy(SmartMutationConfig config) {
  if (config.parallel && config.inputPaths.length > 1) {
    return 'Multi-threaded parallel';
  } else if (config.useCumulative) {
    return 'Cumulative mutation';
  } else {
    return 'Sequential';
  }
}
