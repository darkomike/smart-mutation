import 'cli_config.dart';

/// Print comprehensive summary with performance metrics
void printSummary(ProcessingResults results, Duration elapsed, CliConfig config) {
  print('\nMutation complete!');
  print('Files processed: ${results.filesProcessed}');
  print('Total mutations generated: ${results.totalMutations}');
  print('Processing time: ${elapsed.inMilliseconds}ms');
  print('Output directory: ${config.outputDir}');
  
  if (results.errors.isNotEmpty) {
    print('\nErrors encountered: ${results.errors.length}');
    if (config.verbose) {
      for (final error in results.errors) {
        print('  - $error');
      }
    }
  }
}
