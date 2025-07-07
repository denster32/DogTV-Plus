# Troubleshooting Guide

This guide helps resolve common technical issues when working with DogTV+.

## Build and Runtime Issues

- **Core Data Initialization Fails**  
  Ensure the `.xcdatamodeld` file is included in the target.  
  Verify `NSPersistentContainer` name matches the model file name.

- **Consent Toggles Not Persisting**  
  Consent settings use `UserDefaults`. Verify bundle identifier allows `UserDefaults` writes.

- **DocC Documentation Not Generating**  
  Run `xcodebuild docbuild -scheme DogTV+ -destination generic/platform=macOS`.

- **Privacy Policy Not Loading**  
  Confirm `PrivacyPolicy.md` is added to the app bundle and target membership.

## Analytics and Logging

- **Analytics Events Not Sending**  
  Check `ConsentManager.shared.analyticsEnabled` is `true`.  
  Verify network reachability for batching requests.

## UI and Navigation

- **NavigationLink Destination Not Showing**  
  Ensure destination view is imported and declared as `View`.

## Contact

If problems persist, contact the development team at devops@dogtvplus.com. 