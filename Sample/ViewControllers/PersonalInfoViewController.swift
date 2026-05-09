
//
//  PersonalInfoViewController.swift
//  LoanApp
//
//  Screen 1 – Personal Information
//

import UIKit

final class PersonalInfoViewController: UIViewController {

 

    let viewModel = PersonalInfoViewModel()
 
    var onNext: ((PersonalInfo) -> Void)?

 
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let progressView = StepProgressView(steps: ["Personal", "Financial", "Review"])

 
    private let nameField    = AppUI.inputField(placeholder: "Full Name")
    private let emailField   = AppUI.inputField(placeholder: "Email Address", keyboard: .emailAddress)
    private let phoneField   = AppUI.inputField(placeholder: "Phone Number",  keyboard: .phonePad)
    private let addressField = AppUI.inputField(placeholder: "Address (optional)")

 
    private let nameError    = AppUI.errorLabel()
    private let emailError   = AppUI.errorLabel()
    private let phoneError   = AppUI.errorLabel()

 
    private let genderLabel  = AppUI.label(text: "Gender", font: .systemFont(ofSize: 16), color: AppColor.textPrimary)
    private let genderPicker = UIPickerView()
    private let genderCard   = AppUI.card()

 
    private let nextButton   = AppUI.primaryButton(title: "Continue →")

 

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Personal Info"
        setupNavigation()
        setupUI()
        setupDelegates()
        setupKeyboardHandling()
        progressView.currentStep = 1
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        AppUI.updateGradient(in: nextButton)
    }

    // MARK: - UI Setup

    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor   = AppColor.surface
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor            = AppColor.accentLight

        // Right: applications list
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet.rectangle"),
            style: .plain,
            target: self,
            action: #selector(showApplicationsList)
        )
    }

    private func setupUI() {
        view.backgroundColor = AppColor.background

  
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis      = .vertical
        contentStack.spacing   = Spacing.md
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Spacing.lg),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Spacing.md),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Spacing.md),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Spacing.xl),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Spacing.md * 2)
        ])

      
        contentStack.addArrangedSubview(progressView)
        contentStack.setCustomSpacing(Spacing.xl, after: progressView)

       
        let header = makeHeader(icon: "", title: "Personal Information",
                                subtitle: "Please fill in your details accurately.")
        contentStack.addArrangedSubview(header)
        contentStack.setCustomSpacing(Spacing.xl, after: header)

       
        addField(label: "Full Name *", field: nameField, error: nameError)
        addField(label: "Email Address *", field: emailField, error: emailError)
        addField(label: "Phone Number *", field: phoneField, error: phoneError)
        addGenderRow()
        addField(label: "Address", field: addressField, error: nil)

 
        contentStack.setCustomSpacing(Spacing.xl, after: contentStack.arrangedSubviews.last!)
        contentStack.addArrangedSubview(nextButton)
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    }

    private func addField(label text: String, field: UITextField, error: UILabel?) {
        let wrapper = UIStackView()
        wrapper.axis    = .vertical
        wrapper.spacing = 6
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        let lbl = AppUI.sectionTitle(text)
        lbl.text = text.uppercased()
        wrapper.addArrangedSubview(lbl)
        wrapper.addArrangedSubview(field)
        if let err = error { wrapper.addArrangedSubview(err) }
        contentStack.addArrangedSubview(wrapper)
    }

    private func addGenderRow() {
        let wrapper = UIStackView()
        wrapper.axis    = .vertical
        wrapper.spacing = 6
        wrapper.translatesAutoresizingMaskIntoConstraints = false

        let lbl = AppUI.sectionTitle("GENDER *")
        wrapper.addArrangedSubview(lbl)

        genderCard.heightAnchor.constraint(equalToConstant: 120).isActive = true
        genderPicker.translatesAutoresizingMaskIntoConstraints = false
        genderCard.addSubview(genderPicker)
        NSLayoutConstraint.activate([
            genderPicker.topAnchor.constraint(equalTo: genderCard.topAnchor),
            genderPicker.leadingAnchor.constraint(equalTo: genderCard.leadingAnchor),
            genderPicker.trailingAnchor.constraint(equalTo: genderCard.trailingAnchor),
            genderPicker.bottomAnchor.constraint(equalTo: genderCard.bottomAnchor)
        ])
        wrapper.addArrangedSubview(genderCard)
        contentStack.addArrangedSubview(wrapper)
    }

    private func makeHeader(icon: String, title: String, subtitle: String) -> UIView {
        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
 
        let titleLbl = AppUI.label(text: title,
                                   font: .systemFont(ofSize: 22, weight: .bold),
                                   color: AppColor.textPrimary)
        let subLbl = AppUI.label(text: subtitle,
                                  font: .systemFont(ofSize: 14),
                                  color: AppColor.textSecondary,
                                  lines: 2)
        [titleLbl, subLbl].forEach { stack.addArrangedSubview($0) }
        return stack
    }

 

    private func setupDelegates() {
        genderPicker.dataSource = self
        genderPicker.delegate   = self
        genderPicker.setValue(AppColor.textPrimary, forKey: "textColor")

        [nameField, emailField, phoneField, addressField].forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        }

        phoneField.autocapitalizationType = .none
        phoneField.keyboardType = .numberPad
        // Pre-populate with the NZ country code prefix "+64 "
        phoneField.text = NZPhoneFormatter.format("")
    }


    // MARK: - Actions

    @objc private func textDidChange(_ sender: UITextField) {
        syncViewModel()   // keep ViewModel current on every keystroke
        if sender === nameField {
            let error = viewModel.validateFullName()
            nameError.text     = error
            nameError.isHidden = error == nil
            nameField.setError(error != nil)
        } else if sender === emailField {
            let error = viewModel.validateEmail()
            emailError.text     = error
            emailError.isHidden = error == nil
            emailField.setError(error != nil)
        } else if sender === phoneField {
            let error = viewModel.validatePhone()
            phoneError.text     = error
            phoneError.isHidden = error == nil
            phoneField.setError(error != nil)
        }
    }

    @objc private func handleNext() {
        view.endEditing(true)
        syncViewModel()
        let result = viewModel.validate()

        nameError.text  = result.fullNameError; nameError.isHidden  = result.fullNameError == nil
        emailError.text = result.emailError;    emailError.isHidden = result.emailError == nil
        phoneError.text = result.phoneError;    phoneError.isHidden = result.phoneError == nil

        nameField.setError(result.fullNameError != nil)
        emailField.setError(result.emailError != nil)
        phoneField.setError(result.phoneError != nil)

        guard result.isValid, let info = viewModel.buildPersonalInfo() else {
            shakeInvalidFields(result)
            return
        }
        onNext?(info)
    }

    @objc private func showApplicationsList() {
        let vc = ApplicationsListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Helpers

    private func syncViewModel() {
        viewModel.fullName    = nameField.text    ?? ""
        viewModel.email       = emailField.text   ?? ""
        viewModel.phoneNumber = phoneField.text   ?? ""
        viewModel.address     = addressField.text ?? ""
        viewModel.gender      = Gender.allCases[genderPicker.selectedRow(inComponent: 0)]
    }
 
    func syncFieldsFromViewModel() {
        nameField.text    = viewModel.fullName
        emailField.text   = viewModel.email
        phoneField.text   = viewModel.phoneNumber
        addressField.text = viewModel.address
        if let index = Gender.allCases.firstIndex(of: viewModel.gender) {
            genderPicker.selectRow(index, inComponent: 0, animated: false)
        }
    }

    private func shakeInvalidFields(_ result: PersonalInfoViewModel.ValidationResult) {
        if result.fullNameError != nil { shake(nameField) }
        if result.emailError    != nil { shake(emailField) }
        if result.phoneError    != nil { shake(phoneField) }
    }

    private func shake(_ view: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values   = [-8, 8, -6, 6, -4, 4, 0]
        anim.duration = 0.4
        view.layer.add(anim, forKey: "shake")
    }

    // MARK: - Keyboard

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow(_ note: Notification) {
        guard let info = note.userInfo,
              let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = frame.height + Spacing.md
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        scrollView.contentInset.bottom = 0
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
}

// MARK: - UITextFieldDelegate

extension PersonalInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:  emailField.becomeFirstResponder()
        case emailField: phoneField.becomeFirstResponder()
        case phoneField: addressField.becomeFirstResponder()
        default:         textField.resignFirstResponder()
        }
        return true
    }

    // MARK: Phone prefix lock + NZ formatting

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField === phoneField else { return true }

        let currentText = textField.text ?? NZPhoneFormatter.format("")
        let prefixCount  = NZPhoneFormatter.prefix.count   // length of "+64 "

        // Block any edit that would touch or remove the "+64 " prefix
        if range.location < prefixCount {
            return false
        }

        // Only allow digit input (or deletion / empty replacement)
        if !string.isEmpty {
            let allowed = CharacterSet.decimalDigits
            guard string.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
                return false
            }
        }

        // Compute the new raw text and extract subscriber digits
        guard let swiftRange = Range(range, in: currentText) else { return true }
        let updatedText     = currentText.replacingCharacters(in: swiftRange, with: string)
        let subscriberPart  = NZPhoneFormatter.subscriberDigits(from: updatedText)

        // Enforce max subscriber digit count
        if string != "" && subscriberPart.count > NZPhoneFormatter.maxSubscriberDigits {
            return false
        }

        // Apply full NZ formatting
        let formatted = NZPhoneFormatter.format(updatedText)
        textField.text = formatted

        // Always move cursor to end
        if let endPos = textField.position(from: textField.endOfDocument, offset: 0) {
            textField.selectedTextRange = textField.textRange(from: endPos, to: endPos)
        }

        // Sync ViewModel and run live validation
        syncViewModel()
        let error = viewModel.validatePhone()
        phoneError.text     = error
        phoneError.isHidden = error == nil
        phoneField.setError(error != nil)

        return false   // we already applied the change
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Ensure phone always has the +64 prefix if somehow empty
        if textField === phoneField {
            let current = textField.text ?? ""
            if !current.hasPrefix("+64") {
                textField.text = NZPhoneFormatter.format(current)
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        syncViewModel()
        switch textField {
        case nameField:
            let error = viewModel.validateFullName()
            nameError.text     = error
            nameError.isHidden = error == nil
            nameField.setError(error != nil)
        case emailField:
            let error = viewModel.validateEmail()
            emailError.text     = error
            emailError.isHidden = error == nil
            emailField.setError(error != nil)
        case phoneField:
            let error = viewModel.validatePhone()
            phoneError.text     = error
            phoneError.isHidden = error == nil
            phoneField.setError(error != nil)
        default: break
        }
    }
}

// MARK: - UIPickerView

extension PersonalInfoViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        Gender.allCases.count
    }
    func pickerView(_ pickerView: UIPickerView,
                    attributedTitleForRow row: Int,
                    forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: Gender.allCases[row].rawValue,
                           attributes: [.foregroundColor: AppColor.textPrimary])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.gender = Gender.allCases[row]
    }
}
