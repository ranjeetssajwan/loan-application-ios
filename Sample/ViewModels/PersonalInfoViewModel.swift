
//
//  PersonalInfoViewModel.swift
//  LoanApp
//
//  ViewModel for Screen 1 – Personal Information.
//

import Foundation

final class PersonalInfoViewModel {

    // MARK: - Inputs (bound from ViewController)

    var fullName:    String = ""
    var email:       String = ""
    var phoneNumber: String = ""
    var gender:      Gender = .male
    var address:     String = ""   // optional

    // MARK: - Per-field validation (used for real-time feedback)

 
    func validateFullName() -> String? {
        let trimmed = fullName.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty                        { return "Full name is required." }
        if trimmed.split(separator: " ").count < 2 { return "Please enter your first and last name." }
        return nil
    }

   
    func validateEmail() -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty             { return "Email address is required." }
        if !isValidEmail(trimmed)      { return "Please enter a valid email address." }
        return nil
    }
 
    func validatePhone() -> String? {
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed == NZPhoneFormatter.prefix.trimmingCharacters(in: .whitespaces) {
            return "Phone number is required."
        }
        let digits = NZPhoneFormatter.subscriberDigits(from: trimmed)
        if digits.count < 8 || digits.count > 9 {
            return "Enter a valid NZ number (e.g. +64 21 123 4567)."
        }
        return nil
    }

 

    struct ValidationResult {
        var isValid:       Bool
        var fullNameError: String?
        var emailError:    String?
        var phoneError:    String?
    }

   
    func validate() -> ValidationResult {
        let nameErr  = validateFullName()
        let emailErr = validateEmail()
        let phoneErr = validatePhone()
        return ValidationResult(
            isValid:       nameErr == nil && emailErr == nil && phoneErr == nil,
            fullNameError: nameErr,
            emailError:    emailErr,
            phoneError:    phoneErr
        )
    }

 
    func buildPersonalInfo() -> PersonalInfo? {
        guard validate().isValid else { return nil }
        return PersonalInfo(
            fullName:    fullName.trimmingCharacters(in: .whitespaces),
            email:       email.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
            gender:      gender,
            address:     address.trimmingCharacters(in: .whitespaces)
        )
    }

    

    private func isValidEmail(_ value: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return value.range(of: regex, options: .regularExpression) != nil
    }




    func prefill(with info: PersonalInfo) {
        fullName    = info.fullName
        email       = info.email
        // Ensure the stored phone number is re-prefixed for display
        phoneNumber = NZPhoneFormatter.format(info.phoneNumber)
        gender      = info.gender
        address     = info.address
    }
}
