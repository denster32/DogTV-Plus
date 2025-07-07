# API Reference: PrivacyComplianceManager

/// PrivacyComplianceManager: Manages regulatory compliance (GDPR, CCPA, etc.) and user data rights.

## Initialization
```swift
let manager = PrivacyComplianceManager(secureDataStorage: storageSystem)
```

## Consent Management

```swift
func requestConsent(for dataTypes: [PrivacyComplianceManager.DataType]) -> ConsentRecord
```
Presents consent prompt and returns a pending `ConsentRecord`.

```swift
func updateConsent(identifier: UUID, status: ConsentStatus) throws
```
Updates an existing consent record to `granted`, `denied`, or `revoked`.

```swift
func isDataProcessingAllowed(for dataType: DataType) -> Bool
```
Checks if processing of the specified type is permitted.

## Data Rights

```swift
func generatePrivacyPolicy() -> String
```
Generates a formatted privacy policy text.

```swift
func exportUserData() throws -> [String: Any]
```
Exports encrypted user data for portability.

## Supporting Types

```swift
enum PrivacyRegulation: CaseIterable { case gdpr, ccpa, pipeda, lgpd }
enum ConsentStatus { case granted, denied, pending, revoked }
enum DataType: CaseIterable { case personalProfile, behavioralData, medicalInformation, locationData, deviceInformation }
struct ConsentRecord { let identifier: UUID; let dataTypes: [DataType]; let status: ConsentStatus; let timestamp: Date; let version: String }
struct PrivacyConfiguration { let regulations: [PrivacyRegulation]; let dataRetentionPeriod: TimeInterval; let isDataSharingAllowed: Bool; let isThirdPartyTrackingEnabled: Bool }
``` 