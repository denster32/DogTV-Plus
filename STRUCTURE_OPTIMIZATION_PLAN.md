# Structure Optimization Plan

This plan outlines the steps to optimize the project structure.

## Completed Actions:

* **Project Audit:**  Executed commands to analyze the project structure, including counting Swift files, listing file sizes, identifying large files, listing documentation files, and listing project files.
* **Duplicate File Identification:** Identified and documented duplicate files in `FILES_TO_DELETE.md` and `FILES_TO_CONSOLIDATE.md`.  The duplicate files are primarily from the `DogTVUI` module being copied to create the `DogTVPlusUI` module.  The plan is to delete the `DogTVUI` files and consolidate the logic from the `DogTVPlusUI` files into the corresponding `DogTV` files.

## Next Steps:

### Files for Consolidation/Splitting:
The following Swift files are over 500 lines and should be reviewed for potential splitting or refactoring, especially where duplicates exist across `DogTVCore` and `DogTVPlusCore` modules:

*   `Sources/DogTVCore/Services/EngagementRetentionEngine.swift` (911 lines)
*   `Tests/DogTVPlusCoreTests/ComprehensiveTestSuite.swift` (719 lines)
*   `Tests/DogTVCoreTests/ComprehensiveTestSuite.swift` (719 lines)
*   `Sources/DogTVCore/Services/HealthWellnessPlatform.swift` (716 lines)
*   `Sources/DogTVPlusCore/Services/InternationalizationEngine.swift` (702 lines)
*   `Sources/DogTVCore/Services/InternationalizationEngine.swift` (702 lines)
*   `Sources/DogTVCore/DogTVCore.swift` (681 lines)
*   `Sources/DogTVPlusCore/Services/GlobalPrivacyComplianceEngine.swift` (663 lines)
*   `Sources/DogTVCore/Services/GlobalPrivacyComplianceEngine.swift` (663 lines)
*   `Sources/DogTVCore/Services/AdvancedAIPlatform.swift` (652 lines)
*   `Sources/DogTVPlusCore/Services/AppleEcosystemIntegration.swift` (650 lines)
*   `Sources/DogTVCore/Services/AppleEcosystemIntegration.swift` (650 lines)
*   `Sources/DogTVPlusCore/Services/BusinessIntelligenceService.swift` (534 lines)
*   `Sources/DogTVCore/Services/BusinessIntelligenceService.swift` (534 lines)
*   `Sources/DogTVPlusCore/Services/EnterpriseSecurityFramework.swift` (531 lines)
*   `Sources/DogTVCore/Services/EnterpriseSecurityFramework.swift` (531 lines)
*   `Sources/DogTVPlusCore/Services/AdvancedUXFramework.swift` (1020 lines)
*   `Sources/DogTVCore/Services/AdvancedUXFramework.swift` (1020 lines)

Further analysis is also needed to identify unused assets and resources, temporary files and build artifacts, empty directories, and outdated documentation. This will require more specific criteria and potentially manual review.
