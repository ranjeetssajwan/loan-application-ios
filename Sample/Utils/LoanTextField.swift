
//
//  LoanTextField.swift
//  LoanApp
//
//  Styled UITextField used across all form screens.
//

import UIKit

final class LoanTextField: UITextField {

    // MARK: - State

    enum FieldState { case normal, focused, error }

    private(set) var fieldState: FieldState = .normal {
        didSet { updateAppearance() }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor      = AppColor.inputBg
        textColor            = AppColor.textPrimary
        tintColor            = AppColor.accentLight
        font                 = .systemFont(ofSize: 16)
        layer.cornerRadius   = Radius.md
        layer.borderWidth    = 1.5
        layer.borderColor    = AppColor.border.cgColor
        attributedPlaceholder = makePlaceholder(for: placeholder ?? "")

        // left padding
        let pad        = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        leftView       = pad
        leftViewMode   = .always
        rightView      = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        rightViewMode  = .always

        // Editing observers
        addTarget(self, action: #selector(didBeginEdit), for: .editingDidBegin)
        addTarget(self, action: #selector(didEndEdit),   for: .editingDidEnd)
    }

    // MARK: - Public

    func setError(_ show: Bool) {
        fieldState = show ? .error : (isFirstResponder ? .focused : .normal)
    }

    // MARK: - Private

    @objc private func didBeginEdit() {
        if fieldState != .error { fieldState = .focused }
    }

    @objc private func didEndEdit() {
        if fieldState != .error { fieldState = .normal }
    }

    private func updateAppearance() {
        UIView.animate(withDuration: 0.2) {
            switch self.fieldState {
            case .normal:
                self.layer.borderColor = AppColor.border.cgColor
                self.layer.shadowOpacity = 0
            case .focused:
                self.layer.borderColor = AppColor.accent.cgColor
                self.layer.shadowColor  = AppColor.accent.cgColor
                self.layer.shadowOpacity = 0.4
                self.layer.shadowRadius  = 6
                self.layer.shadowOffset  = .zero
            case .error:
                self.layer.borderColor  = AppColor.error.cgColor
                self.layer.shadowColor  = AppColor.error.cgColor
                self.layer.shadowOpacity = 0.3
                self.layer.shadowRadius  = 6
                self.layer.shadowOffset  = .zero
            }
        }
    }

    private func makePlaceholder(for text: String) -> NSAttributedString {
        NSAttributedString(string: text,
                           attributes: [.foregroundColor: AppColor.textMuted])
    }

    override var placeholder: String? {
        didSet {
            attributedPlaceholder = makePlaceholder(for: placeholder ?? "")
        }
    }
}
