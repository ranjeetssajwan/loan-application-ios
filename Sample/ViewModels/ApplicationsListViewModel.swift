
//
//  ApplicationsListViewModel.swift
//  LoanApp
//
//  ViewModel for the saved-applications list screen.
//

import Foundation

final class ApplicationsListViewModel {

 
    private(set) var applications: [LoanApplication] = []

  

    func loadApplications() {
        applications = LoanPersistenceService.shared.fetchAll()
    }

   

    func deleteApplication(at index: Int) {
        guard index < applications.count else { return }
        let id = applications[index].id
        LoanPersistenceService.shared.delete(id: id)
        applications.remove(at: index)
    }

 

    func application(at index: Int) -> LoanApplication {
        applications[index]
    }

  

    struct CellData {
        let applicantName:  String
        let loanAmount:     String
        let annualIncome:   String
        let submittedDate:  String
        let isEligible:     Bool
    }

    func cellData(at index: Int) -> CellData {
        let app = applications[index]
        return CellData(
            applicantName: app.personal.fullName,
            loanAmount:    formatCurrency(app.financial.loanAmount),
            annualIncome:  formatCurrency(app.financial.annualIncome),
            submittedDate: formatDate(app.submittedAt),
            isEligible:    app.isLoanAmountValid
        )
    }

    var isEmpty: Bool { applications.isEmpty }

 

    private func formatCurrency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }

    private func formatDate(_ date: Date) -> String {
        let f       = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
