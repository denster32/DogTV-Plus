# App Store Preparation

## 13.1.1 Create Compelling App Store Assets

### 13.1.1.1 App Icon
- Provide a 1024×1024 App Store icon (PNG).
- Include all required App Icon sizes in `Assets.xcassets` under `AppIcon.appiconset` (e.g., 20×20, 29×29, 40×40, 60×60, 76×76, 83.5×83.5, 1024×1024).

### 13.1.1.2 Screenshots
- Capture high-resolution screenshots for Apple TV 4K and HD (1920×1080 and 3840×2160).
- Showcase key features: human vs. dog vision mode, content scheduling, behavior analysis, privacy settings.
- Save in PNG format named chronologically (e.g., `1_Home.png`, `2_VisionMode.png`).

### 13.1.1.3 App Description
- Write a concise, scientifically accurate summary of DogTV+ features and benefits.
- Emphasize canine vision simulation, behavior-adaptive content, privacy controls, and scientific backing.
- Target ~300 characters for the short description and up to 4000 for the full description.

### 13.1.1.4 Keywords
- Optimize with relevant terms: `dog tv`, `canine vision`, `pet relaxation`, `animal behavior`, `tvos app`, `dog entertainment`, `pet wellness`, `veterinary validated`.

### 13.1.1.5 Preview Video
- Create a 15–30 second App Preview video demonstrating core features.
- Include captions and callouts for vision mode, scheduling, and analytics dashboards.
- Export in MOV (H.264) format at 1920×1080 resolution.

## 13.1.2 Prepare for Seamless App Store Submission

### 13.1.2.1 Finalize App Bundle
- Verify all entitlements (App Sandbox, In-App Purchase, Network Access) are set in Xcode target.
- Confirm correct bundle identifier and version/build numbers.

### 13.1.2.2 App Store Connect Metadata
- Ensure app name, subtitle, and category are accurate in App Store Connect.
- Fill in support URL, marketing URL, and privacy policy URL.

### 13.1.2.3 In-App Purchase Setup
- Implement and test any in-app purchases with Sandbox tester accounts.
- Verify purchase flows, restore purchases, and error handling.

### 13.1.2.4 Pre-Submission Review
- Run Xcode Archive validation and address any warnings/errors.
- Use `xcrun altool` to validate the IPA before uploading.

### 13.1.2.5 Submission Checklist
- Complete a step-by-step checklist: screenshots uploaded, description entered, keywords set, builds uploaded, test flight invites sent.
- Document any review notes or feedback received during beta testing. 