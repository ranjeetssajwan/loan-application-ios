
//
//  SceneDelegate.swift
//  LoanApp


import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

 

    private var navigationController: UINavigationController!

 
    private var currentPersonalInfo:  PersonalInfo?
    private var currentFinancialInfo: FinancialInfo?

 

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let win = UIWindow(windowScene: windowScene)
        window  = win

        buildFlow()

        win.makeKeyAndVisible()

        // Animate the root in
        win.alpha = 0
        UIView.animate(withDuration: 0.35) { win.alpha = 1 }
    }

  

    private func buildFlow() {
        let reviewVC = makeEmptyReviewVC()
        navigationController = UINavigationController(rootViewController: reviewVC)
        navigationController.navigationBar.prefersLargeTitles = false
        window?.rootViewController = navigationController
    }

 

    private func makeEmptyReviewVC() -> ReviewViewController {
        let vc = ReviewViewController()   // empty / entry state
        vc.onStart = { [weak self] in
            self?.showPersonalScreen()
        }
        return vc
    }

    // MARK: - Screen 1 – Personal Info

    private func showPersonalScreen() {
        let vc = PersonalInfoViewController()

        // Pre-fill if coming back from an edit
        if let info = currentPersonalInfo {
            vc.viewModel.prefill(with: info)
            DispatchQueue.main.async { vc.viewModel.prefill(with: info) }
        }

        vc.onNext = { [weak self] personal in
            self?.currentPersonalInfo = personal
            self?.showFinancialScreen(prefill: nil)
        }

        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Screen 2 – Financial Info

    private func showFinancialScreen(prefill: FinancialInfo?) {
        let vc = FinancialInfoViewController()

        if let info = prefill ?? currentFinancialInfo {
            vc.viewModel.prefill(with: info)
        }

        vc.onNext = { [weak self] financial in
            self?.currentFinancialInfo = financial
            self?.showPopulatedReviewScreen()
        }

        vc.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Screen 3 – Populated Review

    private func showPopulatedReviewScreen() {
        guard let personal  = currentPersonalInfo,
              let financial = currentFinancialInfo else { return }

        let vm = ReviewViewModel(personal: personal, financial: financial)
        let vc = ReviewViewController(viewModel: vm)

        vc.onEditPersonal = { [weak self] in
            guard let self else { return }
            // Pop back to PersonalInfoVC on the stack
            let stack = self.navigationController.viewControllers
            if let personalVC = stack.first(where: { $0 is PersonalInfoViewController }) as? PersonalInfoViewController {
                self.navigationController.popToViewController(personalVC, animated: true)
                if let info = self.currentPersonalInfo {
                    personalVC.viewModel.prefill(with: info)
                    personalVC.syncFieldsFromViewModel()
                }
                // Rewire onNext so the flow continues from this VC
                personalVC.onNext = { [weak self] personal in
                    self?.currentPersonalInfo = personal
                    self?.showFinancialScreen(prefill: nil)
                }
            } else {
                // Fall back: push a fresh PersonalInfoVC
                self.navigationController.popToRootViewController(animated: false)
                self.showPersonalScreen()
            }
        }

        vc.onEditFinancial = { [weak self] in
            guard let self else { return }
            let stack = self.navigationController.viewControllers
            if let finVC = stack.first(where: { $0 is FinancialInfoViewController }) as? FinancialInfoViewController {
                self.navigationController.popToViewController(finVC, animated: true)
            } else {
                self.navigationController.popViewController(animated: false)
                self.showFinancialScreen(prefill: self.currentFinancialInfo)
            }
        }

        vc.onSubmitted = { [weak self] _ in
            self?.showApplicationsList()
        }

        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Applications list

    private func showApplicationsList() {
        let vc = ApplicationsListViewController()

        // When the user taps "Edit Application" in the detail screen, pop back
        // to the landing Review and restart the form with data pre-filled.
        vc.onEditApplication = { [weak self] application in
            guard let self else { return }
            // Store the existing data so the form screens can pre-fill
            self.currentPersonalInfo  = application.personal
            self.currentFinancialInfo = application.financial
            // Pop to the root landing screen, then push Personal Info
            self.navigationController.popToRootViewController(animated: false)
            self.showPersonalScreen()
        }

        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Standard scene callbacks

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
