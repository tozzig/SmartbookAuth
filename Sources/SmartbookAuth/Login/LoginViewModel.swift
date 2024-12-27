//
//  LoginViewModel.swift
//
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import UIKit
import RxCocoa
import RxSwift

protocol LoginViewModelProtocol {
    var title: Driver<String> { get }
    var loginFormTitle: Driver<String> { get }
    var passwordFormTitle: Driver<String> { get }
    var loginValidationResult: Driver<ValidationResult> { get }
    var passwordValidationResult: Driver<ValidationResult> { get }
    var loginButtonTitle: Driver<String> { get }
    var forgotPasswordTitle: Driver<NSAttributedString> { get }
    var dontHaveAccounTitle: Driver<String> { get }
    var registerButtonTitle: Driver<String> { get }
//
    var isLoginButtonEnabled: Driver<Bool> { get }
    var error: Driver<Error> { get }
    var registerButtonTapped: Driver<Void> { get }
    var forgotPasswordButtonTapped: Driver<Void> { get }
    var user: Driver<User> { get }
    var login: AnyObserver<String> { get }
    var password: AnyObserver<String> { get }
    var loginButtonTap: AnyObserver<Void> { get }
    var registerButtonTap: AnyObserver<Void> { get }
    var forgotPasswordButtonTap: AnyObserver<Void> { get }
}

final class LoginViewModel {
    private let disposeBag = DisposeBag()
    private let authorizationService: AuthorizationServiceProtocol
    private let loginSubject = BehaviorSubject(value: "")
    private let passwordSubject = BehaviorSubject(value: "")
    private let loginValidator = Validators.email
    private let passwordValidator = Validators.password
    private let loginButtonTapSubject = PublishSubject<Void>()
    private let registerButtonTapSubject = PublishSubject<Void>()
    private let forgotPasswordButtonTapSubject = PublishSubject<Void>()
    private let userSubject = PublishSubject<User>()
    private let errorSubject = PublishSubject<Error>()

    let title = Driver.just(R.string.localizable.login())
    let loginFormTitle = Driver.just(R.string.localizable.login())
    let passwordFormTitle = Driver.just(R.string.localizable.password())
    private lazy var loginValidation = {
        loginSubject.map { [unowned self] login in
            loginValidator.validate(login)
        }
    }()
    private lazy var passwordValidation = {
        passwordSubject.map { [unowned self] password in
            passwordValidator.validate(password)
        }
    }()
    let loginButtonTitle = Driver.just(R.string.localizable.log_in())
    let forgotPasswordTitle: Driver<NSAttributedString> = {
        let stringAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryText ?? .lightGray,
            .underlineColor: UIColor.secondaryText ?? .lightGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let string = NSAttributedString(string: R.string.localizable.forgot_your_password(), attributes: stringAttributes)
        return Driver.just(string)
    }()
    let dontHaveAccounTitle = Driver.just(R.string.localizable.no_account_yet())
    let registerButtonTitle = Driver.just(R.string.localizable.register())

    init(authorizationService: AuthorizationServiceProtocol) {
        self.authorizationService = authorizationService
        bindObservables()
    }
}

private extension LoginViewModel {
    func bindObservables() {
        let areCredentialsValid = Observable
            .combineLatest(loginValidation, passwordValidation)
            .map { $0.0.isValid && $0.1.isValid }
        disposeBag.insert {
            loginButtonTapSubject
                .withLatestFrom(areCredentialsValid)
                .filter { $0 }
                .withLatestFrom(Observable.combineLatest(loginSubject, passwordSubject)) { ($1.0, $1.1) }
                .flatMapLatest { [unowned self] login, password in
                    authorizationService.login(email: login, password: password)
                }
                .catch { [weak self] error in
                    self?.errorSubject.onNext(error)
                    return .error(error)
                }
                .retry()
                .bind(to: userSubject)
        }
    }
}

extension LoginViewModel: LoginViewModelProtocol {
    var loginValidationResult: Driver<ValidationResult> {
        Observable.merge(
            loginButtonTapSubject.withLatestFrom(loginValidation),
            loginSubject.mapTo(.success)
        )
        .asDriverOnErrorJustComplete()
    }
    var passwordValidationResult: RxCocoa.Driver<ValidationResult> {
        Observable.merge(
            loginButtonTapSubject.withLatestFrom(passwordValidation),
            passwordSubject.mapTo(.success)
        )
        .asDriverOnErrorJustComplete()
    }
    
    var isLoginButtonEnabled: Driver<Bool> {
        Observable
            .combineLatest(loginSubject, passwordSubject) { !$0.isEmpty && !$1.isEmpty }
            .asDriverOnErrorJustComplete()
    }
    var error: Driver<Error> {
        errorSubject.asDriverOnErrorJustComplete()
    }

    var registerButtonTapped: Driver<Void> {
        registerButtonTapSubject.asDriverOnErrorJustComplete()
    }
    var forgotPasswordButtonTapped: Driver<Void> {
        forgotPasswordButtonTapSubject.asDriverOnErrorJustComplete()
    }

    var user: Driver<User> {
        userSubject.asDriverOnErrorJustComplete()
    }
    var login: AnyObserver<String> {
        loginSubject.asObserver()
    }
    var password: AnyObserver<String> {
        passwordSubject.asObserver()
    }
    var loginButtonTap: AnyObserver<Void> {
        loginButtonTapSubject.asObserver()
    }
    var registerButtonTap: AnyObserver<Void> {
        registerButtonTapSubject.asObserver()
    }
    var forgotPasswordButtonTap: AnyObserver<Void> {
        forgotPasswordButtonTapSubject.asObserver()
    }
}
