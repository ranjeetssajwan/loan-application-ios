
//
//  ApplicationListCell.swift
//  LoanApp
 

import UIKit

final class ApplicationListCell: UITableViewCell {

    static let reuseID = "ApplicationListCell"

 

    private let card        = AppUI.card()
    private let initials    = UILabel()
    private let nameLabel   = AppUI.label(font: .systemFont(ofSize: 16, weight: .semibold))
    private let amountLabel = AppUI.label(font: .systemFont(ofSize: 20, weight: .bold),
                                          color: AppColor.accentLight)
    private let incomeLabel = AppUI.label(font: .systemFont(ofSize: 12),
                                          color: AppColor.textSecondary)
    private let dateLabel   = AppUI.label(font: .systemFont(ofSize: 12),
                                          color: AppColor.textMuted)
    private let statusBadge = UILabel()
    private let chevron     = UIImageView(image: UIImage(systemName: "chevron.right"))

    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    

    private func setupLayout() {
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.xs),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.md),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.md),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.xs)
        ])

        
        let avatar = UIView()
        avatar.backgroundColor    = AppColor.accent.withAlphaComponent(0.2)
        avatar.layer.cornerRadius = 24
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.widthAnchor.constraint(equalToConstant: 48).isActive  = true
        avatar.heightAnchor.constraint(equalToConstant: 48).isActive = true

        initials.font          = .systemFont(ofSize: 17, weight: .bold)
        initials.textColor     = AppColor.accentLight
        initials.textAlignment = .center
        initials.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(initials)
        NSLayoutConstraint.activate([
            initials.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            initials.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
        ])


        statusBadge.font              = .systemFont(ofSize: 10, weight: .bold)
        statusBadge.layer.cornerRadius = 4
        statusBadge.clipsToBounds     = true
        statusBadge.textAlignment     = .center
        statusBadge.translatesAutoresizingMaskIntoConstraints = false

        
        chevron.tintColor   = AppColor.textMuted
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true

        // ── Text column ────────────────────────────────────────────────────
        
        let loanTag = AppUI.label(text: "Loan", font: .systemFont(ofSize: 10, weight: .medium),
                                  color: AppColor.textMuted)
        let incomeTag = AppUI.label(text: "Income", font: .systemFont(ofSize: 10, weight: .medium),
                                    color: AppColor.textMuted)

        let loanCol   = UIStackView(arrangedSubviews: [loanTag,   amountLabel])
        let incomeCol = UIStackView(arrangedSubviews: [incomeTag, incomeLabel])
        [loanCol, incomeCol].forEach {
            $0.axis    = .vertical
            $0.spacing = 1
        }

        let amountsRow       = UIStackView(arrangedSubviews: [loanCol, incomeCol])
        amountsRow.axis      = .horizontal
        amountsRow.spacing   = Spacing.md
        amountsRow.alignment = .leading

        let textCol   = UIStackView(arrangedSubviews: [nameLabel, amountsRow, dateLabel])
        textCol.axis    = .vertical
        textCol.spacing = 3
        textCol.translatesAutoresizingMaskIntoConstraints = false

        
        let rightCol = UIStackView(arrangedSubviews: [statusBadge, chevron])
        rightCol.axis      = .vertical
        rightCol.alignment = .trailing
        rightCol.spacing   = Spacing.xs
        rightCol.translatesAutoresizingMaskIntoConstraints = false

        
        let row       = UIStackView(arrangedSubviews: [avatar, textCol, rightCol])
        row.axis      = .horizontal
        row.alignment = .center
        row.spacing   = Spacing.md
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: Spacing.md),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Spacing.md),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Spacing.md),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Spacing.md)
        ])
    }

    // MARK: - Configure

    func configure(with data: ApplicationsListViewModel.CellData) {
        nameLabel.text   = data.applicantName
        amountLabel.text = data.loanAmount
        incomeLabel.text = data.annualIncome
        dateLabel.text   = "📅 " + data.submittedDate
        initials.text    = makeInitials(data.applicantName)

        if data.isEligible {
            statusBadge.text            = "  ✓ Eligible  "
            statusBadge.textColor       = AppColor.success
            statusBadge.backgroundColor = AppColor.success.withAlphaComponent(0.15)
        } else {
            statusBadge.text            = "  ✗ Over Limit  "
            statusBadge.textColor       = AppColor.error
            statusBadge.backgroundColor = AppColor.error.withAlphaComponent(0.15)
        }
    }

    private func makeInitials(_ name: String) -> String {
        let parts   = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map { String($0).uppercased() } }
        return letters.joined()
    }

    // MARK: - Highlight

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.card.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            self.card.alpha = highlighted ? 0.85 : 1
        }
    }
}
