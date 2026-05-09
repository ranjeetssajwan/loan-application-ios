
//
//  ApplicationDetailViewModel.swift
//  LoanApp
//
//  ViewModel for the Application Detail screen.
//  Maps a LoanApplication domain struct into display-ready rows for each section.
//

import UIKit

final class ApplicationDetailViewModel {

    

    let application: LoanApplication

    init(application: LoanApplication) {
        self.application = application
    }

 

    struct DetailRow {
        let label:      String
        let value:      String
        var valueColor: UIColor = AppColor.textPrimary
    }

    

    var personalRows: [DetailRow] {
        [
            DetailRow(label: "Full Name",     value: application.personal.fullName),
            DetailRow(label: "Email",         value: application.personal.email),
            DetailRow(label: "Phone Number",  value: application.personal.phoneNumber),
            DetailRow(label: "Gender",        value: application.personal.gender.rawValue),
            DetailRow(label: "Address",       value: application.personal.address.isEmpty
                                                        ? "—" : application.personal.address),
            DetailRow(label: "Date of Birth", value: "—")   // Not yet in model — reserved for future
        ]
    }

  

    var financialRows: [DetailRow] {
        [
            DetailRow(label: "Annual Income",  value: formatCurrency(application.financial.annualIncome)),
            DetailRow(label: "Loan Amount",    value: formatCurrency(application.financial.loanAmount)),
            DetailRow(label: "Max Eligible",   value: formatCurrency(application.financial.annualIncome * 0.5)),
            DetailRow(label: "Loan / Income",  value: String(format: "%.1f%%", application.loanToIncomeRatio * 100)),
            DetailRow(label: "IRD Number",     value: maskedIRD(application.financial.irdNumber)),
            DetailRow(label: "Eligibility",    value: eligibilityText,
                      valueColor: eligibilityColor)
        ]
    }

  

    var applicationRows: [DetailRow] {
        [
            DetailRow(label: "Application ID",  value: String(application.id.uuidString.prefix(8)).uppercased()),
            DetailRow(label: "Full ID",         value: application.id.uuidString.lowercased()),
            DetailRow(label: "Created Date",    value: formatDate(application.submittedAt)),
            DetailRow(label: "Last Updated",    value: formatDate(application.submittedAt)),
            DetailRow(label: "Status",          value: "Submitted",
                      valueColor: AppColor.success)
        ]
    }

    

    var eligibilityText: String {
        application.isLoanAmountValid ? "✓ Within Limit" : "✗ Exceeds Limit"
    }

    var eligibilityColor: UIColor {
        application.isLoanAmountValid ? AppColor.success : AppColor.error
    }

    var loanRatioFraction: Float {
        Float(min(application.loanToIncomeRatio, 1.0))
    }

 

    private func formatCurrency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle           = .currency
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }

    private func formatDate(_ date: Date) -> String {
        let f       = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        return f.string(from: date)
    }

    /// Shows last 2 digits, masks the rest.
    private func maskedIRD(_ ird: String) -> String {
        guard ird.count >= 2 else { return ird }
        return String(repeating: "*", count: ird.count - 2) + String(ird.suffix(2))
    }
}
