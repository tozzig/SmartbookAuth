//
//  LoginViewController.swift
//
//
//  Created by Anton Tsikhanau on 23.04.23.
//

import UIKit
import RxCocoa
import RxSwift
import SmartbookCore

final class LoginViewController: ViewController {
    private let viewModel: LoginViewModelProtocol

    @IBOutlet private weak var loginFormView: FormView!
    @IBOutlet private weak var passwordFormView: PasswordFormView!
    @IBOutlet private weak var actionButton: ActionButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var dontHaveAccountLabel: UILabel!

    init(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .module)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindObservables()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LoginViewController {
    func setupViews() {
        loginFormView.keyboardType = .emailAddress
        dontHaveAccountLabel.textColor = .darkText
        dontHaveAccountLabel.font = .systemFont(ofSize: 14)
        registerButton.setTitleColor(.main, for: [])
        registerButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    }

    func bindObservables() {
        disposeBag.insert {
            viewModel.loginFormTitle.drive(loginFormView.rx.title)
            viewModel.passwordFormTitle.drive(passwordFormView.rx.title)
            viewModel.title.drive(rx.title)
            viewModel.isLoginButtonEnabled.drive(actionButton.rx.isEnabled)
            viewModel.loginButtonTitle.drive(actionButton.rx.title())
            viewModel.loginValidationResult.drive(loginFormView.validationResult)
            viewModel.passwordValidationResult.drive(passwordFormView.validationResult)
            viewModel.forgotPasswordTitle.drive(forgotPasswordButton.rx.attributedTitle())
            viewModel.dontHaveAccounTitle.drive(dontHaveAccountLabel.rx.text)
            viewModel.registerButtonTitle.drive(registerButton.rx.title())
            viewModel.error.drive(onNext: { [weak self] error in
                self?.showError(error)
            })

            loginFormView.rx.text
                .distinctUntilChanged()
                .skip(while: \.isEmpty)
                .bind(to: viewModel.login)
            passwordFormView.rx.text
                .distinctUntilChanged()
                .skip(while: \.isEmpty)
                .bind(to: viewModel.password)
            actionButton.rx.tap.bind(to: viewModel.loginButtonTap)
            registerButton.rx.tap.bind(to: viewModel.registerButtonTap)
            forgotPasswordButton.rx.tap.bind(to: viewModel.forgotPasswordButtonTap)
        }
    }
}
