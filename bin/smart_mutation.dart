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
  
  // Load JSON configuration
  final jsonConfig = await SmartMutationConfig.fromFile(cliConfig.configFile);
  
  if (cliConfig.verbose) {
    print('Loaded configuration from: ${cliConfig.configFile}');
    print('Configuration: $jsonConfig');
  }
  
  // Process with JSON configuration
  final processor = JsonConfigProcessor();
  await processor.processWithConfig(jsonConfig);
}
