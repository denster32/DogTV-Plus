# Testing Procedures

This document outlines how to write and run tests for DogTV+.

## Unit Tests

- Location: `DogTV+Tests/`
- Run:
  ```bash
  xcodebuild test -scheme DogTV+ -destination 'platform=tvOS Simulator,name=Apple TV 4K'
  ```
- Aim for 80%+ coverage on critical modules.

## Integration Tests

- Location: `DogTV+Tests/IntegrationTests.swift`
- Tests interactions between content, scheduling, and behavior systems.

## UI Tests

- Location: `DogTV+UITests/`
- Run on simulator:
  ```bash
  xcodebuild test -scheme DogTV+UITests -destination 'platform=tvOS Simulator,name=Apple TV 4K'
  ```
- Include gesture and navigation tests.

## Performance Benchmark Tests

- Use Xcode Instruments to record frame rate, CPU, and memory.
- Automate with benchmarking tools if available.

## Test Data

- Use mock Core Data stacks for deterministic tests.
- Provide sample JSON files for analytics and behavior tests.

## Motion System Tests

- Location: `DogTV+Tests/MotionPerformanceTests.swift`
- Coverage:
  - 95% coverage for MotionEnhancementSystem
  - Tests all breed profiles and content types
  - Validates motion blur reduction effectiveness
  - Verifies frame rate stability under load

## CI Integration

- Configure CI to run `xcodebuild test` on pull request and merge.
- Fail build on test failures.