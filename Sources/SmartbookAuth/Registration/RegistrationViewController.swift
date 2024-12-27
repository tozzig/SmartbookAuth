//
//  RegistrationViewController.swift
//  
//
//  Created by Anton Tsikhanau on 2.08.23.
//

import SmartbookCore
import UIKit
import RxSwift

class RegistrationViewController: ViewController {
    private let viewModel: RegistrationViewModelProtocol

    @IBOutlet private weak var loginFormView: FormView!
    @IBOutlet private weak var passwordFormView: PasswordFormView!
    @IBOutlet private weak var actionButton: ActionButton!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var haveAccountLabel: UILabel!
    @IBOutlet private weak var privacyPolicySwitch: UISwitch!
    @IBOutlet private weak var privacyPolicyTextView: UITextView!

    init(viewModel: RegistrationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindObservables()
    }
}

private extension RegistrationViewController {
    func setupViews() {
        loginFormView.keyboardType = .emailAddress
        haveAccountLabel.textColor = .darkText
        haveAccountLabel.font = .systemFont(ofSize: 14)
        loginButton.setTitleColor(.main, for: [])
        loginButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        privacyPolicySwitch.isOn = false
        privacyPolicySwitch.onTintColor = .main

        privacyPolicyTextView.textAlignment = .center
        privacyPolicyTextView.isEditable = false
        privacyPolicyTextView.isScrollEnabled = false
        privacyPolicyTextView.clipsToBounds = false
        privacyPolicyTextView.font = .preferredFont(forTextStyle: .caption1)
        privacyPolicyTextView.linkTextAttributes = [:]
        privacyPolicyTextView.adjustsFontForContentSizeCategory = true
        privacyPolicyTextView.translatesAutoresizingMaskIntoConstraints = false

        #if DEBUG
//        loginFormView.text = "tozzig1408@gmail.com"
//        passwordFormView.text = "12345678"
        #endif
    }

    func bindObservables() {
        disposeBag.insert {
            viewModel.loginFormTitle.drive(loginFormView.rx.title)
            viewModel.passwordFormTitle.drive(passwordFormView.rx.title)
            viewModel.title.drive(rx.title)
            viewModel.isRegisterButtonEnabled.drive(actionButton.rx.isEnabled)
            viewModel.registerButtonTitle.drive(actionButton.rx.title())
            viewModel.loginValidationResult.drive(loginFormView.validationResult)
            viewModel.passwordValidationResult.drive(passwordFormView.validationResult)
            viewModel.haveAccounTitle.drive(haveAccountLabel.rx.text)
            viewModel.loginButtonTitle.drive(loginButton.rx.title())
            viewModel.error.drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            viewModel.privacyPolicyTitle.drive(privacyPolicyTextView.rx.attributedText)
            viewModel.registrationSuccessMessage
                .observe(on: MainScheduler.asyncInstance)
                .compactMap { [weak self] title, message in
                    self?.showAlert(title: title, message: message, actionTitle: "OK")
                }
                .flatMap { $0.rx.deallocated }
                .bind(to: viewModel.registrationSuccessMessageRead)

            loginFormView.rx.text
                .distinctUntilChanged()
                .skip(while: \.isEmpty)
                .bind(to: viewModel.login)
            passwordFormView.rx.text
                .distinctUntilChanged()
                .skip(while: \.isEmpty)
                .bind(to: viewModel.password)
            actionButton.rx.tap.bind(to: viewModel.registerButtonTap)
            loginButton.rx.tap.bind(to: viewModel.loginButtonTap)
            privacyPolicySwitch.rx.isOn.bind(to: viewModel.privacyPolicyAccepted)
        }
    }
}
