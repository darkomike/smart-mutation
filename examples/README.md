# Examples

This directory contains example projects demonstrating how to use the Smart Mutation Tool.

## 📁 Available Examples

### `basic_calculator/`
A simple calculator project with basic arithmetic operations.

**Features:**
- Addition, subtraction, multiplication, division
- Unit tests for all operations
- Demonstrates arithmetic and logical mutations

**Usage:**
```bash
cd examples/basic_calculator
dart test  # Run tests first
cd ../..
dart run bin/smart_mutation.dart --config examples/example_config.json
```

## 🚀 Running Examples

1. **Navigate to project root:**
   ```bash
   cd /path/to/smart_mutation
   ```

2. **Run mutation testing on an example:**
   ```bash
   dart run bin/smart_mutation.dart --config examples/example_config.json
   ```

3. **View results:**
   - HTML Report: `output/mutation_test_report.html`
   - JSON Report: `output/mutation_test_report.json`

## 📋 Configuration Templates

Each example includes its own configuration showing different use cases:

- **`example_config.json`**: General configuration for testing the calculator example
- **`basic_calculator/smart_mutation_config.json`**: Local configuration for the calculator project

## 🎯 What to Expect

When you run mutation testing on these examples, you'll see:

1. **Mutation Generation**: The tool creates mutated versions of your code
2. **Test Execution**: Runs your test suite against each mutation
3. **Report Generation**: Creates beautiful HTML reports showing:
   - Which mutations were detected (tests failed)
   - Which mutations were missed (tests passed)
   - Code diff views showing exact changes
   - Quality metrics and recommendations

## 📊 Sample Output

```
🚀 Smart Mutation Tool v2.1 - GitHub-Style Mutation Testing
📂 Loading configuration from: examples/example_config.json
🎯 Using Sequential processing strategy

📊 OVERVIEW
----------------------------------------
Total mutations: 5
Mutations detected: 4
Detection rate: 80.0%
Test suite grade: B (Good)

💡 RECOMMENDATIONS
----------------------------------------
• Consider adding more comprehensive test cases
• Add tests for edge cases and boundary conditions
```

## 🔧 Customizing Examples

Feel free to:
- Modify the code in `basic_calculator/`
- Create your own examples
- Experiment with different mutation types
- Try different configuration options

Happy mutation testing! 🧬
