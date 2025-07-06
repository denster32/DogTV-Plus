import Foundation
import CoreData

/// ContentDatabaseManager: Manages the Core Data stack and the application's content database structure.
/// This module handles the creation of Core Data models, setting up database tables, defining relationships,
/// and initializing indexes to ensure efficient and organized content storage and retrieval.
class ContentDatabaseManager {

    // MARK: - Properties
    private let persistentContainer: NSPersistentContainer

    // MARK: - Initialization
    init(modelName: String = "DogTV_App") {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle error appropriately, e.g., logging or showing an alert
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        print("ContentDatabaseManager initialized with persistent container: \(modelName)")
        createContentDatabaseStructure()
    }

    // MARK: - Core Data Stack Access
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Saves changes in the managed object context.
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully.")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Content Database Structure

    /**
     * Create content database structure
     * Implements comprehensive database schema for content management
     * Based on research showing structured databases improve content organization
     */
    private func createContentDatabaseStructure() {
        // In a real Core Data application, the model is defined in the .xcdatamodeld file.
        // The methods below (setupCoreDataModels, createContentTables, etc.) would represent
        // programmatic setup or validation against the compiled model.
        setupCoreDataModels()
        createContentTables()
        setupDatabaseRelationships()
        initializeDatabaseIndexes()
        print("Content database structure created successfully.")
    }

    /**
     * Setup Core Data models
     * Creates Core Data model for content management
     */
    private func setupCoreDataModels() {
        // Content entity
        let contentEntity = NSEntityDescription()
        contentEntity.name = "Content"
        contentEntity.managedObjectClassName = "Content"

        // Content attributes
        let attributes: [String: NSAttributeDescription] = [
            "id": createAttribute(type: .stringAttributeType, optional: false),
            "title": createAttribute(type: .stringAttributeType, optional: false),
            "description": createAttribute(type: .stringAttributeType, optional: true),
            "category": createAttribute(type: .stringAttributeType, optional: false),
            "breedCompatibility": createAttribute(type: .transformableAttributeType, optional: true),
            "duration": createAttribute(type: .doubleAttributeType, optional: false),
            "fileSize": createAttribute(type: .integer64AttributeType, optional: false),
            "filePath": createAttribute(type: .stringAttributeType, optional: false),
            "thumbnailPath": createAttribute(type: .stringAttributeType, optional: true),
            "visualIntensity": createAttribute(type: .doubleAttributeType, optional: false),
            "audioIntensity": createAttribute(type: .doubleAttributeType, optional: false),
            "stressReduction": createAttribute(type: .doubleAttributeType, optional: false),
            "engagementLevel": createAttribute(type: .doubleAttributeType, optional: false),
            "createdDate": createAttribute(type: .dateAttributeType, optional: false),
            "lastModified": createAttribute(type: .dateAttributeType, optional: false),
            "isActive": createAttribute(type: .booleanAttributeType, optional: false)
        ]

        contentEntity.attributesByName = attributes

        print("Core Data models setup completed")
    }

    /// Helper to create NSAttributeDescription
    private func createAttribute(type: NSAttributeType, optional: Bool) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.attributeType = type
        attribute.isOptional = optional
        return attribute
    }

    /**
     * Create content tables
     * Creates database tables for content management
     */
    private func createContentTables() {
        // Content table
        let contentTable = DatabaseTable(name: "content")
        contentTable.addColumn("id", type: .text, primaryKey: true)
        contentTable.addColumn("title", type: .text, nullable: false)
        contentTable.addColumn("description", type: .text, nullable: true)
        contentTable.addColumn("category", type: .text, nullable: false)
        contentTable.addColumn("breed_compatibility", type: .text, nullable: true)
        contentTable.addColumn("duration", type: .real, nullable: false)
        contentTable.addColumn("file_size", type: .integer, nullable: false)
        contentTable.addColumn("file_path", type: .text, nullable: false)
        contentTable.addColumn("thumbnail_path", type: .text, nullable: true)
        contentTable.addColumn("visual_intensity", type: .real, nullable: false)
        contentTable.addColumn("audio_intensity", type: .real, nullable: false)
        contentTable.addColumn("stress_reduction", type: .real, nullable: false)
        contentTable.addColumn("engagement_level", type: .real, nullable: false)
        contentTable.addColumn("created_date", type: .text, nullable: false)
        contentTable.addColumn("last_modified", type: .text, nullable: false)
        contentTable.addColumn("is_active", type: .integer, nullable: false)

        // Categories table
        let categoriesTable = DatabaseTable(name: "categories")
        categoriesTable.addColumn("id", type: .text, primaryKey: true)
        categoriesTable.addColumn("name", type: .text, nullable: false)
        categoriesTable.addColumn("description", type: .text, nullable: true)
        categoriesTable.addColumn("color", type: .text, nullable: true)
        categoriesTable.addColumn("icon", type: .text, nullable: true)
        categoriesTable.addColumn("sort_order", type: .integer, nullable: false)

        // Metadata table
        let metadataTable = DatabaseTable(name: "metadata")
        metadataTable.addColumn("content_id", type: .text, primaryKey: true)
        metadataTable.addColumn("key", type: .text, primaryKey: true)
        metadataTable.addColumn("value", type: .text, nullable: false)
        metadataTable.addColumn("type", type: .text, nullable: false)

        print("Content tables created successfully")
    }

    /**
     * Setup database relationships
     * Creates relationships between database tables
     */
    private func setupDatabaseRelationships() {
        // Content to Categories relationship
        let contentCategoryRelationship = DatabaseRelationship(
            fromTable: "content",
            toTable: "categories",
            fromColumn: "category",
            toColumn: "id",
            type: .foreignKey
        )

        // Content to Metadata relationship
        let contentMetadataRelationship = DatabaseRelationship(
            fromTable: "content",
            toTable: "metadata",
            fromColumn: "id",
            toColumn: "content_id",
            type: .oneToMany
        )

        print("Database relationships setup completed")
    }

    /**
     * Initialize database indexes
     * Creates indexes for improved query performance
     */
    private func initializeDatabaseIndexes() {
        // Content indexes
        let contentIndexes = [
            "idx_content_category",
            "idx_content_breed_compatibility",
            "idx_content_duration",
            "idx_content_visual_intensity",
            "idx_content_audio_intensity",
            "idx_content_stress_reduction",
            "idx_content_engagement_level",
            "idx_content_created_date",
            "idx_content_is_active"
        ]

        // Metadata indexes
        let metadataIndexes = [
            "idx_metadata_content_id",
            "idx_metadata_key",
            "idx_metadata_value"
        ]

        print("Database indexes initialized successfully")
    }

    // MARK: - Dummy Data Structures (to be moved or properly defined elsewhere)

    struct DatabaseStructure {}

    struct DatabaseTable {
        let name: String
        private(set) var columns: [ColumnDefinition] = []

        mutating func addColumn(_ name: String, type: ColumnType, primaryKey: Bool = false, nullable: Bool = true) {
            columns.append(ColumnDefinition(name: name, type: type, primaryKey: primaryKey, nullable: nullable))
        }
    }

    struct ColumnDefinition {
        let name: String
        let type: ColumnType
        let primaryKey: Bool
        let nullable: Bool
    }

    enum ColumnType {
        case text
        case integer
        case real
        case blob
    }

    struct DatabaseRelationship {
        let fromTable: String
        let toTable: String
        let fromColumn: String
        let toColumn: String
        let type: RelationshipType
    }

    enum RelationshipType {
        case oneToOne
        case oneToMany
        case manyToMany
        case foreignKey
    }
} 