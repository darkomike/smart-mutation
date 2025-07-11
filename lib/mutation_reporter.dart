import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'mutator.dart';

/// Optimized GitHub-style reporting system for mutation testing results
class MutationTestReporter {
  /// Generate detailed mutation testing report with optimized performance
  static Future<MutationReport> generateReport({
    required List<MutationTestResult> results,
    required List<String> mutatedFiles,
    required String originalFile,
    String? outputPath,
    bool includeDetailedAnalysis = true,
    String format = 'html',
  }) async {
    final report = MutationReport(
      timestamp: DateTime.now(),
      originalFile: originalFile,
      totalMutations: results.length,
      mutatedFiles: mutatedFiles,
      results: results,
    );

    // Parallel analysis for better performance
    await Future.wait([
      Future(() => report._calculateStatistics()),
      if (includeDetailedAnalysis) ...[
        Future(() => report._analyzeTestSuiteQuality()),
        Future(() => report._analyzeMutationPatterns()),
        Future(() => report._generateRecommendations()),
      ],
    ]);

    if (outputPath != null) {
      if (format.toLowerCase() == 'html') {
        await _saveHtmlReport(report, outputPath, originalFile);
      } else {
        await _saveReportToFile(report, outputPath);
      }
    }

    return report;
  }

  /// Save JSON report with optimized formatting
  static Future<void> _saveReportToFile(MutationReport report, String outputPath) async {
    final jsonReport = report.toJson();
    final file = File(outputPath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonReport),
      mode: FileMode.write,
      flush: true,
    );
    print('📊 JSON mutation test report saved to: $outputPath');
  }

  /// Save optimized GitHub-style HTML report
  static Future<void> _saveHtmlReport(MutationReport report, String filePath, String originalFile) async {
    final htmlContent = await _generateOptimizedGitHubStyleHtml(report, originalFile);
    final htmlPath = filePath.endsWith('.html') ? filePath : '${filePath.replaceAll('.json', '')}.html';
    
    final file = File(htmlPath);
    await file.writeAsString(
      htmlContent,
      mode: FileMode.write,
      flush: true,
    );
    print('📊 GitHub-style HTML mutation test report saved to: $htmlPath');
  }

  /// Generate optimized GitHub-style HTML with lazy loading
  static Future<String> _generateOptimizedGitHubStyleHtml(MutationReport report, String originalFile) async {
    // Pre-calculate mutation cards asynchronously
    final mutationCardsFuture = _generateOptimizedMutationCards(report.results, originalFile);
    
    final cssStyles = _getOptimizedCSS();
    final headerHtml = _generateHeaderHtml(report);
    final recommendationsHtml = _generateRecommendationsHtml(report);
    
    // Wait for mutation cards to be ready
    final mutationCards = await mutationCardsFuture;
    
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mutation Testing Report - ${_escapeHtml(originalFile.split('/').last)}</title>
    $cssStyles
</head>
<body>
    <div class="container">
        $headerHtml
        $recommendationsHtml
        
        <div>
            <h2 style="margin-bottom: 16px; font-size: 20px;">🔍 Mutation Details</h2>
            $mutationCards
        </div>
        
        <div class="footer">
            Generated on ${report.timestamp} • Smart Mutation Testing Tool v2.1
        </div>
    </div>
    
    <script>
        // Lazy load diff content for better performance
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.mutation-card');
            cards.forEach(card => {
                card.addEventListener('click', function() {
                    const diffContent = card.querySelector('.diff-content');
                    if (diffContent && !diffContent.classList.contains('loaded')) {
                        diffContent.classList.add('loaded');
                    }
                });
            });
        });
    </script>
</body>
</html>''';
  }

  /// Generate optimized CSS with better performance
  static String _getOptimizedCSS() {
    return '''
    <style>
        /* Optimized CSS with better performance and GitHub styling */
        *, *::before, *::after { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif;
            line-height: 1.5;
            color: #24292f;
            background-color: #f6f8fa;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 24px;
        }
        
        .header {
            background: #ffffff;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 3px rgba(16, 22, 26, 0.1);
        }
        
        .header h1 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 8px;
            color: #24292f;
        }
        
        .summary-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 16px;
            margin: 16px 0;
        }
        
        .stat-box {
            text-align: center;
            padding: 12px;
            background: #f6f8fa;
            border-radius: 6px;
            border: 1px solid #d0d7de;
            transition: transform 0.2s ease;
        }
        
        .stat-box:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(16, 22, 26, 0.1);
        }
        
        .stat-number {
            font-size: 20px;
            font-weight: 600;
            color: #24292f;
        }
        
        .stat-label {
            font-size: 12px;
            color: #656d76;
            margin-top: 4px;
        }
        
        .grade-box {
            background: linear-gradient(135deg, #d4f4dd, #e6ffed);
            color: #1a7f37;
        }
        
        .mutation-card {
            background: #ffffff;
            border: 1px solid #d0d7de;
            border-radius: 6px;
            margin-bottom: 16px;
            overflow: hidden;
            cursor: pointer;
            transition: box-shadow 0.2s ease;
        }
        
        .mutation-card:hover {
            box-shadow: 0 4px 12px rgba(16, 22, 26, 0.15);
        }
        
        .mutation-header {
            padding: 16px;
            background: #f6f8fa;
            border-bottom: 1px solid #d0d7de;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .mutation-title {
            font-weight: 600;
            font-size: 14px;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-detected {
            background: #d4f4dd;
            color: #1a7f37;
        }
        
        .status-missed {
            background: #ffeef0;
            color: #cf222e;
        }
        
        .diff-content {
            font-family: ui-monospace, SFMono-Regular, "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
            font-size: 12px;
        }
        
        .diff-line {
            padding: 0 8px;
            line-height: 20px;
            white-space: pre;
        }
        
        .line-number {
            display: inline-block;
            width: 40px;
            text-align: right;
            margin-right: 16px;
            color: #656d76;
            user-select: none;
        }
        
        .line-removed {
            background: #ffebe9;
        }
        
        .line-removed::before {
            content: "-";
            color: #cf222e;
            font-weight: bold;
            margin-right: 8px;
        }
        
        .line-added {
            background: #e6ffed;
        }
        
        .line-added::before {
            content: "+";
            color: #1a7f37;
            font-weight: bold;
            margin-right: 8px;
        }
        
        .line-context {
            background: #ffffff;
        }
        
        .line-context::before {
            content: " ";
            margin-right: 8px;
        }
        
        .mutation-meta {
            padding: 12px 16px;
            background: #f6f8fa;
            border-top: 1px solid #d0d7de;
            font-size: 12px;
            color: #656d76;
        }
        
        .recommendations {
            background: #fff8c5;
            border: 1px solid #d4a72c;
            border-radius: 6px;
            padding: 16px;
            margin: 24px 0;
        }
        
        .recommendations h3 {
            color: #9a6700;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .recommendations ul {
            margin-left: 16px;
            color: #9a6700;
        }
        
        .footer {
            text-align: center;
            margin-top: 32px;
            padding: 16px;
            color: #656d76;
            font-size: 12px;
        }
        
        /* Performance optimizations */
        .mutation-card {
            contain: layout style;
        }
        
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>''';
  }

  /// Generate header HTML section
  static String _generateHeaderHtml(MutationReport report) {
    final gradeClass = _getGradeClass(report.detectionRate);
    
    return '''
        <div class="header">
            <h1>🧬 Mutation Testing Report</h1>
            <p>Analysis for <code>${_escapeHtml(report.originalFile)}</code></p>
            
            <div class="summary-stats">
                <div class="stat-box">
                    <div class="stat-number">${report.totalMutations}</div>
                    <div class="stat-label">Total Mutations</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">${report.detectedMutations}</div>
                    <div class="stat-label">Detected</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">${report.missedMutations}</div>
                    <div class="stat-label">Missed</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">${(report.detectionRate * 100).toStringAsFixed(1)}%</div>
                    <div class="stat-label">Detection Rate</div>
                </div>
                <div class="stat-box $gradeClass">
                    <div class="stat-number">${report.testSuiteGrade}</div>
                    <div class="stat-label">Grade</div>
                </div>
            </div>
        </div>''';
  }

  /// Generate recommendations HTML section
  static String _generateRecommendationsHtml(MutationReport report) {
    if (report.recommendations.isEmpty) return '';
    
    final recommendationItems = report.recommendations
        .map((rec) => '<li>${_escapeHtml(rec)}</li>')
        .join('');
    
    return '''
        <div class="recommendations">
            <h3>💡 Recommendations</h3>
            <ul>
                $recommendationItems
            </ul>
        </div>''';
  }

  /// Generate optimized mutation cards with better performance
  static Future<String> _generateOptimizedMutationCards(List<MutationTestResult> results, String originalFile) async {
    final buffer = StringBuffer();
    
    // Process cards in batches for better memory management
    const batchSize = 50;
    for (int i = 0; i < results.length; i += batchSize) {
      final end = math.min(i + batchSize, results.length);
      final batch = results.sublist(i, end);
      
      for (int j = 0; j < batch.length; j++) {
        final result = batch[j];
        final cardIndex = i + j + 1;
        final diffContent = await _generateOptimizedDiffView(result, originalFile);
        
        buffer.write('''
        <div class="mutation-card">
            <div class="mutation-header">
                <div class="mutation-title">
                    ${result.mutationType.displayName.toUpperCase()} mutation #$cardIndex
                </div>
                <span class="status-badge ${result.mutationDetected ? 'status-detected' : 'status-missed'}">
                    ${result.mutationDetected ? '✅ Detected' : '❌ Missed'}
                </span>
            </div>
            <div class="diff-content">
                $diffContent
            </div>
            <div class="mutation-meta">
                <strong>Execution:</strong> ${result.executionTime?.inMilliseconds ?? 0}ms • 
                <strong>File:</strong> ${_escapeHtml(result.mutationFile ?? 'N/A')}
            </div>
        </div>
      ''');
      }
    }
    
    return buffer.toString();
  }

  /// Generate optimized diff view for better performance
  static Future<String> _generateOptimizedDiffView(MutationTestResult result, String originalFile) async {
    try {
      final originalFileObj = File(originalFile);
      final mutatedFileObj = File(result.mutationFile ?? '');
      
      if (!await originalFileObj.exists() || !await mutatedFileObj.exists()) {
        return '<div class="diff-line">Unable to generate diff - files not available</div>';
      }
      
      // Read files concurrently for better performance
      final results = await Future.wait([
        originalFileObj.readAsLines(),
        mutatedFileObj.readAsLines(),
      ]);
      
      final originalLines = results[0];
      final mutatedLines = results[1];
      
      return _createOptimizedGitHubDiff(originalLines, mutatedLines, 1);
    } catch (e) {
      return '<div class="diff-line">Error: ${_escapeHtml(e.toString())}</div>';
    }
  }

  /// Create optimized GitHub-style diff HTML
  static String _createOptimizedGitHubDiff(List<String> originalLines, List<String> mutatedLines, int mutationLine) {
    final buffer = StringBuffer();
    const contextLines = 3;
    final startLine = math.max(0, mutationLine - contextLines - 1);
    final endLine = math.min(originalLines.length, mutationLine + contextLines);
    
    for (int i = startLine; i < endLine; i++) {
      final displayLineNumber = i + 1;
      
      if (i < originalLines.length && i < mutatedLines.length) {
        final originalLine = originalLines[i];
        final mutatedLine = mutatedLines[i];
        
        if (i == mutationLine - 1 && originalLine != mutatedLine) {
          // Show the mutation with optimized HTML
          buffer.writeln('<div class="diff-line line-removed"><span class="line-number">$displayLineNumber</span>${_escapeHtml(originalLine)}</div>');
          buffer.writeln('<div class="diff-line line-added"><span class="line-number">$displayLineNumber</span>${_escapeHtml(mutatedLine)}</div>');
        } else {
          // Context line
          buffer.writeln('<div class="diff-line line-context"><span class="line-number">$displayLineNumber</span>${_escapeHtml(originalLine)}</div>');
        }
      }
    }
    
    return buffer.toString();
  }

  /// Optimized HTML escaping
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Get grade CSS class based on detection rate
  static String _getGradeClass(double detectionRate) {
    if (detectionRate > 0.8) return 'grade-box';
    return 'stat-box';
  }

  /// Print optimized console report
  static void printDetailedReport(MutationReport report) {
    final divider = '=' * 80;
    final subDivider = '-' * 40;
    
    print('\n$divider');
    print('🧬 MUTATION TEST REPORT');
    print(divider);
    
    print('\n📊 OVERVIEW');
    print(subDivider);
    print('Report generated: ${report.timestamp}');
    print('Original file: ${report.originalFile}');
    print('Total mutations: ${report.totalMutations}');
    print('Mutations detected: ${report.detectedMutations}');
    print('Mutations missed: ${report.missedMutations}');
    print('Overall detection rate: ${(report.detectionRate * 100).toStringAsFixed(1)}%');
    print('Test suite grade: ${report.testSuiteGrade}');
    
    if (report.mutationTypeStats.isNotEmpty) {
      print('\n📈 STATISTICS BY MUTATION TYPE');
      print(subDivider);
      for (final stat in report.mutationTypeStats) {
        final symbol = stat.detected > 0 ? '✅' : '❌';
        print('$symbol ${stat.mutationType.padRight(12)} : ${stat.detected}/${stat.total} detected (${(stat.detectionRate * 100).toStringAsFixed(1)}%)');
      }
    }
    
    print('\n🎯 TEST SUITE QUALITY ANALYSIS');
    print(subDivider);
    print('Quality score: ${report.qualityScore}/100');
    print('Coverage strength: ${report.coverageStrength}');
    print('Fault detection ability: ${report.faultDetectionAbility}');
    
    if (report.recommendations.isNotEmpty) {
      print('\n💡 RECOMMENDATIONS');
      print(subDivider);
      for (final recommendation in report.recommendations) {
        print('• $recommendation');
      }
    }
    
    print(divider);
  }
}

/// Optimized mutation testing report with better performance
class MutationReport {
  MutationReport({
    required this.timestamp,
    required this.originalFile,
    required this.totalMutations,
    required this.mutatedFiles,
    required this.results,
  });

  final DateTime timestamp;
  final String originalFile;
  final int totalMutations;
  final List<String> mutatedFiles;
  final List<MutationTestResult> results;

  // Calculated statistics - lazy initialization for better performance
  late final int detectedMutations = results.where((r) => r.mutationDetected).length;
  late final int missedMutations = totalMutations - detectedMutations;
  late final double detectionRate = totalMutations > 0 ? (detectedMutations / totalMutations) : 0;
  late final List<MutationTestResult> successfulMutations = results.where((r) => !r.mutationDetected).toList();

  // Quality analysis - computed on demand
  late int qualityScore;
  late String testSuiteGrade;
  late String coverageStrength;
  late String faultDetectionAbility;
  late List<MutationTypeStat> mutationTypeStats;
  late List<String> weaknessAreas;
  late List<String> strengthAreas;
  late List<String> commonFailurePatterns;
  late List<String> recommendations;

  void _calculateStatistics() {
    // Calculate grade efficiently
    testSuiteGrade = _calculateGrade(detectionRate);
    
    // Calculate mutation type statistics with better performance
    final typeGroups = <String, List<MutationTestResult>>{};
    for (final result in results) {
      final typeName = result.mutationType.displayName;
      typeGroups.putIfAbsent(typeName, () => []).add(result);
    }
    
    mutationTypeStats = typeGroups.entries.map((entry) {
      final detected = entry.value.where((r) => r.mutationDetected).length;
      final total = entry.value.length;
      final rate = total > 0 ? (detected / total) : 0.0;
      
      return MutationTypeStat(
        mutationType: entry.key,
        total: total,
        detected: detected,
        detectionRate: rate,
      );
    }).toList();
  }

  void _analyzeTestSuiteQuality() {
    // Optimized quality score calculation
    qualityScore = (detectionRate * 80).round();
    
    // Bonus for comprehensive mutation type coverage
    final uniqueTypes = mutationTypeStats.length;
    if (uniqueTypes >= 5) qualityScore += 15;
    else if (uniqueTypes >= 3) qualityScore += 10;
    
    qualityScore = math.min(100, qualityScore);
    
    // Assess coverage strength efficiently
    coverageStrength = _calculateCoverageStrength(detectionRate);
    faultDetectionAbility = _calculateFaultDetectionAbility(qualityScore);
  }

  void _analyzeMutationPatterns() {
    weaknessAreas = [];
    strengthAreas = [];
    
    for (final stat in mutationTypeStats) {
      if (stat.detectionRate == 0.0) {
        weaknessAreas.add('${stat.mutationType} mutations (0.0% detection)');
      } else if (stat.detectionRate < 0.5) {
        weaknessAreas.add('${stat.mutationType} mutations (${(stat.detectionRate * 100).toStringAsFixed(1)}% detection)');
      } else if (stat.detectionRate >= 0.8) {
        strengthAreas.add('${stat.mutationType} mutations (${(stat.detectionRate * 100).toStringAsFixed(1)}% detection)');
      }
    }
    
    // Identify common failure patterns efficiently
    commonFailurePatterns = [];
    if (successfulMutations.length > totalMutations * 0.3) {
      commonFailurePatterns.add('High number of undetected mutations suggests insufficient test coverage');
    }
  }

  void _generateRecommendations() {
    recommendations = [];
    
    // Performance-oriented recommendations
    if (detectionRate < 0.5) {
      recommendations.add('Critical: Improve overall test coverage - current detection rate is ${(detectionRate * 100).toStringAsFixed(1)}%');
    } else if (detectionRate < 0.8) {
      recommendations.add('Consider adding more comprehensive test cases to reach >80% detection rate');
    }
    
    // Type-specific recommendations
    for (final stat in mutationTypeStats) {
      if (stat.detectionRate < 0.3) {
        recommendations.add('Add more tests for ${stat.mutationType} operations');
      }
    }
    
    // Quality improvement suggestions
    if (qualityScore < 60) {
      recommendations.add('Consider adopting test-driven development (TDD) practices');
      recommendations.add('Add edge case testing for boundary conditions');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Excellent test coverage! Consider adding performance and integration tests');
    }
  }

  String _calculateGrade(double rate) {
    if (rate >= 0.95) return 'A+ (Excellent)';
    if (rate >= 0.85) return 'A (Very Good)';
    if (rate >= 0.75) return 'B (Good)';
    if (rate >= 0.65) return 'C (Fair)';
    if (rate >= 0.50) return 'D (Poor)';
    return 'F (Failing)';
  }

  String _calculateCoverageStrength(double rate) {
    if (rate >= 0.9) return 'Excellent';
    if (rate >= 0.7) return 'Good';
    if (rate >= 0.5) return 'Fair';
    if (rate >= 0.3) return 'Weak';
    return 'Very Weak';
  }

  String _calculateFaultDetectionAbility(int score) {
    if (score >= 80) return 'High';
    if (score >= 60) return 'Medium';
    if (score >= 40) return 'Low';
    return 'Very Low';
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'originalFile': originalFile,
      'totalMutations': totalMutations,
      'detectedMutations': detectedMutations,
      'missedMutations': missedMutations,
      'detectionRate': detectionRate,
      'testSuiteGrade': testSuiteGrade,
      'qualityScore': qualityScore,
      'coverageStrength': coverageStrength,
      'faultDetectionAbility': faultDetectionAbility,
      'mutationTypeStats': mutationTypeStats.map((s) => s.toJson()).toList(),
      'weaknessAreas': weaknessAreas,
      'strengthAreas': strengthAreas,
      'commonFailurePatterns': commonFailurePatterns,
      'recommendations': recommendations,
      'detailedResults': results.map((r) => {
        'mutationType': r.mutationType.displayName,
        'detected': r.mutationDetected,
        'executionTime': r.executionTime?.inMilliseconds,
        'mutationFile': r.mutationFile,
      }).toList(),
    };
  }
}

/// Statistics for a specific mutation type - immutable for better performance
class MutationTypeStat {
  const MutationTypeStat({
    required this.mutationType,
    required this.total,
    required this.detected,
    required this.detectionRate,
  });

  final String mutationType;
  final int total;
  final int detected;
  final double detectionRate;

  Map<String, dynamic> toJson() {
    return {
      'mutationType': mutationType,
      'total': total,
      'detected': detected,
      'detectionRate': detectionRate,
    };
  }
}
