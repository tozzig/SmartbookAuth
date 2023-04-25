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

final public class LoginViewController: ViewController {

    private let viewModel: LoginViewModelProtocol

    @IBOutlet private weak var loginFormView: FormView!
    @IBOutlet private weak var passwordFormView: PasswordFormView!
    @IBOutlet private weak var actionButton: ActionButton!

    public override func viewDidLoad() {
        super.viewDidLoad()

        disposeBag.insert {
            Driver.just("Логин").drive(loginFormView.rx.title)
            Driver.just("Пароль").drive(passwordFormView.rx.title)
            Observable
                .combineLatest(
                    loginFormView.rx.text.map { $0?.isEmpty == false },
                    passwordFormView.rx.text.map { $0?.isEmpty == false }
                ) { $0 && $1 }
                .asDriverOnErrorJustComplete()
                .drive(actionButton.rx.isEnabled)
        }
    }

    init(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nib: R.nib.loginViewController)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

