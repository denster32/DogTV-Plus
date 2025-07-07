# Code Style Guidelines

## SwiftLint Integration

This project uses SwiftLint to enforce code style rules.

### Setup
1. Install SwiftLint:
   ```bash
   brew install swiftlint
   ```
2. Add a `.swiftlint.yml` file to the project root.

### Example `.swiftlint.yml`
```yaml
disabled_rules:
  - line_length
opt_in_rules:
  - empty_count
  - missing_docs
  - trailing_whitespace
warning_threshold: 10
line_length:
  warning: 120
  error: 200
```  

## General Guidelines
- Use 4-space indentation.  
- Place braces on the same line.  
- Keep lines under 120 characters.  
- Use Swift API Design Guidelines for naming.
- Write documentation comments for public types and methods.

## Examples
```swift
/// Calculates the dog's relaxed state based on behavior data.
func calculateRelaxationScore(from data: BehaviorData) -> Float {
    // Implementation
}
```

## Code Formatting
- Run SwiftFormat or Xcode's `Editor > Structure > Re-Indent` to format code. 