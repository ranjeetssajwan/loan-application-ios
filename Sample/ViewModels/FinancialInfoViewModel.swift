
//
//  FinancialInfoViewModel.swift
//  LoanApp
//
//  ViewModel for Screen 2 – Financial Information.
//

import Foundation

final class FinancialInfoViewModel {

 

    var annualIncomeText: String = ""
    var loanAmountText:   String = ""
    var irdNumber:        String = ""

 

    var annualIncome: Double { CurrencyFormatter.numericValue(annualIncomeText) }
    var loanAmount:   Double { CurrencyFormatter.numericValue(loanAmountText) }

  

    struct ValidationResult {
        var isValid:          Bool
        var incomeError:      String?
        var loanAmountError:  String?
        var irdError:         String?
    }

 
    func validateIncome() -> String? {
        let trimmed = annualIncomeText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty   { return "Annual income is required." }
        if annualIncome <= 0 { return "Please enter a valid annual income." }
        return nil
    }

 
    func validateLoanAmount() -> String? {
        let trimmed = loanAmountText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty  { return "Desired loan amount is required." }
        if loanAmount <= 0  { return "Please enter a valid loan amount." }
        if annualIncome > 0 && loanAmount > annualIncome * 0.5 {
            let max = formatCurrency(annualIncome * 0.5)
            return "Loan cannot exceed 50% of income (\(max))."
        }
        return nil
    }

 
    func validateIRD() -> String? {
        let cleaned = irdNumber
            .replacingOccurrences(of: "-", with: "")
            .filter { $0.isNumber }
        if cleaned.isEmpty            { return "IRD number is required." }
        if !isValidIRDNumber(cleaned) { return "Please enter a valid IRD number." }
        return nil
    }

 
    func validate() -> ValidationResult {
        let incErr  = validateIncome()
        let loanErr = validateLoanAmount()
        let irdErr  = validateIRD()
        return ValidationResult(
            isValid:         incErr == nil && loanErr == nil && irdErr == nil,
            incomeError:     incErr,
            loanAmountError: loanErr,
            irdError:        irdErr
        )
    }

    private func isValidIRDNumber(_ input: String) -> Bool {

        // Must be 8 or 9 digits
        guard input.range(
            of: #"^\d{8,9}$"#,
            options: .regularExpression
        ) != nil else {
            return false
        }

        var digits = input.compactMap {
            Int(String($0))
        }

        // Add leading zero for 8-digit numbers
        if digits.count == 8 {
            digits.insert(0, at: 0)
        }

        let checkDigit = digits.removeLast()

        // Primary weighting
        let primaryWeights = [3, 2, 7, 6, 5, 4, 3, 2]

        let primarySum = zip(digits, primaryWeights)
            .map(*)
            .reduce(0, +)

        let primaryRemainder = primarySum % 11

        var calculated =
        primaryRemainder == 0
        ? 0
        : 11 - primaryRemainder

        // Secondary weighting
        if calculated == 10 {

            let secondaryWeights = [7, 4, 3, 2, 5, 2, 7, 6]

            let secondarySum = zip(digits, secondaryWeights)
                .map(*)
                .reduce(0, +)

            let secondaryRemainder = secondarySum % 11

            calculated =
            secondaryRemainder == 0
            ? 0
            : 11 - secondaryRemainder
        }

        // Invalid if still 10
        if calculated == 10 {
            return false
        }

        return calculated == checkDigit
    }
    
     
    
 
    var maximumLoanAmount: Double { annualIncome * 0.5 }

    func buildFinancialInfo() -> FinancialInfo? {
        guard validate().isValid else { return nil }
        return FinancialInfo(
            annualIncome: annualIncome,
            loanAmount:   loanAmount,
            irdNumber:    irdNumber.filter { $0.isNumber }
        )
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }

 

    func prefill(with info: FinancialInfo) {
        annualIncomeText = CurrencyFormatter.format(String(format: "%.0f", info.annualIncome))
        loanAmountText   = CurrencyFormatter.format(String(format: "%.0f", info.loanAmount))
        irdNumber        = info.irdNumber
    }
}
