import 'dart:convert';
import 'dart:io';
import 'package:smart_mutation/mutator.dart';

/// Mutation engine types
enum MutationEngine {
  ruleBased,
  llm,
  hybrid
}

/// LLM Configuration for AI-powered mutations
class LLMConfig {
  const LLMConfig({
    required this.provider,
    required this.model,
    this.apiKey,
    this.baseUrl,
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.timeout = 30,
    this.retryAttempts = 3,
    this.customPrompt,
  });

  final LLMProvider provider;
  final String model;
  final String? apiKey;
  final String? baseUrl;
  final double temperature;
  final int maxTokens;
  final int timeout;
  final int retryAttempts;
  final String? customPrompt;

  /// Default LLM configuration for cloud-based AI (Google Gemini)
  static const LLMConfig defaultLocal = LLMConfig(
    provider: LLMProvider.gemini,
    model: 'gemini-pro',
    baseUrl: 'https://generativelanguage.googleapis.com',
    temperature: 0.7,
    maxTokens: 1000,
    timeout: 30,
    retryAttempts: 2,
  );

  /// Fallback LLM configuration with smaller model
  static const LLMConfig fallback = LLMConfig(
    provider: LLMProvider.gemini,
    model: 'gemini-pro',
    baseUrl: 'https://generativelanguage.googleapis.com',
    temperature: 0.5,
    maxTokens: 500,
    timeout: 20,
    retryAttempts: 1,
  );

  /// Fast LLM configuration for quick mutations
  static const LLMConfig fast = LLMConfig(
    provider: LLMProvider.gemini,
    model: 'gemini-pro',
    baseUrl: 'https://generativelanguage.googleapis.com',
    temperature: 0.3,
    maxTokens: 300,
    timeout: 15,
    retryAttempts: 1,
  );

  factory LLMConfig.fromJson(Map<String, dynamic> json) {
    return LLMConfig(
      provider: LLMProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => LLMProvider.gemini,
      ),
      model: json['model'] ?? 'codellama',
      apiKey: json['apiKey'],
      baseUrl: json['baseUrl'],
      temperature: (json['temperature'] ?? 0.7).toDouble(),
      maxTokens: json['maxTokens'] ?? 1000,
      timeout: json['timeout'] ?? 30,
      retryAttempts: json['retryAttempts'] ?? 3,
      customPrompt: json['customPrompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'model': model,
      if (apiKey != null) 'apiKey': apiKey,
      if (baseUrl != null) 'baseUrl': baseUrl,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'timeout': timeout,
      'retryAttempts': retryAttempts,
      if (customPrompt != null) 'customPrompt': customPrompt,
    };
  }
}

/// Supported LLM providers - Cloud-based free AI
enum LLMProvider {
  gemini,
}

/// Configuration model for JSON-based input
class SmartMutationConfig {
  const SmartMutationConfig({
    required this.inputPaths,
    required this.outputDir,
    required this.mutationTypes,
    this.enableTracking = true,
    this.useCumulative = false,
    this.verbose = false,
    this.excludePatterns = const [],
    this.includePatterns = const ['**/*.dart'],
    this.lineRanges = const {},
    this.parallel = true,
    this.maxThreads,
    this.runTests = false,
    this.testCommand,
    this.mutationEngine = MutationEngine.ruleBased,
    this.llmConfig,
  });

  final List<String> inputPaths;
  final String outputDir;
  final List<String> mutationTypes;
  final bool enableTracking;
  final bool useCumulative;
  final bool verbose;
  final List<String> excludePatterns;
  final List<String> includePatterns;
  final Map<String, LineRange> lineRanges;
  final bool parallel;
  final int? maxThreads;
  final bool runTests;
  final String? testCommand;
  final MutationEngine mutationEngine;
  final LLMConfig? llmConfig;

  /// Get effective LLM configuration
  LLMConfig get effectiveLLMConfig {
    if (llmConfig != null) return llmConfig!;
    
    // Use default LLM configuration based on mutation engine
    switch (mutationEngine) {
      case MutationEngine.llm:
      case MutationEngine.hybrid:
        return LLMConfig.defaultLocal;
      case MutationEngine.ruleBased:
        return LLMConfig.defaultLocal; // Still provide default for potential future use
    }
  }

  /// Create default configuration for quick start
  factory SmartMutationConfig.defaultConfig() {
    return const SmartMutationConfig(
      inputPaths: ['lib/', 'src/'],
      outputDir: 'docs/mutations',
      mutationTypes: ['arithmetic', 'logical', 'relational'],
      enableTracking: true,
      useCumulative: true,
      verbose: false,
      excludePatterns: [
        '**/generated/**',
        '**/*.g.dart',
        '**/test/**',
      ],
      includePatterns: ['**/*.dart'],
      lineRanges: {},
      parallel: true,
      maxThreads: null,
    );
  }

  /// Create configuration from JSON
  factory SmartMutationConfig.fromJson(Map<String, dynamic> json) {
    return SmartMutationConfig(
      inputPaths: List<String>.from(json['inputPaths'] ?? []),
      outputDir: json['outputDir'] as String? ?? 'mutations',
      mutationTypes: List<String>.from(json['mutationTypes'] ?? ['arithmetic']),
      enableTracking: json['enableTracking'] as bool? ?? true,
      useCumulative: json['useCumulative'] as bool? ?? false,
      verbose: json['verbose'] as bool? ?? false,
      excludePatterns: List<String>.from(json['excludePatterns'] ?? []),
      includePatterns: List<String>.from(json['includePatterns'] ?? ['**/*.dart']),
      lineRanges: _parseLineRanges(json['lineRanges'] as Map<String, dynamic>? ?? {}),
      parallel: json['parallel'] as bool? ?? true,
      maxThreads: json['maxThreads'] as int?,
      runTests: json['runTests'] as bool? ?? false,
      testCommand: json['testCommand'] as String?,
      mutationEngine: MutationEngine.values.firstWhere(
        (e) => e.name == json['mutationEngine'],
        orElse: () => MutationEngine.ruleBased,
      ),
      llmConfig: json['llmConfig'] != null
          ? LLMConfig.fromJson(json['llmConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'inputPaths': inputPaths,
      'outputDir': outputDir,
      'mutationTypes': mutationTypes,
      'enableTracking': enableTracking,
      'useCumulative': useCumulative,
      'verbose': verbose,
      'excludePatterns': excludePatterns,
      'includePatterns': includePatterns,
      'lineRanges': _lineRangesToJson(),
      'parallel': parallel,
      if (maxThreads != null) 'maxThreads': maxThreads,
      'runTests': runTests,
      if (testCommand != null) 'testCommand': testCommand,
      'mutationEngine': mutationEngine.name,
      if (llmConfig != null) 'llmConfig': llmConfig!.toJson(),
    };
  }

  /// Load configuration from JSON file
  static Future<SmartMutationConfig> fromFile(String configPath) async {
    try {
      final configFile = File(configPath);
      if (!await configFile.exists()) {
        throw Exception('Configuration file not found: $configPath');
      }

      final configContent = await configFile.readAsString();
      final configJson = jsonDecode(configContent) as Map<String, dynamic>;
      
      return SmartMutationConfig.fromJson(configJson);
    } catch (e) {
      throw Exception('Failed to load configuration from $configPath: $e');
    }
  }

  /// Generate example configuration file
  static Future<void> generateExample(String outputPath) async {
    final exampleConfig = SmartMutationConfig(
      inputPaths: [
        'lib/',
        'bin/',
        'test/',
      ],
      outputDir: 'mutations',
      mutationTypes: ['arithmetic', 'logical', 'relational'],
      enableTracking: true,
      useCumulative: false,
      verbose: true,
      excludePatterns: [
        '**/generated/**',
        '**/*.g.dart',
        '**/test/**',
      ],
      includePatterns: [
        '**/*.dart',
      ],
      lineRanges: {
        'lib/mutator.dart': LineRange(startLine: 1, endLine: 100),
        'bin/smart_mutation.dart': LineRange(startLine: 20, endLine: 50),
      },
      parallel: true,
      maxThreads: 4,
    );

    final configFile = File(outputPath);
    await configFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(exampleConfig.toJson())
    );
  }

  /// Parse mutation rules from string types
  List<MutationRule> get mutationRules {
    final types = <MutationType>[];
    
    for (final typeName in mutationTypes.map((s) => s.trim().toLowerCase())) {
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
        case 'conditional':
          types.add(MutationType.conditional);
          break;
        case 'increment':
          types.add(MutationType.increment);
          break;
        case 'assignment':
          types.add(MutationType.assignment);
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

  /// Validate configuration
  List<String> validate() {
    final errors = <String>[];

    if (inputPaths.isEmpty) {
      errors.add('inputPaths cannot be empty');
    }

    if (outputDir.isEmpty) {
      errors.add('outputDir cannot be empty');
    }

    if (mutationTypes.isEmpty) {
      errors.add('mutationTypes cannot be empty');
    }

    if (maxThreads != null && maxThreads! <= 0) {
      errors.add('maxThreads must be positive if specified');
    }

    // Validate that input paths exist
    for (final inputPath in inputPaths) {
      final entity = FileSystemEntity.typeSync(inputPath);
      if (entity == FileSystemEntityType.notFound) {
        errors.add('Input path does not exist: $inputPath');
      }
    }

    return errors;
  }

  /// Helper method to parse line ranges from JSON
  static Map<String, LineRange> _parseLineRanges(Map<String, dynamic> json) {
    final lineRanges = <String, LineRange>{};
    
    for (final entry in json.entries) {
      final rangeData = entry.value as Map<String, dynamic>;
      lineRanges[entry.key] = LineRange(
        startLine: rangeData['startLine'] as int,
        endLine: rangeData['endLine'] as int,
      );
    }
    
    return lineRanges;
  }

  /// Helper method to convert line ranges to JSON
  Map<String, dynamic> _lineRangesToJson() {
    final result = <String, dynamic>{};
    
    for (final entry in lineRanges.entries) {
      result[entry.key] = {
        'startLine': entry.value.startLine,
        'endLine': entry.value.endLine,
      };
    }
    
    return result;
  }

  @override
  String toString() {
    return 'SmartMutationConfig(inputs: ${inputPaths.length}, '
           'output: $outputDir, types: $mutationTypes, '
           'tracking: $enableTracking, cumulative: $useCumulative)';
  }
}

/// Line range specification for targeted mutations
class LineRange {
  const LineRange({
    required this.startLine,
    required this.endLine,
  });

  final int startLine;
  final int endLine;

  @override
  String toString() => 'LineRange($startLine-$endLine)';
}
