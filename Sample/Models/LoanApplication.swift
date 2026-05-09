
//
//  LoanApplication.swift
//  LoanApp
//
//  MVVM Model — represents one complete loan application.
//

import Foundation

// MARK: - Gender

enum Gender: String, Codable, CaseIterable {
    case male   = "Male"
    case female = "Female"
    case other  = "Other"
    case preferNotToSay = "Prefer not to say"
}

// MARK: - Personal Info

struct PersonalInfo: Codable {
    var fullName:    String
    var email:       String
    var phoneNumber: String
    var gender:      Gender
    var address:     String   // optional field — may be empty
}

// MARK: - Financial Info

struct FinancialInfo: Codable {
    var annualIncome:    Double
    var loanAmount:      Double
    var irdNumber:       String
}

// MARK: - Loan Application

struct LoanApplication: Codable, Identifiable {
    var id:            UUID
    var submittedAt:   Date
    var personal:      PersonalInfo
    var financial:     FinancialInfo

    init(personal: PersonalInfo, financial: FinancialInfo) {
        self.id          = UUID()
        self.submittedAt = Date()
        self.personal    = personal
        self.financial   = financial
    }

    // MARK: Computed helpers

    /// Loan-to-income ratio (loan / income).
    var loanToIncomeRatio: Double {
        guard financial.annualIncome > 0 else { return 0 }
        return financial.loanAmount / financial.annualIncome
    }

    /// Whether the loan amount is within the 50 % of annual income limit.
    var isLoanAmountValid: Bool {
        financial.annualIncome > 0 && financial.loanAmount <= financial.annualIncome * 0.5
    }
}
