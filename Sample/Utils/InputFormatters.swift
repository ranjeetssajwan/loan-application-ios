
//
//  InputFormatters.swift
//  LoanApp
//


import Foundation

// MARK: - CurrencyFormatter

enum CurrencyFormatter {


    static func format(_ rawText: String) -> String {
        let digits = rawText.filter { $0.isNumber }
        guard !digits.isEmpty else { return "" }

        // Convert to Int to apply grouping separator
        guard let value = Int(digits) else { return digits }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: value)) ?? digits
    }



    static func numericValue(_ formattedText: String) -> Double {
        let digits = formattedText.filter { $0.isNumber }
        return Double(digits) ?? 0
    }
}

// MARK: - NZPhoneFormatter

enum NZPhoneFormatter {


    static let prefix = "+64 "


    static let maxSubscriberDigits = 9

    // MARK: Public

    static func format(_ rawText: String) -> String {
        let subscriberDigits = extractSubscriberDigits(from: rawText)
        let formatted = formatSubscriberDigits(subscriberDigits)
        return prefix + formatted
    }


    /// - Parameter formattedText: A formatted string like `"+64 21 123 4567"`.
    static func subscriberDigits(from formattedText: String) -> String {
        extractSubscriberDigits(from: formattedText)
    }

    // MARK: Private


    private static func extractSubscriberDigits(from text: String) -> String {
        var working = text

        // Strip the literal "+64" or "64" prefix if present
        if working.hasPrefix("+64") {
            working = String(working.dropFirst(3))
        } else if working.hasPrefix("64") {
            working = String(working.dropFirst(2))
        }


        var digits = working.filter { $0.isNumber }


        if digits.hasPrefix("0") {
            digits = String(digits.dropFirst())
        }

        // Enforce max length
        if digits.count > maxSubscriberDigits {
            digits = String(digits.prefix(maxSubscriberDigits))
        }

        return digits
    }

    private static func formatSubscriberDigits(_ digits: String) -> String {
        let count = digits.count
        guard count > 0 else { return "" }

 
        let g1End = min(2, count)          // first group: 2 digits
        let g2End = min(5, count)          // second group: next 3 digits
        // third group: remaining

        let idx1 = digits.index(digits.startIndex, offsetBy: g1End)
        let idx2 = digits.index(digits.startIndex, offsetBy: g2End)

        var parts: [String] = [String(digits[..<idx1])]

        if count > 2 {
            parts.append(String(digits[idx1..<idx2]))
        }
        if count > 5 {
            parts.append(String(digits[idx2...]))
        }

        return parts.joined(separator: " ")
    }
}
