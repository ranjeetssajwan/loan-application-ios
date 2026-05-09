
//
//  CoreDataStack.swift
//  LoanApp
//
 
import CoreData

final class CoreDataStack {

    // MARK: - Singleton

    static let shared = CoreDataStack()
    private init() {}

    // MARK: - Container

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "LoanApp",                      // SQLite file name (no .xcdatamodeld needed)
            managedObjectModel: makeManagedObjectModel()
        )
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreDataStack – persistent store failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save
 
    @discardableResult
    func saveContext() -> Bool {
        let ctx = viewContext
        guard ctx.hasChanges else { return true }
        do {
            try ctx.save()
            return true
        } catch {
            print("CoreDataStack saveContext error: \(error)")
            ctx.rollback()
            return false
        }
    }

    // MARK: - Programmatic Model
 
    private func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        
        let appEntity      = NSEntityDescription()
        let personalEntity = NSEntityDescription()
        let finEntity      = NSEntityDescription()

        appEntity.name                      = "LoanApplicationEntity"
        appEntity.managedObjectClassName    = NSStringFromClass(NSManagedObject.self)

        personalEntity.name                  = "PersonalInfoEntity"
        personalEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        finEntity.name                      = "FinancialInfoEntity"
        finEntity.managedObjectClassName    = NSStringFromClass(NSManagedObject.self)

        
        func stringAttr(_ name: String) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .stringAttributeType
            a.isOptional    = false
            a.defaultValue  = ""
            return a
        }

        func doubleAttr(_ name: String) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name          = name
            a.attributeType = .doubleAttributeType
            a.isOptional    = false
            a.defaultValue  = 0.0
            return a
        }

        
        let idAttr = NSAttributeDescription()
        idAttr.name          = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional    = false

        let submittedAtAttr = NSAttributeDescription()
        submittedAtAttr.name          = "submittedAt"
        submittedAtAttr.attributeType = .dateAttributeType
        submittedAtAttr.isOptional    = false

        appEntity.properties = [idAttr, submittedAtAttr]

        
        personalEntity.properties = [
            stringAttr("fullName"),
            stringAttr("email"),
            stringAttr("phoneNumber"),
            stringAttr("gender"),
            stringAttr("address")
        ]

        
        finEntity.properties = [
            doubleAttr("annualIncome"),
            doubleAttr("loanAmount"),
            stringAttr("irdNumber")
        ]

  
        let appToPersonal              = NSRelationshipDescription()
        appToPersonal.name             = "personal"
        appToPersonal.destinationEntity = personalEntity
        appToPersonal.maxCount         = 1
        appToPersonal.minCount         = 1
        appToPersonal.deleteRule       = .cascadeDeleteRule
        appToPersonal.isOptional       = false

        let personalToApp              = NSRelationshipDescription()
        personalToApp.name             = "application"
        personalToApp.destinationEntity = appEntity
        personalToApp.maxCount         = 1
        personalToApp.deleteRule       = .nullifyDeleteRule
        personalToApp.isOptional       = true

        appToPersonal.inverseRelationship = personalToApp
        personalToApp.inverseRelationship = appToPersonal

        
        let appToFin              = NSRelationshipDescription()
        appToFin.name             = "financial"
        appToFin.destinationEntity = finEntity
        appToFin.maxCount         = 1
        appToFin.minCount         = 1
        appToFin.deleteRule       = .cascadeDeleteRule
        appToFin.isOptional       = false

        let finToApp              = NSRelationshipDescription()
        finToApp.name             = "application"
        finToApp.destinationEntity = appEntity
        finToApp.maxCount         = 1
        finToApp.deleteRule       = .nullifyDeleteRule
        finToApp.isOptional       = true

        appToFin.inverseRelationship = finToApp
        finToApp.inverseRelationship = appToFin

        
        appEntity.properties      += [appToPersonal, appToFin]
        personalEntity.properties += [personalToApp]
        finEntity.properties      += [finToApp]

        model.entities = [appEntity, personalEntity, finEntity]
        return model
    }
}
