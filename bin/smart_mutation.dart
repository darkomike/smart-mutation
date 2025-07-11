import 'dart:io';
import 'package:smart_mutation/cli_config.dart';
import 'package:smart_mutation/file_processor.dart';
import 'package:smart_mutation/config_model.dart';
import 'package:smart_mutation/json_processor.dart';

/// Main entry point with enhanced error handling and performance
Future<void> main(List<String> arguments) async {
  try {
    final config = await parseArguments(arguments);
    
    if (config.isJsonMode) {
      await _runJsonMode(config);
    } else {
      await _runLegacyMode(config);
    }
  } catch (e) {
    print('Fatal error: $e');
    exit(1);
  }
}

/// Run JSON configuration mode
Future<void> _runJsonMode(CliConfig cliConfig) async {
  if (cliConfig.configFile == null) {
    throw Exception('Config file path is required for JSON mode');
  }

  print('🚀 Smart Mutation Tool - JSON Configuration Mode');
  
  // Load JSON configuration
  final jsonConfig = await SmartMutationConfig.fromFile(cliConfig.configFile!);
  
  if (cliConfig.verbose) {
    print('Loaded configuration from: ${cliConfig.configFile}');
    print('Configuration: $jsonConfig');
  }
  
  // Process with JSON configuration
  final processor = JsonConfigProcessor();
  await processor.processWithConfig(jsonConfig);
}

/// Run legacy directory mode
Future<void> _runLegacyMode(CliConfig config) async {
  if (config.inputDir == null || config.outputDir == null) {
    throw Exception('Input and output directories are required for legacy mode');
  }

  print('📁 Smart Mutation Tool - Legacy Directory Mode');
  
  if (config.verbose) {
    print('Note: Consider using JSON configuration mode for advanced features.');
    print('Generate example: dart run smart_mutation --generate-example');
    print('');
  }
  
  // Create a compatible config for the legacy processor
  final legacyConfig = CliConfig(
    inputDir: config.inputDir,
    outputDir: config.outputDir,
    mutationRules: config.mutationRules,
    enableTracking: config.enableTracking,
    useCumulative: config.useCumulative,
    verbose: config.verbose,
  );
  
  await runMutationTesting(legacyConfig);
}
