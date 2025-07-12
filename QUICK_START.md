# 🚀 Smart Mutation Tool v2.1 - Quick Start Guide

## 📋 TL;DR - Get Started in 30 Seconds

```bash
# 1. Generate config template
dart bin/smart_mutation.dart --generate-example

# 2. Edit smart_mutation_config.json for your project

# 3. Run mutation testing
dart bin/smart_mutation.dart --config smart_mutation_config.json

# 4. Open HTML report
open output/mutation_test_report.html
```

## 🎯 Configuration Cheat Sheet

### Production Mode (Full Testing)
```json
{
  "inputPaths": ["lib"],
  "outputDir": "output", 
  "mutationTypes": ["arithmetic", "logical", "relational", "datatype", "increment", "functionCall"],
  "useCumulative": true,
  "runTests": true,
  "testCommand": "dart test",
  "verbose": false
}
```
**Result**: HTML report + test coverage analysis (no JSON files)

### Quick Analysis Mode
```json
{
  "inputPaths": ["file.dart"],
  "outputDir": "analysis",
  "mutationTypes": ["arithmetic", "logical"],
  "useCumulative": true,
  "runTests": false,
  "verbose": false
}
```
**Result**: HTML report only (fast, no test execution)

### Debug Mode
```json
{
  "inputPaths": ["lib"],
  "outputDir": "debug",
  "mutationTypes": ["arithmetic", "logical", "relational"],
  "useCumulative": true,
  "runTests": false,
  "verbose": true
}
```
**Result**: HTML + JSON reports + detailed console output

## 🔧 Key Settings Explained

| Setting | `true` | `false` |
|---------|--------|---------|
| `verbose` | Generates JSON files + detailed output | HTML only, clean output |
| `runTests` | Executes tests + coverage analysis | Quick mutation generation only |
| `useCumulative` | All mutations in single files | Separate file per mutation type |
| `parallel` | Multi-threaded processing | Single-threaded processing |

## 📊 Understanding Output

### Always Created
- `mutation_test_report.html` - GitHub-style visual report
- `*_mutated.dart` - Files with applied mutations

### Created with `verbose: true`
- `mutation_test_report.json` - Machine-readable report data

### Created with `runTests: true`
- Test coverage analysis in reports
- Mutation detection rates and grades

## ⚡ Common Commands

```bash
# Basic usage
dart bin/smart_mutation.dart --config config.json

# With verbose output
dart bin/smart_mutation.dart --config config.json --verbose

# Generate example config
dart bin/smart_mutation.dart --generate-example

# Get help
dart bin/smart_mutation.dart --help
```

## 🎨 Report Features

✅ **GitHub-Style Diffs**: Red/green line changes  
✅ **Mutation Badges**: Visual status indicators  
✅ **Quality Grading**: A+ to F test suite scores  
✅ **Professional Design**: Authentic GitHub styling  
✅ **Comprehensive Stats**: Detection rates by mutation type  

## 🚨 Troubleshooting

**"Input path does not exist"**  
→ Check `inputPaths` in your config file

**"Configuration validation failed"**  
→ Ensure all required fields are present

**No JSON files generated**  
→ Set `verbose: true` in configuration

**Tests not running**  
→ Set `runTests: true` and provide valid `testCommand`

---

**Ready to improve your code quality? Start mutating! 🧬**
