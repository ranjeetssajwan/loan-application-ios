
//
//  LoanPersistenceService.swift
//  LoanApp
 


import Foundation
import CoreData

final class LoanPersistenceService {

    // MARK: - Singleton

    static let shared = LoanPersistenceService()
    private init() {}

    // MARK: - Context

    private var context: NSManagedObjectContext {
        CoreDataStack.shared.viewContext
    }

    // MARK: - Public API

    /// Returns all saved applications, newest first.
    func fetchAll() -> [LoanApplication] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LoanApplicationEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "submittedAt", ascending: false)]

        do {
            let results = try context.fetch(request)
            return results.compactMap { map(to: $0) }
        } catch {
            print("LoanPersistenceService fetchAll error: \(error)")
            return []
        }
    }

  
    @discardableResult
    func save(_ application: LoanApplication) -> Bool {
        // ── LoanApplicationEntity ──────────────────────────────────────────
        let appObj = NSManagedObject(
            entity: entityDescription("LoanApplicationEntity"),
            insertInto: context
        )
        appObj.setValue(application.id,          forKey: "id")
        appObj.setValue(application.submittedAt, forKey: "submittedAt")

        // ── PersonalInfoEntity ─────────────────────────────────────────────
        let personalObj = NSManagedObject(
            entity: entityDescription("PersonalInfoEntity"),
            insertInto: context
        )
        personalObj.setValue(application.personal.fullName,    forKey: "fullName")
        personalObj.setValue(application.personal.email,       forKey: "email")
        personalObj.setValue(application.personal.phoneNumber, forKey: "phoneNumber")
        personalObj.setValue(application.personal.gender.rawValue, forKey: "gender")
        personalObj.setValue(application.personal.address,     forKey: "address")
        personalObj.setValue(appObj,                           forKey: "application")

   
        let finObj = NSManagedObject(
            entity: entityDescription("FinancialInfoEntity"),
            insertInto: context
        )
        finObj.setValue(application.financial.annualIncome, forKey: "annualIncome")
        finObj.setValue(application.financial.loanAmount,   forKey: "loanAmount")
        finObj.setValue(application.financial.irdNumber,    forKey: "irdNumber")
        finObj.setValue(appObj,                             forKey: "application")
 
        appObj.setValue(personalObj, forKey: "personal")
        appObj.setValue(finObj,      forKey: "financial")

        return CoreDataStack.shared.saveContext()
    }

 
    @discardableResult
    func update(_ application: LoanApplication) -> Bool {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LoanApplicationEntity")
        request.predicate = NSPredicate(format: "id == %@", application.id as CVarArg)

        do {
            if let appObj = try context.fetch(request).first {
        
                appObj.setValue(application.submittedAt, forKey: "submittedAt")

           
                if let personalObj = appObj.value(forKey: "personal") as? NSManagedObject {
                    personalObj.setValue(application.personal.fullName,    forKey: "fullName")
                    personalObj.setValue(application.personal.email,       forKey: "email")
                    personalObj.setValue(application.personal.phoneNumber, forKey: "phoneNumber")
                    personalObj.setValue(application.personal.gender.rawValue, forKey: "gender")
                    personalObj.setValue(application.personal.address,     forKey: "address")
                }

   
                if let finObj = appObj.value(forKey: "financial") as? NSManagedObject {
                    finObj.setValue(application.financial.annualIncome, forKey: "annualIncome")
                    finObj.setValue(application.financial.loanAmount,   forKey: "loanAmount")
                    finObj.setValue(application.financial.irdNumber,    forKey: "irdNumber")
                }

                return CoreDataStack.shared.saveContext()
            } else {
          
                return save(application)
            }
        } catch {
            print("LoanPersistenceService update error: \(error)")
            return false
        }
    }
 
    @discardableResult
    func delete(id: UUID) -> Bool {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LoanApplicationEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(request)
            results.forEach { context.delete($0) }
            return CoreDataStack.shared.saveContext()
        } catch {
            print("LoanPersistenceService delete error: \(error)")
            return false
        }
    }

    // MARK: - JSON Representation (for API requests)

     
    func toJSON(_ application: LoanApplication) -> [String: Any] {
        [
            "id":          application.id.uuidString,
            "submittedAt": ISO8601DateFormatter().string(from: application.submittedAt),
            "personal": [
                "fullName":    application.personal.fullName,
                "email":       application.personal.email,
                "phoneNumber": application.personal.phoneNumber,
                "gender":      application.personal.gender.rawValue,
                "address":     application.personal.address
            ],
            "financial": [
                "annualIncome": application.financial.annualIncome,
                "loanAmount":   application.financial.loanAmount,
                "irdNumber":    application.financial.irdNumber
            ]
        ]
    }

    // MARK: - Private Mapping Helpers

    
    private func map(to obj: NSManagedObject) -> LoanApplication? {
        guard
            let id          = obj.value(forKey: "id")          as? UUID,
            let submittedAt = obj.value(forKey: "submittedAt") as? Date,
            let personalObj = obj.value(forKey: "personal")    as? NSManagedObject,
            let finObj      = obj.value(forKey: "financial")   as? NSManagedObject
        else { return nil }

        guard
            let fullName    = personalObj.value(forKey: "fullName")    as? String,
            let email       = personalObj.value(forKey: "email")       as? String,
            let phone       = personalObj.value(forKey: "phoneNumber") as? String,
            let genderRaw   = personalObj.value(forKey: "gender")      as? String,
            let gender      = Gender(rawValue: genderRaw),
            let address     = personalObj.value(forKey: "address")     as? String
        else { return nil }

        let annualIncome = finObj.value(forKey: "annualIncome") as? Double ?? 0
        let loanAmount   = finObj.value(forKey: "loanAmount")   as? Double ?? 0
        let irdNumber    = finObj.value(forKey: "irdNumber")    as? String ?? ""

        let personal  = PersonalInfo(
            fullName:    fullName,
            email:       email,
            phoneNumber: phone,
            gender:      gender,
            address:     address
        )
        let financial = FinancialInfo(
            annualIncome: annualIncome,
            loanAmount:   loanAmount,
            irdNumber:    irdNumber
        )

   
        var app         = LoanApplication(personal: personal, financial: financial)
        app.id          = id
        app.submittedAt = submittedAt
        return app
    }

 
    private func entityDescription(_ name: String) -> NSEntityDescription {
        guard let desc = NSEntityDescription.entity(forEntityName: name, in: context) else {
            fatalError("LoanPersistenceService – entity '\(name)' not found in Core Data model.")
        }
        return desc
    }
}
