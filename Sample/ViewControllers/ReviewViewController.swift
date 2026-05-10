
//
//  ReviewViewController.swift
//  LoanApp
//
 

import UIKit

final class ReviewViewController: UIViewController {
 
    private(set) var viewModel: ReviewViewModel?
 
    var onStart:         (() -> Void)?
    var onEditPersonal:  (() -> Void)?
    var onEditFinancial: (() -> Void)?
    var onSubmitted:     ((LoanApplication) -> Void)?

 
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()
    private let progressView = StepProgressView(steps: ["Personal", "Financial", "Review"])
    private let submitButton = AppUI.primaryButton(title: "Submit Application")

 
    private let emptyStateContainer = UIView()

 
    init() {
        self.viewModel = nil
        super.init(nibName: nil, bundle: nil)
    }

 
    init(viewModel: ReviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Review"
        setupNavBar()
        if viewModel != nil {
            setupUI()
            progressView.currentStep = 3
        } else {
            setupEmptyState()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewModel != nil {
            AppUI.updateGradient(in: submitButton)
        } else {
            updateEmptyStateGradient()
        }
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
        contentStack.addArrangedSubview(makeHeader())
        contentStack.setCustomSpacing(Spacing.xl, after: contentStack.arrangedSubviews.last!)

        contentStack.addArrangedSubview(
            makeSection(title: "Personal Information",
                        rows: viewModel?.personalRows ?? [],
                        editSelector: #selector(editPersonal)))
        contentStack.addArrangedSubview(
            makeSection(title: "Financial Information",
                        rows: viewModel?.financialRows ?? [],
                        editSelector: #selector(editFinancial)))
        contentStack.addArrangedSubview(makeDisclaimer())
        contentStack.setCustomSpacing(Spacing.xl, after: contentStack.arrangedSubviews.last!)
        contentStack.addArrangedSubview(submitButton)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
    }

    // MARK: - Empty State UI

    private func setupEmptyState() {
        view.backgroundColor = AppColor.background

        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateContainer)
        NSLayoutConstraint.activate([
            emptyStateContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyStateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.xl),
            emptyStateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.xl)
        ])



     
        let titleLabel = AppUI.label(
            text: "Loan Application",
            font: .systemFont(ofSize: 28, weight: .bold),
            color: AppColor.textPrimary
        )
        titleLabel.textAlignment = .center
        
       
        let subtitleLabel = AppUI.label(
            text: "Complete a quick 3-step process to review and submit your loan application.",
            font: .systemFont(ofSize: 15),
            color: AppColor.textSecondary,
            lines: 0
        )
        subtitleLabel.textAlignment = .center

   
        let stepsCard = makeStepsCard()
 
        let startButton = AppUI.primaryButton(title: "Start Application  →")
        startButton.tag = 99
        startButton.addTarget(self, action: #selector(handleStart), for: .touchUpInside)

 
        let listButton = AppUI.secondaryButton(title: "View Saved Applications")
        listButton.addTarget(self, action: #selector(showApplicationsList), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [ titleLabel, subtitleLabel, stepsCard, startButton, listButton])
        stack.axis      = .vertical
        stack.spacing   = Spacing.lg
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: emptyStateContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor)
        ])
    }

    private func makeStepsCard() -> UIView {
        let card = AppUI.card()
        let inner = UIStackView()
        inner.axis    = .vertical
        inner.spacing = Spacing.sm
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: Spacing.md),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Spacing.md),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Spacing.md),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Spacing.md)
        ])

        let steps: [(String, String)] = [
            ("1", "Personal Information – name, email, phone & gender"),
            ("2", "Financial Information – income, loan amount & IRD number"),
            ("3", "Review & Submit – confirm all details and apply")
        ]

        for (number, description) in steps {
            let row = UIStackView()
            row.axis    = .horizontal
            row.spacing = Spacing.sm
            row.alignment = .center

            let badge = UILabel()
            badge.text          = number
            badge.font          = .systemFont(ofSize: 12, weight: .bold)
            badge.textColor     = AppColor.background
            badge.backgroundColor = AppColor.accentLight
            badge.textAlignment = .center
            badge.layer.cornerRadius = 11
            badge.clipsToBounds = true
            badge.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                badge.widthAnchor.constraint(equalToConstant: 22),
                badge.heightAnchor.constraint(equalToConstant: 22)
            ])

            let desc = AppUI.label(text: description,
                                   font: .systemFont(ofSize: 13),
                                   color: AppColor.textSecondary,
                                   lines: 2)
            row.addArrangedSubview(badge)
            row.addArrangedSubview(desc)
            inner.addArrangedSubview(row)
        }
        return card
    }

 
    private func updateEmptyStateGradient() {
        if let btn = view.viewWithTag(99) as? UIButton {
            AppUI.updateGradient(in: btn)
        }
    }

 
    private func makeSection(title: String,
                              rows: [ReviewViewModel.ReviewRow],
                              editSelector: Selector) -> UIView {
        let card = AppUI.card()
        let inner = UIStackView()
        inner.axis    = .vertical
        inner.spacing = 0
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: Spacing.md),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Spacing.md),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Spacing.md),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Spacing.md)
        ])

 
        let hdr  = UIStackView()
        hdr.axis = .horizontal
        let titleLbl = AppUI.label(text: title, font: .systemFont(ofSize: 15, weight: .semibold), color: AppColor.accentLight)
        let editBtn  = UIButton(type: .system)
        editBtn.setTitle("Edit", for: .normal)
        editBtn.setTitleColor(AppColor.accentLight, for: .normal)
        editBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        editBtn.translatesAutoresizingMaskIntoConstraints = false
        editBtn.addTarget(self, action: editSelector, for: .touchUpInside)
        hdr.addArrangedSubview(titleLbl)
        hdr.addArrangedSubview(editBtn)
        inner.addArrangedSubview(hdr)

        let div = UIView()
        div.backgroundColor = AppColor.border
        div.heightAnchor.constraint(equalToConstant: 1).isActive = true
        div.translatesAutoresizingMaskIntoConstraints = false
        inner.addArrangedSubview(div)
        inner.setCustomSpacing(Spacing.sm, after: div)

        for (i, row) in rows.enumerated() {
            inner.addArrangedSubview(makeDataRow(label: row.label, value: row.value))
            if i < rows.count - 1 {
                let sep = UIView()
                sep.backgroundColor = AppColor.border.withAlphaComponent(0.4)
                sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                sep.translatesAutoresizingMaskIntoConstraints = false
                inner.addArrangedSubview(sep)
            }
        }
        return card
    }

    private func makeDataRow(label: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis      = .horizontal
        row.alignment = .top
        row.spacing   = Spacing.sm

        let lbl = AppUI.label(text: label, font: .systemFont(ofSize: 13), color: AppColor.textSecondary)
        lbl.widthAnchor.constraint(equalToConstant: 110).isActive = true
        lbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let val = AppUI.label(text: value, font: .systemFont(ofSize: 14, weight: .medium), color: AppColor.textPrimary, lines: 0)
        val.textAlignment = .right
        row.addArrangedSubview(lbl)
        row.addArrangedSubview(val)

        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: wrap.topAnchor, constant: Spacing.sm),
            row.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -Spacing.sm)
        ])
        return wrap
    }

    private func makeHeader() -> UIView {
        let s = UIStackView(); s.axis = .vertical; s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
//        s.addArrangedSubview(AppUI.label(text: "checkmark.square", font: .systemFont(ofSize: 36)))
        s.addArrangedSubview(AppUI.label(text: "Review Your Application", font: .systemFont(ofSize: 22, weight: .bold)))
        s.addArrangedSubview(AppUI.label(text: "Please verify all details before submitting.",
                                          font: .systemFont(ofSize: 14), color: AppColor.textSecondary, lines: 2))
        return s
    }

    private func makeDisclaimer() -> UIView {
        let card = AppUI.card()
        card.backgroundColor = UIColor(hex: "#1A1A2E")
        card.layer.borderColor = AppColor.warning.withAlphaComponent(0.4).cgColor
        let lbl = AppUI.label(
            text: "By submitting, you confirm all information is accurate. False information may result in rejection.",
            font: .systemFont(ofSize: 12), color: AppColor.warning, lines: 0)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: card.topAnchor, constant: Spacing.md),
            lbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Spacing.md),
            lbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Spacing.md),
            lbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Spacing.md)
        ])
        return card
    }

    // MARK: - Actions
    @objc private func handleStart()        { onStart?() }
    @objc private func editPersonal()       { onEditPersonal?() }
    @objc private func editFinancial()      { onEditFinancial?() }

    @objc private func showApplicationsList() {
        let vc = ApplicationsListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleSubmit() {
        submitButton.isEnabled = false
        guard let app = viewModel?.submit() else {
            submitButton.isEnabled = true
            showAlert(title: "Submission Failed", message: "Could not save your application. Please try again.")
            return
        }
        let alert = UIAlertController(
            title: "Application Submitted!",
            message: "Saved successfully.\n\nReference ID: \(String(app.id.uuidString.prefix(8)).uppercased())",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "View All Applications", style: .default) { [weak self] _ in
            self?.onSubmitted?(app)
        })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
