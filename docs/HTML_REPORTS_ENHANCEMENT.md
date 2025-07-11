# GitHub-Style Mutation Testing Reports - Complete! 🎉

## What's New
The Smart Mutation Tool now generates **GitHub-style HTML reports** with code diff views, just like GitHub's pull request interface!

## 🎨 GitHub-Inspired Design Features

### Visual Interface
- **GitHub color scheme** - Uses GitHub's signature `#f6f8fa` background and `#24292f` text colors
- **Card-based layout** - Clean, modern cards with subtle borders (`#d0d7de`)
- **Typography matching** - Uses GitHub's font stack: `-apple-system, BlinkMacSystemFont, 'Segoe UI'`
- **Responsive grid** - Adapts to different screen sizes like GitHub

### Code Diff Views
- **Line-by-line diffs** - Shows exactly what mutations were applied
- **GitHub-style diff colors**:
  - 🔴 **Removed lines** - Red background (`#ffebe9`) for original code
  - 🟢 **Added lines** - Green background (`#e6ffed`) for mutated code
  - ⚪ **Context lines** - White background for unchanged code
- **Line numbers** - Easy navigation with proper line numbering
- **Monospace font** - Code displayed in `SFMono-Regular, Consolas` font family

### Status Indicators
- **Badge system** like GitHub:
  - ✅ **Detected mutations** - Green badges (`#d4f4dd` background, `#1a7f37` text)
  - ❌ **Missed mutations** - Red badges (`#ffeef0` background, `#cf222e` text)

## 📊 Report Sections

### Header Section
- **Project title** with mutation emoji
- **File being analyzed** in code formatting
- **Summary statistics** in a responsive grid:
  - Total Mutations
  - Detected
  - Missed  
  - Detection Rate
  - Grade

### Recommendations Section
- **GitHub warning style** - Yellow background (`#fff8c5`) with brown text (`#9a6700`)
- **Smart suggestions** for improving test coverage

### Mutation Details Section
- **Individual mutation cards** for each mutation applied
- **Expandable diff views** showing the exact code changes
- **Execution metadata** - timing and file information

## 🔍 Code Change Visualization

Each mutation now shows:
```diff
- Original code line (red background)
+ Mutated code line (green background)
  Context lines (white background)
```

### Example Diff Display:
```
15    return a + b;     // Context
16  - return a + b;     // Original (removed)
16  + return a - b;     // Mutation (added)  
17    }                 // Context
```

## � Benefits of GitHub-Style Interface

### For Developers
- **Familiar interface** - Looks and feels like GitHub PRs
- **Easy code review** - Quickly spot what mutations were applied
- **Visual debugging** - See exactly which changes broke tests
- **Professional appearance** - Share with team members and stakeholders

### For Test Quality Assessment
- **Clear visual feedback** on test effectiveness
- **Line-by-line analysis** of mutation detection
- **Context preservation** - See mutations in proper code context
- **Pattern recognition** - Identify common test gaps

## Usage
Same simple command, now with GitHub-style output:

```bash
dart run bin/smart_mutation.dart --config your_config.json
```

Output:
```
📊 GitHub-style HTML report saved to: your_output_dir/mutation_test_report.html
```

## Technical Implementation
- **CSS Grid Layout** - Responsive design using modern CSS
- **GitHub Color Variables** - Exact color matching with GitHub's design system
- **Semantic HTML** - Proper structure for accessibility
- **Lightweight** - No external dependencies, pure HTML/CSS

Your mutation testing reports now look as professional as a GitHub pull request! 🌟

## Example Generated Report
The tool automatically generates:
- `mutation_test_report.html` - **Primary interactive report** (new!)
- `mutation_test_report.json` - Backup data format (when verbose mode enabled)

## Usage
The HTML report is now generated **by default** for all mutation testing runs:

```bash
dart run bin/smart_mutation.dart --config your_config.json
```

Output:
```
🌐 Interactive HTML report saved to: your_output_dir/mutation_test_report.html
📄 JSON report also saved to: your_output_dir/mutation_test_report.json (if verbose)
```

## Benefits
- **Better readability** - Visual charts instead of raw JSON
- **Professional presentation** - Share reports with stakeholders
- **Interactive exploration** - Click and explore data easily
- **Mobile accessible** - View reports on any device
- **Print-friendly** - Generate PDFs for documentation

## Backward Compatibility
- JSON reports still available in verbose mode
- All existing functionality preserved
- Same command-line interface

Your mutation testing reports are now as beautiful as they are informative! 🚀
