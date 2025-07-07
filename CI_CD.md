# CI/CD Pipeline

This document outlines our continuous integration and deployment setup for DogTV+.

## Continuous Integration (CI)

We use GitHub Actions to automate build, test, lint, and documentation steps:

- Triggers on push to `main` and `feature/**` branches, and on pull requests.
- Builds the tvOS app in Release configuration with `xcodebuild`.
- Runs unit, integration, and UI tests on an Apple TV Simulator.
- Performs code quality checks with SwiftLint.
- Generates DocC documentation and uploads it as an artifact.

Workflow file: `.github/workflows/ci.yml`

## Continuous Deployment (CD)

We use Fastlane for deployment workflows:

- `fastlane beta`: Increments build number, builds the app, and uploads to TestFlight.
- `fastlane release`: Captures screenshots, increments build number, builds the app, and submits to the App Store.

Configuration file: `Fastfile` 