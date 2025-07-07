# API Reference: ContentLibrarySystem

/// ContentLibrarySystem: Manages the DogTV+ content library including fetching, adding, updating, deleting content items, metadata management, tagging, categorization, and performance optimizations.

## Overview
`ContentLibrarySystem` is an `ObservableObject` responsible for retrieving and managing media content within DogTV+.

## Initialization
```swift
let library = ContentLibrarySystem()
```  
Initializes core services: database, metadata schema, AI tagging, categorization, search, and performance monitoring.

## Published Properties
- `@Published var contentItems: [ContentItem]`
- `@Published var categories: [ContentCategory]`
- `@Published var searchResults: [ContentItem]`
- `@Published var isLoading: Bool`
- `@Published var errorMessage: String?`

## Content Operations
```swift
func fetchContentItems()
func addContentItem(_ item: ContentItem)
func updateContentItem(_ item: ContentItem)
func deleteContentItem(_ item: ContentItem)
```  
Perform CRUD operations on content items. All methods call `fetchContentItems()` to refresh the list.

## AI-Powered Tagging
```swift
func autoTagContent(_ item: ContentItem)
func autoTagAllContent()
```  
Generates tags for items using `AIContentTaggingEngine` and stores them as metadata.

## Categorization
```swift
func getContentItems(byCategory category: ContentCategory) -> [ContentItem]
```  
Retrieves items matching a category defined by `ContentCategorizationSystem`.

## Metadata Management
```swift
func addMetadata(to item: ContentItem, key: String, value: String)
func getMetadata(for item: ContentItem) -> [String: String]
func validateAllContentMetadata()
```  
Handles per-item metadata via `MetadataManager`, including schema validation.

## Search & Filtering
```swift
func searchContent(keyword: String)
func filterContent(criteria: ContentFilterCriteria) -> [ContentItem]
```  
Provides keyword search and filter-based retrieval.

## Performance Optimization
```swift
func optimizeContentLoading()
func cacheContent(_ item: ContentItem)
```  
Delegates to `ContentPerformanceMonitor` for load time optimization and caching.

---

For more details on related modules, see:
- `ContentDatabaseManager` for Core Data setup
- `MetadataManager` for metadata schema & validation
- `AIContentTaggingEngine` for automatic content tagging 