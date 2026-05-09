
//
//  DesignSystem.swift
//  LoanApp
//
//  Shared colors, fonts, spacing constants, and reusable UI helpers.
//

import UIKit

// MARK: - Colors

enum AppColor {
    static let background    = UIColor(hex: "#0F0F1A")
    static let surface       = UIColor(hex: "#1A1A2E")
    static let card          = UIColor(hex: "#16213E")
    static let accent        = UIColor(hex: "#7C3AED")   // violet
    static let accentLight   = UIColor(hex: "#A78BFA")
    static let success       = UIColor(hex: "#10B981")
    static let error         = UIColor(hex: "#EF4444")
    static let warning       = UIColor(hex: "#F59E0B")
    static let textPrimary   = UIColor.white
    static let textSecondary = UIColor(hex: "#9CA3AF")
    static let textMuted     = UIColor(hex: "#6B7280")
    static let border        = UIColor(hex: "#2D2D44")
    static let inputBg       = UIColor(hex: "#1E1E30")
    static let stepActive    = UIColor(hex: "#7C3AED")
    static let stepDone      = UIColor(hex: "#10B981")
    static let stepInactive  = UIColor(hex: "#2D2D44")
}

// MARK: - UIColor hex init

extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if h.count == 6 { h = "FF" + h }
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        self.init(
            red:   CGFloat((val & 0xFF0000) >> 16) / 255,
            green: CGFloat((val & 0x00FF00) >>  8) / 255,
            blue:  CGFloat( val & 0x0000FF       ) / 255,
            alpha: CGFloat((val & 0xFF000000) >> 24) / 255
        )
    }
}

// MARK: - Spacing

enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner radius

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let pill: CGFloat = 999
}

// MARK: - Factory helpers

enum AppUI {

    // MARK: Labels

    static func label(text: String = "",
                      font: UIFont = .systemFont(ofSize: 14),
                      color: UIColor = AppColor.textPrimary,
                      lines: Int = 1) -> UILabel {
        let l             = UILabel()
        l.text            = text
        l.font            = font
        l.textColor       = color
        l.numberOfLines   = lines
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    // MARK: Buttons

    static func primaryButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor  = AppColor.accent
        b.layer.cornerRadius = Radius.md
        b.heightAnchor.constraint(equalToConstant: 54).isActive = true
        b.translatesAutoresizingMaskIntoConstraints = false
        // gradient overlay
        let grad = CAGradientLayer()
        grad.colors     = [UIColor(hex: "#7C3AED").cgColor, UIColor(hex: "#4F46E5").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.cornerRadius = Radius.md
        b.layer.insertSublayer(grad, at: 0)
        b.addTarget(b, action: #selector(UIButton.animateTap), for: .touchDown)
        return b
    }

    static func secondaryButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(AppColor.accentLight, for: .normal)
        b.titleLabel?.font   = .systemFont(ofSize: 16, weight: .medium)
        b.backgroundColor    = .clear
        b.layer.borderWidth  = 1.5
        b.layer.borderColor  = AppColor.accent.cgColor
        b.layer.cornerRadius = Radius.md
        b.heightAnchor.constraint(equalToConstant: 54).isActive = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }

    // MARK: Text fields

    static func inputField(placeholder: String,
                           keyboard: UIKeyboardType = .default) -> LoanTextField {
        let tf = LoanTextField()
        tf.placeholder       = placeholder
        tf.keyboardType      = keyboard
        tf.autocorrectionType = .no
        tf.autocapitalizationType = keyboard == .default ? .words : .none
        tf.heightAnchor.constraint(equalToConstant: 54).isActive = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }

    // MARK: Section header

    static func sectionTitle(_ text: String) -> UILabel {
        label(text: text,
              font: .systemFont(ofSize: 13, weight: .semibold),
              color: AppColor.textMuted)
    }

    // MARK: Error label

    static func errorLabel() -> UILabel {
        let l = label(text: "", font: .systemFont(ofSize: 12), color: AppColor.error)
        l.isHidden = true
        return l
    }

    // MARK: Card view

    static func card() -> UIView {
        let v = UIView()
        v.backgroundColor    = AppColor.card
        v.layer.cornerRadius = Radius.lg
        v.layer.borderWidth  = 1
        v.layer.borderColor  = AppColor.border.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: Gradient layer for buttons (resize on layout)

    static func updateGradient(in button: UIButton) {
        if let grad = button.layer.sublayers?.first as? CAGradientLayer {
            grad.frame = button.bounds
        }
    }
}

// MARK: - UIButton tap animation

extension UIButton {
    @objc func animateTap() {
        UIView.animate(withDuration: 0.12, animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.12) { self.transform = .identity }
        }
    }
}
