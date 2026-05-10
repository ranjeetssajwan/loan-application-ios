
//
//  ReviewViewModel.swift
//  LoanApp
//
 

import Foundation

final class ReviewViewModel {

  

    var personal:  PersonalInfo
    var financial: FinancialInfo

    init(personal: PersonalInfo, financial: FinancialInfo) {
        self.personal  = personal
        self.financial = financial
    }

 

    struct ReviewRow {
        let label: String
        let value: String
    }

    var personalRows: [ReviewRow] {
        [
            ReviewRow(label: "Full Name",     value: personal.fullName),
            ReviewRow(label: "Email",         value: personal.email),
            ReviewRow(label: "Phone",         value: personal.phoneNumber),
            ReviewRow(label: "Gender",        value: personal.gender.rawValue),
            ReviewRow(label: "Address",       value: personal.address.isEmpty ? "—" : personal.address)
        ]
    }

    var financialRows: [ReviewRow] {
        [
            ReviewRow(label: "Annual Income",  value: CurrencyFormatter.nzd(financial.annualIncome)),
            ReviewRow(label: "Loan Amount",    value: CurrencyFormatter.nzd(financial.loanAmount)),
            ReviewRow(label: "Loan Ratio",     value: String(format: "%.1f%%", loanRatio * 100)),
            ReviewRow(label: "IRD Number",     value: maskedIRD(financial.irdNumber))
        ]
    }

 
    func submit() -> LoanApplication? {
        let app = LoanApplication(personal: personal, financial: financial)
        let ok  = LoanPersistenceService.shared.save(app)
        return ok ? app : nil
    }

  

    private var loanRatio: Double {
        guard financial.annualIncome > 0 else { return 0 }
        return financial.loanAmount / financial.annualIncome
    }


    /// Shows last 2 digits, masks the rest.
    private func maskedIRD(_ ird: String) -> String {
        guard ird.count >= 2 else { return ird }
        let suffix = String(ird.suffix(2))
        let stars  = String(repeating: "*", count: ird.count - 2)
        return stars + suffix
    }
}
