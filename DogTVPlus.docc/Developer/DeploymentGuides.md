# Deployment Guides

This guide covers deploying DogTV+ to various environments.

## Development Environment

1. Clone the repo and open in Xcode.  
2. Run on local Apple TV simulator for rapid testing.

## Staging Environment

1. Create a `staging` branch based on `main`.  
2. Update app configuration: enable staging API endpoints in `Config.plist`.
3. Archive build in Xcode: `Product > Archive`.  
4. Upload to TestFlight internal testing.

## Production Environment

1. Merge fully tested code to `main`.  
2. Bump version and build number in project settings.  
3. Tag the release: `git tag -a vX.Y.Z -m "Release X.Y.Z"`.
4. Archive and validate in Xcode.  
5. Submit to App Store Connect.
6. Monitor review status and address any feedback.

## Rollback Procedure

- If critical issues arise, revert to the previous tag:  
  ```bash
  git checkout vX.Y.Z
  ```
- Rebuild and re-submit.

## Configuration Management

- Use environment-specific `Config.plist` files.  
- Securely store API keys and secrets using Apple Keychain or CI secrets. 