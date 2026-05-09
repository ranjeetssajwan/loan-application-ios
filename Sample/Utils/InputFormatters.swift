
//
//  InputFormatters.swift
//  LoanApp
//
//  Stateless formatting helpers for currency fields and NZ phone numbers.
//  Used by ViewModels (for parsing clean values) and ViewControllers
//  (for real-time display formatting).
//

import Foundation

// MARK: - CurrencyFormatter

enum CurrencyFormatter {

    /// Formats a raw text string (may already contain commas) into a
    /// comma-separated integer string.
    ///
    /// - Parameter rawText: Any string. Non-digit characters are stripped first.
    /// - Returns: Formatted string, e.g. `"1000000"` → `"1,000,000"`.
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

    /// Strips commas (and any other non-digit characters) then converts to Double.
    ///
    /// - Parameter formattedText: A possibly comma-formatted string like `"1,000,000"`.
    /// - Returns: The numeric value, or `0` if the string cannot be parsed.
    static func numericValue(_ formattedText: String) -> Double {
        let digits = formattedText.filter { $0.isNumber }
        return Double(digits) ?? 0
    }
}

// MARK: - NZPhoneFormatter

enum NZPhoneFormatter {

    /// The mandatory country code prefix shown in the field.
    static let prefix = "+64 "

    /// Maximum number of subscriber digits (after the country code).
    /// NZ mobiles: 021/022/027/028 XXX XXXX → 9 subscriber digits.
    /// NZ landlines: 9 XXXX XXXX → 9 subscriber digits (without leading 0).
    static let maxSubscriberDigits = 9

    // MARK: Public

    /// Formats a raw string into a display-ready NZ phone number.
    ///
    /// The result always starts with `"+64 "` followed by spaced digit groups.
    /// Example: `"21 123 4567"` → `"+64 21 123 4567"`.
    ///
    /// - Parameter rawText: Any string. Leading `+64` and spaces are handled.
    static func format(_ rawText: String) -> String {
        let subscriberDigits = extractSubscriberDigits(from: rawText)
        let formatted = formatSubscriberDigits(subscriberDigits)
        return prefix + formatted
    }

    /// Returns only the subscriber digits (no prefix, no spaces) for validation.
    ///
    /// - Parameter formattedText: A formatted string like `"+64 21 123 4567"`.
    static func subscriberDigits(from formattedText: String) -> String {
        extractSubscriberDigits(from: formattedText)
    }

    // MARK: Private

    /// Strips the `+64` prefix (and any leading 0) then returns remaining digits.
    private static func extractSubscriberDigits(from text: String) -> String {
        var working = text

        // Strip the literal "+64" or "64" prefix if present
        if working.hasPrefix("+64") {
            working = String(working.dropFirst(3))
        } else if working.hasPrefix("64") {
            working = String(working.dropFirst(2))
        }

        // Keep only digits
        var digits = working.filter { $0.isNumber }

        // If the subscriber number starts with 0 (e.g. user typed 021…),
        // strip the leading 0 because +64 replaces it.
        if digits.hasPrefix("0") {
            digits = String(digits.dropFirst())
        }

        // Enforce max length
        if digits.count > maxSubscriberDigits {
            digits = String(digits.prefix(maxSubscriberDigits))
        }

        return digits
    }

    /// Inserts spaces to produce groups matching NZ formatting:
    /// - 1–2 digits   → no groups (e.g. `"2"`, `"21"`)
    /// - 3–5 digits   → `"XXX-XX"` style (e.g. `"21 1"`, `"21 12"`)
    /// - 6+ digits    → `"XX XXX XXXX"` (e.g. `"21 123 4567"`)
    private static func formatSubscriberDigits(_ digits: String) -> String {
        let count = digits.count
        guard count > 0 else { return "" }

        // NZ subscriber numbers: 2 digit area prefix + up to 7 remaining
        // Groups: [2][3][4] → "21 123 4567" (9 digits total)
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
