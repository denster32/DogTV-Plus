# Contributing to DogTV+

Thank you for your interest in contributing to DogTV+! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/DogTV+.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `swift test`
6. Commit your changes: `git commit -m "Add your feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Create a Pull Request

## Development Environment

### Requirements
- Xcode 15.0+
- Swift 5.9+
- macOS 14.0+ (for Metal shader development)

### Setup
```bash
git clone https://github.com/yourusername/DogTV+.git
cd DogTV+
swift build
swift test
```

## Code Style

### Swift Style Guide
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for code formatting
- Prefer explicit types in public APIs
- Use meaningful variable and function names

### Example
```swift
// Good
public func generateScene(_ scene: CanineScene) async throws -> MTLTexture

// Avoid
public func gen(_ s: Scene) -> Texture?
```

### File Organization
```
Sources/
├── DogTVCore/          # Core business logic only
├── DogTVUI/            # SwiftUI views and view models
├── DogTVVision/        # Metal shaders and rendering
├── DogTVAudio/         # Audio processing
├── DogTVBehavior/      # Behavior analysis
├── DogTVData/          # Data management
├── DogTVSecurity/      # Security and privacy
└── DogTVAnalytics/     # Analytics and monitoring
```

## Testing

### Test Requirements
- All new code must include unit tests
- Maintain 90%+ code coverage
- Integration tests for major features
- Performance tests for critical paths

### Running Tests
```bash
# All tests
swift test

# Specific module
swift test --filter DogTVCoreTests

# With coverage
swift test --enable-code-coverage
```

## Metal Shader Development

### Shader Guidelines
- Optimize for Apple TV hardware
- Target 60 FPS performance
- Use canine-optimized color constants
- Include performance annotations

### Testing Shaders
```swift
let validator = ShaderValidator()
try validator.validateShader("your_shader_name")
```

## Documentation

### API Documentation
- Use Swift DocC format
- Include code examples
- Document all public APIs
- Explain complex algorithms

### Example
```swift
/// Generates procedural content optimized for canine vision
/// - Parameter scene: The scene type to generate
/// - Returns: A Metal texture containing the rendered scene
/// - Throws: `ContentError` if generation fails
public func generateScene(_ scene: CanineScene) async throws -> MTLTexture {
    // Implementation
}
```

## Pull Request Process

### Before Submitting
- [ ] Code builds without warnings
- [ ] All tests pass
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] Performance impact is considered

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Performance tested

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## Feature Guidelines

### New Features
1. Create GitHub issue first
2. Discuss approach with maintainers
3. Implement with tests
4. Update documentation
5. Submit pull request

### Bug Fixes
1. Create reproducible test case
2. Fix the issue
3. Verify fix with tests
4. Submit pull request

## Performance Considerations

### Critical Metrics
- Frame generation: < 16ms (60 FPS)
- Memory usage: < 200MB peak
- Launch time: < 2 seconds
- Shader compilation: < 100ms

### Optimization Guidelines
- Profile before optimizing
- Use Instruments for analysis
- Prefer Metal over CPU for graphics
- Cache expensive computations

## Scientific Accuracy

### Research Requirements
- Cite peer-reviewed sources
- Validate against known canine research
- Test with actual canine behavior data
- Maintain scientific credibility

### Color Vision Guidelines
- Use dichromatic color space
- Emphasize blue-yellow spectrum
- Avoid red-green distinctions
- Test with colorblind simulation

## Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain professional standards

### Communication
- Use clear, concise language
- Provide context for decisions
- Ask questions when unsure
- Share knowledge with others

## Release Process

### Versioning
- Follow [Semantic Versioning](https://semver.org/)
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Performance validated
- [ ] Security reviewed
- [ ] App Store compliance verified

## Getting Help

### Resources
- [Documentation](docs/)
- [API Reference](docs/API.md)
- [Testing Guide](docs/TESTING.md)
- [Metal Shaders](docs/SHADERS.md)

### Contact
- Create GitHub issue for bugs
- Use discussions for questions
- Follow project announcements

Thank you for contributing to DogTV+!