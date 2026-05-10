
//
//  ApplicationDetailViewController.swift
//  LoanApp


import UIKit

final class ApplicationDetailViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel: ApplicationDetailViewModel

    // MARK: - Callback

    
    var onEdit: ((LoanApplication) -> Void)?

    // MARK: - Subviews

    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let editButton   = AppUI.primaryButton(title: "Edit Application")

    // MARK: - Init

    init(viewModel: ApplicationDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Application Details"
        setupNavBar()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        AppUI.updateGradient(in: editButton)
    }

    // MARK: - Nav bar

    private func setupNavBar() {
        let a = UINavigationBarAppearance()
        a.configureWithOpaqueBackground()
        a.backgroundColor = AppColor.surface
        a.titleTextAttributes = [.foregroundColor: UIColor.white,
                                  .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
        a.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance   = a
        navigationController?.navigationBar.scrollEdgeAppearance = a
        navigationController?.navigationBar.tintColor            = AppColor.accentLight
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = AppColor.background

        // ── Scroll ─────────────────────────────────────────────────────────
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // ── Edit button (fixed at bottom) ──────────────────────────────────
        editButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editButton)
        editButton.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)

        NSLayoutConstraint.activate([
            editButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,  constant: Spacing.md),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.md),
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Spacing.md),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: editButton.topAnchor, constant: -Spacing.sm)
        ])

        // ── Content stack ──────────────────────────────────────────────────
        contentStack.axis    = .vertical
        contentStack.spacing = Spacing.md
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor,    constant: Spacing.lg),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,  constant: Spacing.md),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Spacing.md),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,  constant: -Spacing.xl),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Spacing.md * 2)
        ])

        buildContent()
    }

    private func buildContent() {
        
        contentStack.addArrangedSubview(makeHeroCard())
        contentStack.setCustomSpacing(Spacing.xl, after: contentStack.arrangedSubviews.last!)


        contentStack.addArrangedSubview(makeEligibilityCard())
        contentStack.setCustomSpacing(Spacing.xl, after: contentStack.arrangedSubviews.last!)


        contentStack.addArrangedSubview(
            makeSection(icon: "", title: "Personal Information",
                        rows: viewModel.personalRows))
        contentStack.addArrangedSubview(
            makeSection(icon: "", title: "Financial Information",
                        rows: viewModel.financialRows))
        contentStack.addArrangedSubview(
            makeSection(icon: "", title: "Application Information",
                        rows: viewModel.applicationRows))
    }

    // MARK: - Hero card

    private func makeHeroCard() -> UIView {
        let card  = AppUI.card()
        card.backgroundColor = AppColor.surface

        let initials = UILabel()
        initials.font          = .systemFont(ofSize: 28, weight: .bold)
        initials.textColor     = AppColor.accentLight
        initials.textAlignment = .center
        initials.text          = makeInitials(viewModel.application.personal.fullName)
        initials.translatesAutoresizingMaskIntoConstraints = false

        let avatarBg = UIView()
        avatarBg.backgroundColor    = AppColor.accent.withAlphaComponent(0.2)
        avatarBg.layer.cornerRadius = 36
        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.widthAnchor.constraint(equalToConstant: 72).isActive  = true
        avatarBg.heightAnchor.constraint(equalToConstant: 72).isActive = true
        avatarBg.addSubview(initials)
        NSLayoutConstraint.activate([
            initials.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            initials.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor)
        ])

        let nameLbl = AppUI.label(
            text: viewModel.application.personal.fullName,
            font: .systemFont(ofSize: 20, weight: .bold))
        let emailLbl = AppUI.label(
            text: viewModel.application.personal.email,
            font: .systemFont(ofSize: 13),
            color: AppColor.textSecondary)

        // Status pill
        let statusPill = UILabel()
        statusPill.text              = "  Submitted  "
        statusPill.font              = .systemFont(ofSize: 11, weight: .bold)
        statusPill.textColor         = AppColor.success
        statusPill.backgroundColor   = AppColor.success.withAlphaComponent(0.15)
        statusPill.layer.cornerRadius = 6
        statusPill.clipsToBounds     = true
        statusPill.translatesAutoresizingMaskIntoConstraints = false

        let idLbl = AppUI.label(
            text: "ID: " + String(viewModel.application.id.uuidString.prefix(8)).uppercased(),
            font: .systemFont(ofSize: 11, weight: .medium),
            color: AppColor.textMuted)

        let textStack = UIStackView(arrangedSubviews: [nameLbl, emailLbl, statusPill, idLbl])
        textStack.axis    = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let row       = UIStackView(arrangedSubviews: [avatarBg, textStack])
        row.axis      = .horizontal
        row.spacing   = Spacing.md
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor,      constant: Spacing.md),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor,  constant: Spacing.md),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Spacing.md),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor,  constant: -Spacing.md)
        ])
        return card
    }

    // MARK: - Eligibility bar

    private func makeEligibilityCard() -> UIView {
        let card  = AppUI.card()

        let titleLbl = AppUI.label(
            text: "Loan Eligibility",
            font: .systemFont(ofSize: 13, weight: .semibold),
            color: AppColor.textSecondary)

        let bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.setProgress(viewModel.loanRatioFraction, animated: false)
        bar.progressTintColor = viewModel.eligibilityColor
        bar.trackTintColor    = AppColor.border
        bar.layer.cornerRadius = 3
        bar.clipsToBounds     = true
        bar.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let statusLbl = AppUI.label(
            text: viewModel.eligibilityText,
            font: .systemFont(ofSize: 13, weight: .semibold),
            color: viewModel.eligibilityColor)

        let pctLbl = AppUI.label(
            text: String(format: "%.1f%% of annual income", viewModel.application.loanToIncomeRatio * 100),
            font: .systemFont(ofSize: 12),
            color: AppColor.textMuted)

        let statusRow = UIStackView(arrangedSubviews: [statusLbl, pctLbl])
        statusRow.axis      = .horizontal
        statusRow.spacing   = Spacing.sm
        statusRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLbl, bar, statusRow])
        stack.axis    = .vertical
        stack.spacing = Spacing.sm
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor,      constant: Spacing.md),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor,  constant: Spacing.md),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Spacing.md),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor,  constant: -Spacing.md)
        ])
        return card
    }

    // MARK: - Section card builder

    private func makeSection(icon: String,
                             title: String,
                             rows: [ApplicationDetailViewModel.DetailRow]) -> UIView {
        let card  = AppUI.card()
        let inner = UIStackView()
        inner.axis    = .vertical
        inner.spacing = 0
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor,      constant: Spacing.md),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor,  constant: Spacing.md),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Spacing.md),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor,  constant: -Spacing.md)
        ])

        // Header
        let hdrLbl = AppUI.label(
            text: icon + "  " + title,
            font: .systemFont(ofSize: 15, weight: .semibold),
            color: AppColor.accentLight)
        inner.addArrangedSubview(hdrLbl)

        let divider = UIView()
        divider.backgroundColor = AppColor.border
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.translatesAutoresizingMaskIntoConstraints = false
        inner.addArrangedSubview(divider)
        inner.setCustomSpacing(Spacing.sm, after: hdrLbl)
        inner.setCustomSpacing(Spacing.sm, after: divider)

        // Rows
        for (i, row) in rows.enumerated() {
            inner.addArrangedSubview(makeDataRow(label: row.label,
                                                 value: row.value,
                                                 valueColor: row.valueColor))
            if i < rows.count - 1 {
                let sep = UIView()
                sep.backgroundColor = AppColor.border.withAlphaComponent(0.35)
                sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                sep.translatesAutoresizingMaskIntoConstraints = false
                inner.addArrangedSubview(sep)
            }
        }
        return card
    }

    private func makeDataRow(label: String,
                             value: String,
                             valueColor: UIColor) -> UIView {
        let row       = UIStackView()
        row.axis      = .horizontal
        row.alignment = .top
        row.spacing   = Spacing.sm

        let lbl = AppUI.label(text: label,
                              font: .systemFont(ofSize: 12),
                              color: AppColor.textSecondary)
        lbl.widthAnchor.constraint(equalToConstant: 116).isActive = true
        lbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let val = AppUI.label(text: value,
                              font: .systemFont(ofSize: 13, weight: .medium),
                              color: valueColor,
                              lines: 0)
        val.textAlignment = .right

        row.addArrangedSubview(lbl)
        row.addArrangedSubview(val)

        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: wrap.topAnchor,      constant: Spacing.sm),
            row.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -Spacing.sm)
        ])
        return wrap
    }

    // MARK: - Helpers

    private func makeInitials(_ name: String) -> String {
        let parts   = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map { String($0).uppercased() } }
        return letters.joined()
    }

    // MARK: - Actions

    @objc private func handleEdit() {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "Edit Application is currently under development and will be available in a future update.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
