# 🔧 Smart Mutation Tool v2.2 - Configuration Guide

This guide explains every field in the configuration file and how to use them effectively.

## 📋 Configuration File Structure

The Smart Mutation Tool uses JSON configuration files. Use `config_template.json` as your starting point.

## 🏗️ Core Configuration Fields

### Input/Output Settings

#### `inputPaths` (Required)
```json
"inputPaths": ["lib", "bin/my_app.dart"]
```
- **Type**: Array of strings
- **Description**: Files/directories to analyze for mutations
- **Supports**: Glob patterns like `"lib/**/*.dart"`, `"src/**/*.dart"`
- **Examples**:
  - `["lib"]` - Single directory
  - `["lib", "bin"]` - Multiple directories  
  - `["specific_file.dart"]` - Single file
  - `["lib/**/*.dart", "bin/**/*.dart"]` - Glob patterns

#### `outputDir` (Required)
```json
"outputDir": "output"
```
- **Type**: String
- **Description**: Directory where reports and mutated files are saved
- **Behavior**: Created automatically if it doesn't exist
- **Examples**: `"output"`, `"mutation_reports"`, `"test_results"`

### Mutation Configuration

#### `mutationTypes` (Required)
```json
"mutationTypes": ["arithmetic", "logical", "relational", "datatype", "increment", "functionCall"]
```
- **Type**: Array of strings
- **Available Types**:
  - `"arithmetic"` - `+`, `-`, `*`, `/`, `%` operators
  - `"logical"` - `&&`, `||`, `!` operators  
  - `"relational"` - `==`, `!=`, `>`, `<`, `>=`, `<=` operators
  - `"datatype"` - `int`, `double`, `String`, `bool`, `List`, `Set`, `Map` types
  - `"increment"` - `++`, `--` operators
  - `"functionCall"` - `print`, `add`, `length`, `toString`, method calls
- **Tip**: Remove types you don't want to test for faster execution

## ⚙️ Behavior Control

#### `enableTracking`
```json
"enableTracking": true
```
- **Type**: Boolean
- **true**: Adds `@ MUTATION: type` comments to mutated code
- **false**: Clean output without tracking comments
- **Recommendation**: Keep `true` for debugging and analysis

#### `useCumulative`
```json
"useCumulative": true
```
- **Type**: Boolean
- **true**: Apply ALL mutations to single files (recommended)
- **false**: Create separate files for each mutation type
- **Impact**: 
  - `true` = 1 file per input with all mutations
  - `false` = Multiple files per input (one per mutation type)

## 🧪 Test Execution

#### `runTests`
```json
"runTests": false
```
- **Type**: Boolean
- **false**: Quick mutation analysis only (no test execution)
- **true**: Run tests and analyze mutation detection rates
- **Performance**: `false` is much faster, `true` provides comprehensive analysis

#### `testCommand`
```json
"testCommand": "dart test"
```
- **Type**: String
- **Required**: Only if `runTests: true`
- **Examples**:
  - `"dart test"` - Standard Dart testing
  - `"flutter test"` - Flutter testing
  - `"dart test --coverage=coverage"` - With coverage
  - `"cd my_project && dart test"` - With directory change

## 📊 Output Control

#### `verbose`
```json
"verbose": false
```
- **Type**: Boolean
- **KEY BEHAVIOR**: Controls JSON file generation
- **false**: Clean output, HTML reports only (production mode)
- **true**: Detailed output + JSON reports (debug mode)
- **Important**: JSON files are ONLY generated when `verbose: true`

#### `reportFormat`
```json
"reportFormat": "html"
```
- **Type**: String
- **Current Options**: `"html"` only
- **Generates**: GitHub-style HTML reports with diff visualization
- **Future**: May support additional formats

## ⚡ Performance Settings

#### `parallel`
```json
"parallel": false
```
- **Type**: Boolean
- **false**: Single-threaded processing (safer, slower)
- **true**: Multi-threaded processing (faster, more CPU usage)
- **Recommendation**: Enable for large codebases

#### `maxThreads`
```json
"maxThreads": 2
```
- **Type**: Number
- **Used**: Only if `parallel: true`
- **Recommended**: 2-4 for most systems
- **Note**: Higher values may not improve performance

## 🎯 File Filtering

#### `excludePatterns`
```json
"excludePatterns": [
  "**/*_test.dart",
  "**/test/**",
  "**/*.g.dart",
  "**/generated/**"
]
```
- **Type**: Array of glob patterns
- **Purpose**: Files to exclude from mutation
- **Common Patterns**:
  - `"**/*_test.dart"` - All test files
  - `"**/test/**"` - Test directories
  - `"**/*.g.dart"` - Generated files
  - `"**/generated/**"` - Generated directories
  - `"**/build/**"` - Build directories

#### `includePatterns`

```json
"includePatterns": ["**/*.dart"]
```

- **Type**: Array of glob patterns
- **Purpose**: Files to include in mutation
- **Default**: `["**/*.dart"]` includes all Dart files
- **Examples**: `["lib/**/*.dart", "bin/**/*.dart"]` for specific directories

#### `maxSourceLines` (NEW in v2.2)

```json
"maxSourceLines": 500
```

- **Type**: Number
- **Purpose**: Maximum lines allowed in source files before skipping
- **Default**: `500` lines
- **Behavior**: Files exceeding this limit are automatically skipped
- **Rationale**: Focuses mutation effort on maintainable code files

#### `skipLargeFiles` (NEW in v2.2)

```json
"skipLargeFiles": true
```

- **Type**: Boolean
- **Purpose**: Enable/disable automatic skipping of large files
- **Default**: `true` (enabled)
- **false**: Process all files regardless of size
- **true**: Skip files exceeding `maxSourceLines`

#### `verboseSkipping` (NEW in v2.2)

```json
"verboseSkipping": true
```

- **Type**: Boolean
- **Purpose**: Show detailed messages when skipping files
- **Default**: `true` (show messages)
- **Enhanced Messages**: Includes emoji indicators and helpful tips

### 🎯 Advanced Features

#### `lineRanges`

```json
"lineRanges": {
  "lib/main.dart": {"start": 10, "end": 50},
  "lib/utils.dart": {"start": 1, "end": 100}
}
```

- **Type**: Object mapping file paths to line ranges
- **Purpose**: Apply mutations only to specific line ranges
- **Format**: `{"file_path": {"start": number, "end": number}}`
- **Default**: `{}` (mutate entire files)

## 📝 Configuration Examples

### Production Mode - Full Testing
```json
{
  "inputPaths": ["lib", "bin"],
  "outputDir": "mutation_reports",
  "mutationTypes": ["arithmetic", "logical", "relational", "datatype", "increment", "functionCall"],
  "enableTracking": true,
  "useCumulative": true,
  "runTests": true,
  "testCommand": "dart test --coverage=coverage",
  "verbose": false,
  "parallel": true,
  "maxThreads": 4,
  "excludePatterns": ["**/*_test.dart", "**/test/**", "**/*.g.dart"],
  "includePatterns": ["**/*.dart"],
  "reportFormat": "html"
}
```
**Result**: HTML reports + test coverage analysis (no JSON files)

### Quick Analysis Mode
```json
{
  "inputPaths": ["lib/specific_file.dart"],
  "outputDir": "quick_analysis",
  "mutationTypes": ["arithmetic", "logical"],
  "enableTracking": true,
  "useCumulative": true,
  "runTests": false,
  "verbose": false,
  "parallel": false,
  "maxThreads": 1,
  "excludePatterns": [],
  "includePatterns": ["**/*.dart"],
  "reportFormat": "html"
}
```
**Result**: Fast HTML reports (no test execution, no JSON files)

### Debug Mode
```json
{
  "inputPaths": ["lib"],
  "outputDir": "debug_output",
  "mutationTypes": ["arithmetic", "logical", "relational"],
  "enableTracking": true,
  "useCumulative": true,
  "runTests": false,
  "verbose": true,
  "parallel": false,
  "maxThreads": 1,
  "excludePatterns": ["**/*_test.dart"],
  "includePatterns": ["**/*.dart"],
  "reportFormat": "html"
}
```
**Result**: HTML + JSON reports + detailed console output

## 🚨 Common Issues & Solutions

### "Configuration validation failed"
**Problem**: Missing required fields or invalid values
**Solution**: Ensure `inputPaths`, `outputDir`, and `mutationTypes` are present

### "Input path does not exist"  
**Problem**: Path in `inputPaths` doesn't exist
**Solution**: Check file/directory paths and fix typos

### "No JSON files generated"
**Problem**: Expected JSON reports but only got HTML
**Solution**: Set `verbose: true` in configuration

### "Tests not running"
**Problem**: `runTests: true` but no test execution
**Solution**: Verify `testCommand` is correct for your project

### "Too slow execution"
**Problem**: Mutation testing takes too long
**Solution**: 
- Reduce `mutationTypes` array
- Set `runTests: false` for analysis only
- Enable `parallel: true` with appropriate `maxThreads`

## 💡 Best Practices

1. **Start Simple**: Begin with basic config and add complexity
2. **Use Cumulative Mode**: Set `useCumulative: true` for easier analysis
3. **Filter Wisely**: Exclude test files and generated code
4. **Test Incrementally**: Start with single files before entire projects
5. **Production vs Debug**: Use `verbose: false` for production, `verbose: true` for debugging
6. **Performance Tuning**: Enable parallel processing for large codebases

## 🔗 Related Documentation

- [`README.md`](README.md) - Complete tool documentation
- [`QUICK_START.md`](QUICK_START.md) - 30-second setup guide
- [`config_template.json`](config_template.json) - Commented configuration template

---

**Smart Mutation Tool v2.1** - Professional mutation testing made simple! 🎯
