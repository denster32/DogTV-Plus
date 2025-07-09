# Xcode Development Settings for DogTV+

This document outlines the recommended Xcode settings for optimal development experience with the DogTV+ project.

## Code Formatting Settings

### Text Editing
- **Editor > Code Folding:** Show code folding ribbon ✓
- **Editor > Code Completion:** All suggestions ✓
- **Editor > Syntax Coloring:** All syntax highlighting ✓

### Indentation
- **Indentation > Tab width:** 4 spaces
- **Indentation > Indent width:** 4 spaces  
- **Indentation > Tab Key:** Inserts 4 spaces
- **Indentation > Wrap lines:** ✓
- **Indentation > Automatically trim trailing whitespace:** ✓
- **Indentation > Including whitespace-only lines:** ✓

### Source Control
- **Source Control > Git:** Show source control changes ✓
- **Source Control > Comparison View:** Side by side
- **Source Control > Automatically refresh local status:** ✓

## Build Settings

### Swift Compiler
- **Swift Language Version:** Swift 5.9
- **Strict Concurrency Checking:** Complete
- **Enable Upcoming Features:**
  - StrictConcurrency ✓
  - GlobalConcurrency ✓

### Code Generation
- **Optimization Level (Debug):** No Optimization [-Onone]
- **Optimization Level (Release):** Optimize for Speed [-O]
- **Strip Debug Symbols (Release):** ✓
- **Strip Swift Symbols (Release):** ✓

### Warning Policies
- **Treat Warnings as Errors:** ✓ (Recommended for CI/CD)
- **Missing Return Types:** Error
- **Unused Variables:** Warning
- **Unused Functions:** Warning

## Debugging

### Debug Information Format
- **Debug Information Format (Debug):** DWARF with dSYM File
- **Debug Information Format (Release):** DWARF with dSYM File

### Scheme Settings
- **Build Configuration (Run):** Debug
- **Build Configuration (Test):** Debug  
- **Build Configuration (Profile):** Release
- **Build Configuration (Analyze):** Debug
- **Build Configuration (Archive):** Release

## Development Team Settings

### Code Signing
- **Development Team:** [Your Apple Developer Team]
- **Code Signing Identity (Debug):** Apple Development
- **Code Signing Identity (Release):** Apple Distribution
- **Provisioning Profile:** Automatic

### Deployment
- **iOS Deployment Target:** 17.0
- **tvOS Deployment Target:** 17.0
- **macOS Deployment Target:** 13.0

## Simulator Configuration

### Recommended Simulators
- **Apple TV 4K (3rd generation)** - Primary target
- **Apple TV 4K (2nd generation)** - Compatibility testing
- **iPad Pro (12.9-inch)** - Development testing
- **iPhone 15 Pro** - Development testing

### Simulator Settings
- **Device > Keyboard > Connect Hardware Keyboard:** ✓
- **Device > Shake Gesture:** ✓
- **Window > Physical Size:** 50% (for Apple TV)

## Performance Analysis

### Instruments Integration
- **Product > Profile:** Always use Release configuration
- **Recommended Templates:**
  - Time Profiler (performance analysis)
  - Allocations (memory analysis)  
  - GPU Driver (Metal performance)
  - Energy Log (power consumption)

### Static Analysis
- **Product > Analyze:** Run regularly
- **Enable Static Analyzer Warnings:** ✓
- **Deep Static Analysis:** ✓

## Documentation

### Documentation Comments
- **Editor > Syntax Coloring > Documentation Comments:** ✓
- **Quick Help:** Show documentation for symbols ✓
- **Documentation Build:** Include in build process ✓

### Code Coverage
- **Scheme > Test > Code Coverage:** ✓
- **Scheme > Test > Gather coverage for all targets:** ✓

## Accessibility

### Accessibility Inspector
- **Window > Accessibility Inspector:** Use for testing
- **Accessibility Audit:** Run regularly on UI components

### Voice Control Testing
- **System Preferences > Accessibility > Voice Control:** Enable for testing
- **Test common voice commands with tvOS interface**

## Setup Instructions

1. **Open Xcode Project:**
   ```bash
   cd NewDogTVPlus
   xed .
   ```

2. **Configure Build Schemes:**
   - Product > Scheme > Edit Scheme
   - Apply the build configurations listed above

3. **Set Up Development Team:**
   - Project Navigator > Select project
   - Signing & Capabilities > Team > [Select your team]

4. **Install Development Tools:**
   ```bash
   # Install SwiftLint if not already installed
   brew install swiftlint
   
   # Set up Git hooks
   ./setup-git-hooks.sh
   ```

5. **Verify Setup:**
   ```bash
   # Build all targets
   swift build
   
   # Run tests
   swift test
   
   # Run SwiftLint
   swiftlint
   ```

## Continuous Integration Setup

For CI/CD environments, use these additional settings:

```bash
# Xcode Cloud / GitHub Actions environment variables
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export SWIFT_VERSION="5.9"
export ENABLE_STRICT_CONCURRENCY="YES"
export TREAT_WARNINGS_AS_ERRORS="YES"
```

## Troubleshooting

### Common Issues

**Build Errors:**
- Clean build folder: Product > Clean Build Folder
- Reset package cache: File > Packages > Reset Package Caches
- Restart Xcode if issues persist

**SwiftLint Issues:**
- Update to latest version: `brew upgrade swiftlint`
- Check configuration: `swiftlint config`
- Fix auto-fixable issues: `swiftlint --fix`

**Simulator Issues:**
- Reset simulator: Device > Erase All Content and Settings
- Update simulator list: Window > Devices and Simulators > Download

This configuration ensures a consistent, professional development environment optimized for the DogTV+ project's requirements.
