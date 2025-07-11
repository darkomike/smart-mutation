import 'dart:io';
import 'package:smart_mutation/cli_config.dart';
import 'package:smart_mutation/config_model.dart';
import 'package:smart_mutation/json_processor.dart';

/// Main entry point with JSON-only configuration
Future<void> main(List<String> arguments) async {
  try {
    final config = await parseArguments(arguments);
    await _runJsonMode(config);
  } catch (e) {
    print('Fatal error: $e');
    exit(1);
  }
}

/// Run JSON configuration mode
Future<void> _runJsonMode(CliConfig cliConfig) async {
  print('🚀 Smart Mutation Tool - JSON Configuration Mode');
  
  SmartMutationConfig jsonConfig;
  
  if (cliConfig.useDefault) {
    // Use default configuration
    jsonConfig = SmartMutationConfig.defaultConfig();
    
    if (cliConfig.verbose) {
      print('Using default configuration:');
      print('  Input paths: ${jsonConfig.inputPaths.join(", ")}');
      print('  Output directory: ${jsonConfig.outputDir}');
      print('  Mutation types: ${jsonConfig.mutationTypes.join(", ")}');
      print('  Tracking enabled: ${jsonConfig.enableTracking}');
      print('  Cumulative mode: ${jsonConfig.useCumulative}');
      print('  Parallel processing: ${jsonConfig.parallel}');
      print('');
    }
  } else {
    // Load JSON configuration from file
    jsonConfig = await SmartMutationConfig.fromFile(cliConfig.configFile!);
    
    if (cliConfig.verbose) {
      print('Loaded configuration from: ${cliConfig.configFile}');
      print('Configuration: $jsonConfig');
    }
  }
  
  // Override verbose setting if specified via CLI
  if (cliConfig.verbose && !jsonConfig.verbose) {
    jsonConfig = SmartMutationConfig(
      inputPaths: jsonConfig.inputPaths,
      outputDir: jsonConfig.outputDir,
      mutationTypes: jsonConfig.mutationTypes,
      enableTracking: jsonConfig.enableTracking,
      useCumulative: jsonConfig.useCumulative,
      verbose: true, // Override to true
      excludePatterns: jsonConfig.excludePatterns,
      includePatterns: jsonConfig.includePatterns,
      lineRanges: jsonConfig.lineRanges,
      parallel: jsonConfig.parallel,
      maxThreads: jsonConfig.maxThreads,
    );
  }
  
  // Process with JSON configuration
  final processor = JsonConfigProcessor();
  await processor.processWithConfig(jsonConfig);
}
