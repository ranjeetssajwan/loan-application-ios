# Loan Application iOS App

A 3-step loan application iOS app built using Swift, UIKit, and Core Data, following a lightweight MVVM architecture. The app allows users to submit a loan application, validate inputs, and view previously submitted applications stored locally on-device.


## **Overview:**
The application provides a structured loan application flow across three screens:
- Personal and financial information input
- Data validation and review
- Final submission and storage

All submitted applications are saved locally.




## **Key Features:**
- Multi-step loan application flow
- Real-time form validation
- NZ-specific validation (IRD number validation)
- Local persistence using Core Data
- Application history view with details and delete option
- Sensitive data masking for IRD numbers in UI



## **Architecture:**
The project follows a lightweight MVVM (Model–View–ViewModel) pattern:
- Views handle UI
- ViewModels handle validation and logic
- Services handle Core Data




## **Tech Stack:**
- Swift
- UIKit
- Core Data
- Xcode 26.3+
- iOS 16.0+ (deployment target)




## **Run:**
- Clone the repository
- Open LoanApp.xcodeproj
- Build and run using Xcode on a simulator or device




## **Possible Future Improvements:**
- Add unit tests for validation logic
- Enable editing of existing applications
- Improve secure storage for sensitive data (e.g. Keychain)
- Add dark mode support
- Backend API integration




## **Author:** 
Ranjeet Sajwan,
GitHub: https://github.com/ranjeetssajwan




## **Notes:**
This project was built as a technical assignment to demonstrate iOS development skills, architectural thinking, and data handling in a mobile-first environment. Feel free to use it as a reference.
