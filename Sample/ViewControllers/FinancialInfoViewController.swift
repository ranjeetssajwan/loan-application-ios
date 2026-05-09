
//
//  FinancialInfoViewController.swift
//  LoanApp
//
//  Screen 2 – Financial Information
//

import UIKit

final class FinancialInfoViewController: UIViewController {

 

    let viewModel = FinancialInfoViewModel()

 

    var onNext: ((FinancialInfo) -> Void)?
    var onBack: (() -> Void)?

    

    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let progressView = StepProgressView(steps: ["Personal", "Financial", "Review"])

    private let incomeField  = AppUI.inputField(placeholder: "e.g. 85000", keyboard: .numberPad)
    private let loanField    = AppUI.inputField(placeholder: "e.g. 30000", keyboard: .numberPad)
    private let irdField     = AppUI.inputField(placeholder: "e.g. 123456789", keyboard: .numberPad)

    private let incomeError  = AppUI.errorLabel()
    private let loanError    = AppUI.errorLabel()
    private let irdError     = AppUI.errorLabel()

    // Live eligibility bar
    private let eligibilityCard     = AppUI.card()
    private let eligibilityLabel    = AppUI.label(text: "Eligibility", font: .systemFont(ofSize: 13, weight: .semibold), color: AppColor.textSecondary)
    private let eligibilityBar      = UIProgressView(progressViewStyle: .default)
    private let eligibilityCaption  = AppUI.label(text: "Enter income and loan amount to see eligibility.", font: .systemFont(ofSize: 12), color: AppColor.textMuted, lines: 2)

    private let nextButton = AppUI.primaryButton(title: "Continue →")
    private let backButton = AppUI.secondaryButton(title: "← Back")

    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Financial Info"
        setupNavigation()
        setupUI()
        setupDelegates()
        setupKeyboardHandling()
        progressView.currentStep = 2
        syncFieldsFromViewModel()   // populate fields if prefill() was called before viewDidLoad
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        AppUI.updateGradient(in: nextButton)
    }

    

    private func setupNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.surface
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor            = AppColor.accentLight
    }

    // MARK: - UI

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

        contentStack.axis    = .vertical
        contentStack.spacing = Spacing.md
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

   
        let header = makeHeader()
        contentStack.addArrangedSubview(header)
        contentStack.setCustomSpacing(Spacing.xl, after: header)

   
        addLabeledField(sectionLabel: "ANNUAL INCOME (NZD) *", field: incomeField, error: incomeError)
        addLabeledField(sectionLabel: "DESIRED LOAN AMOUNT (NZD) *", field: loanField, error: loanError)
        addLabeledField(sectionLabel: "IRD NUMBER *", field: irdField, error: irdError)

  
        setupEligibilityCard()
        contentStack.addArrangedSubview(eligibilityCard)
        contentStack.setCustomSpacing(Spacing.xl, after: eligibilityCard)

 
        let buttonRow = UIStackView(arrangedSubviews: [backButton, nextButton])
        buttonRow.axis         = .horizontal
        buttonRow.spacing      = Spacing.sm
        buttonRow.distribution = .fillEqually
        buttonRow.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(buttonRow)

        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    }

    private func setupEligibilityCard() {
        eligibilityCard.heightAnchor.constraint(equalToConstant: 90).isActive = true

        eligibilityBar.translatesAutoresizingMaskIntoConstraints = false
        eligibilityBar.progressTintColor = AppColor.accent
        eligibilityBar.trackTintColor    = AppColor.border
        eligibilityBar.layer.cornerRadius = 3
        eligibilityBar.clipsToBounds      = true

        let stack = UIStackView(arrangedSubviews: [eligibilityLabel, eligibilityBar, eligibilityCaption])
        stack.axis    = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        eligibilityCard.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: eligibilityCard.topAnchor, constant: Spacing.md),
            stack.leadingAnchor.constraint(equalTo: eligibilityCard.leadingAnchor, constant: Spacing.md),
            stack.trailingAnchor.constraint(equalTo: eligibilityCard.trailingAnchor, constant: -Spacing.md),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: eligibilityCard.bottomAnchor, constant: -Spacing.sm),
            eligibilityBar.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    private func addLabeledField(sectionLabel text: String, field: UITextField, error: UILabel) {
        let wrapper = UIStackView()
        wrapper.axis    = .vertical
        wrapper.spacing = 6
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        let lbl = AppUI.sectionTitle(text)
        wrapper.addArrangedSubview(lbl)
        wrapper.addArrangedSubview(field)
        wrapper.addArrangedSubview(error)
        contentStack.addArrangedSubview(wrapper)
    }

    private func makeHeader() -> UIView {
        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
 
        let title = AppUI.label(text: "Financial Information",
                                font: .systemFont(ofSize: 22, weight: .bold))
        let sub   = AppUI.label(text: "Loan amount cannot exceed 50% of your annual income.",
                                font: .systemFont(ofSize: 14),
                                color: AppColor.textSecondary, lines: 2)
        [title, sub].forEach { stack.addArrangedSubview($0) }
        return stack
    }

    // MARK: - Delegates

    private func setupDelegates() {
        [incomeField, loanField, irdField].forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        }
    }

    // MARK: - Live eligibility update

    @objc private func textDidChange(_ sender: UITextField) {
        syncViewModel()         // keep ViewModel current on every keystroke
        updateEligibilityBar()

        if sender === incomeField {
            let error = viewModel.validateIncome()
            incomeError.text     = error
            incomeError.isHidden = error == nil
            incomeField.setError(error != nil)
        } else if sender === loanField {
            let error = viewModel.validateLoanAmount()
            loanError.text     = error
            loanError.isHidden = error == nil
            loanField.setError(error != nil)
        } else if sender === irdField {
            let error = viewModel.validateIRD()
            irdError.text     = error
            irdError.isHidden = error == nil
            irdField.setError(error != nil)
        }
    }

    private func updateEligibilityBar() {
        let income = viewModel.annualIncome
        let loan   = viewModel.loanAmount
        guard income > 0 else {
            eligibilityBar.setProgress(0, animated: true)
            eligibilityCaption.text = "Enter income and loan amount to see eligibility."
            eligibilityCaption.textColor = AppColor.textMuted
            return
        }
        let ratio = Float(loan / income)
        eligibilityBar.setProgress(min(ratio, 1.0), animated: true)

        if loan == 0 {
            eligibilityCaption.text = "Max eligible: \(formatCurrency(income * 0.5))"
            eligibilityCaption.textColor = AppColor.textMuted
            eligibilityBar.progressTintColor = AppColor.accent
        } else if ratio <= 0.5 {
            let pct = Int(ratio * 100)
            eligibilityCaption.text = "✓ Within limit (\(pct)% of income). Max: \(formatCurrency(income * 0.5))"
            eligibilityCaption.textColor = AppColor.success
            eligibilityBar.progressTintColor = AppColor.success
        } else {
            let excess = loan - income * 0.5
            eligibilityCaption.text = "✗ Exceeds limit by \(formatCurrency(excess)). Max: \(formatCurrency(income * 0.5))"
            eligibilityCaption.textColor = AppColor.error
            eligibilityBar.progressTintColor = AppColor.error
        }
    }

 

    @objc private func handleNext() {
        view.endEditing(true)
        syncViewModel()
        let result = viewModel.validate()

        incomeError.text = result.incomeError;     incomeError.isHidden = result.incomeError == nil
        loanError.text   = result.loanAmountError; loanError.isHidden   = result.loanAmountError == nil
        irdError.text    = result.irdError;         irdError.isHidden    = result.irdError == nil

        incomeField.setError(result.incomeError != nil)
        loanField.setError(result.loanAmountError != nil)
        irdField.setError(result.irdError != nil)

        guard result.isValid, let info = viewModel.buildFinancialInfo() else {
            shakeInvalidFields(result)
            return
        }
        onNext?(info)
    }

    @objc private func handleBack() {
        onBack?()
    }

    // MARK: - Helpers

    private func syncViewModel() {
        viewModel.annualIncomeText = incomeField.text ?? ""
        viewModel.loanAmountText   = loanField.text   ?? ""
        viewModel.irdNumber        = irdField.text     ?? ""
    }

    func syncFieldsFromViewModel() {
        incomeField.text = viewModel.annualIncomeText
        loanField.text   = viewModel.loanAmountText
        irdField.text    = viewModel.irdNumber
        updateEligibilityBar()
    }

    private func shakeInvalidFields(_ result: FinancialInfoViewModel.ValidationResult) {
        if result.incomeError     != nil { shake(incomeField) }
        if result.loanAmountError != nil { shake(loanField) }
        if result.irdError        != nil { shake(irdField) }
    }

    private func shake(_ v: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values   = [-8, 8, -6, 6, -4, 4, 0]
        anim.duration = 0.4
        v.layer.add(anim, forKey: "shake")
    }

    private func formatCurrency(_ value: Double) -> String {
        let f = NumberFormatter(); f.numberStyle = .currency; f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }

    // MARK: - Keyboard

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKB))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func kbShow(_ n: Notification) {
        guard let f = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = f.height + Spacing.md
    }
    @objc private func kbHide(_ n: Notification) { scrollView.contentInset.bottom = 0 }
    @objc private func dismissKB() { view.endEditing(true) }
}

// MARK: - UITextFieldDelegate

extension FinancialInfoViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // ── IRD: digits only, no formatting ──────────────────────────────
        if textField === irdField {
            let allowed = CharacterSet.decimalDigits
            return string.unicodeScalars.allSatisfy { allowed.contains($0) } || string.isEmpty
        }

        // ── Income / Loan: intercept, format, set manually ───────────────
        guard textField === incomeField || textField === loanField else { return true }

        // Build the new raw text as if UIKit had applied the replacement
        let currentText = textField.text ?? ""
        guard let swiftRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: swiftRange, with: string)

        // Format the result (digits → comma-grouped)
        let formatted = CurrencyFormatter.format(updatedText)
        textField.text = formatted

        // Move cursor to end (standard for numeric masked fields)
        if let endPos = textField.position(from: textField.endOfDocument, offset: 0) {
            textField.selectedTextRange = textField.textRange(from: endPos, to: endPos)
        }

        // Fire editingChanged manually so textDidChange(_:) runs
        textField.sendActions(for: .editingChanged)

        return false   // we already applied the change
    }

    /// Validate on blur so a field that was tapped-into and left empty shows its error.
    func textFieldDidEndEditing(_ textField: UITextField) {
        syncViewModel()
        updateEligibilityBar()
        switch textField {
        case incomeField:
            let error = viewModel.validateIncome()
            incomeError.text     = error
            incomeError.isHidden = error == nil
            incomeField.setError(error != nil)
        case loanField:
            let error = viewModel.validateLoanAmount()
            loanError.text     = error
            loanError.isHidden = error == nil
            loanField.setError(error != nil)
        case irdField:
            let error = viewModel.validateIRD()
            irdError.text     = error
            irdError.isHidden = error == nil
            irdField.setError(error != nil)
        default: break
        }
    }
}
