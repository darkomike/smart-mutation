import 'dart:io';
import 'package:smart_mutation/cli_config.dart';
import 'package:smart_mutation/file_processor.dart';

/// Main entry point with enhanced error handling and performance
Future<void> main(List<String> arguments) async {
  try {
    final config = await parseArguments(arguments);
    await runMutationTesting(config);
  } catch (e) {
    print('Fatal error: $e');
    exit(1);
  }
}
