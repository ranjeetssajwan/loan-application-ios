
//
//  ApplicationsListViewController.swift
//  LoanApp
//


import UIKit

final class ApplicationsListViewController: UIViewController {

    
    private let viewModel = ApplicationsListViewModel()

 
    var onEditApplication: ((LoanApplication) -> Void)?

 
    private let tableView    = UITableView(frame: .zero, style: .plain)
    private let emptyView    = UIView()
    private let newAppButton = AppUI.primaryButton(title: "+ New Application")

    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Applications"
        setupNavBar()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadApplications()
        tableView.reloadData()
        updateEmptyState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        AppUI.updateGradient(in: newAppButton)
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
        navigationController?.navigationBar.prefersLargeTitles   = false
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = AppColor.background

        // Table
        tableView.backgroundColor    = .clear
        tableView.separatorStyle     = .none
        tableView.rowHeight          = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.dataSource         = self
        tableView.delegate           = self
        tableView.register(ApplicationListCell.self,
                           forCellReuseIdentifier: ApplicationListCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // New-app button
        newAppButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newAppButton)

        NSLayoutConstraint.activate([
            newAppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,   constant: Spacing.md),
            newAppButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.md),
            newAppButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -Spacing.md),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newAppButton.topAnchor, constant: -Spacing.sm)
        ])

        newAppButton.addTarget(self, action: #selector(startNewApplication), for: .touchUpInside)
        setupEmptyView()
    }

    // MARK: - Empty state

    private func setupEmptyView() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.isHidden = true
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emptyView.widthAnchor.constraint(equalToConstant: 260)
        ])

        let iconLbl = AppUI.label(text: "", font: .systemFont(ofSize: 52))
        iconLbl.textAlignment = .center

        let titleLbl = AppUI.label(
            text: "No Applications Yet",
            font: .systemFont(ofSize: 18, weight: .semibold))
        titleLbl.textAlignment = .center

        let subLbl = AppUI.label(
            text: "Tap \"+ New Application\" below to get started.",
            font: .systemFont(ofSize: 14),
            color: AppColor.textSecondary,
            lines: 0)
        subLbl.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [ titleLbl, subLbl])
        stack.axis      = .vertical
        stack.spacing   = Spacing.sm
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        emptyView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: emptyView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
        ])
    }

    private func updateEmptyState() {
        emptyView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
    }

    // MARK: - Navigation to Detail

    private func showDetail(for app: LoanApplication) {
        let vm = ApplicationDetailViewModel(application: app)
        let vc = ApplicationDetailViewController(viewModel: vm)
        vc.onEdit = { [weak self] application in
            self?.onEditApplication?(application)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Actions

    @objc private func startNewApplication() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ApplicationsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.applications.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ApplicationListCell.reuseID,
            for: indexPath) as! ApplicationListCell
        cell.configure(with: viewModel.cellData(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? { nil }
}

// MARK: - UITableViewDelegate

extension ApplicationsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard !viewModel.isEmpty else { return nil }
        let wrapper = UIView()
        wrapper.backgroundColor = .clear
        let count = viewModel.applications.count
        let lbl = AppUI.label(
            text: "\(count) Application\(count == 1 ? "" : "s")",
            font: .systemFont(ofSize: 13, weight: .semibold),
            color: AppColor.textMuted)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: Spacing.md),
            lbl.topAnchor.constraint(equalTo: wrapper.topAnchor,     constant: Spacing.sm),
            lbl.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -Spacing.xs)
        ])
        return wrapper
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat { 36 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let app = viewModel.application(at: indexPath.row)
        showDetail(for: app)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self else { done(false); return }
            self.viewModel.deleteApplication(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.updateEmptyState()
            done(true)
        }
        delete.image           = UIImage(systemName: "trash.fill")
        delete.backgroundColor = AppColor.error
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
