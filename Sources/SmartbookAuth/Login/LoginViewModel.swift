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
    let loginFormTitle = Driver.just(R.string.localizable.username())
    let passwordFormTitle = Driver.just(R.string.localizable.password())
    private(set) lazy var loginValidationResult = {
        loginSubject
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { [unowned self] login in
                loginValidator.validate(login)
            }
            .asDriver(onErrorJustReturn: .success)
    }()
    private(set) lazy var passwordValidationResult = {
        passwordSubject
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { [unowned self] password in
                passwordValidator.validate(password)
            }
            .asDriver(onErrorJustReturn: .success)
    }()
    let loginButtonTitle = Driver.just(R.string.localizable.signIn())
    let forgotPasswordTitle: Driver<NSAttributedString> = {
        let stringAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryText ?? .lightGray,
            .underlineColor: UIColor.secondaryText ?? .lightGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let string = NSAttributedString(string: R.string.localizable.forgotPassword(), attributes: stringAttributes)
        return Driver.just(string)
    }()
    let dontHaveAccounTitle = Driver.just(R.string.localizable.dontHaveAccountYet())
    let registerButtonTitle = Driver.just(R.string.localizable.registerNow())

    init(authorizationService: AuthorizationServiceProtocol) {
        self.authorizationService = authorizationService
        bindObservables()
    }
}

private extension LoginViewModel {
    func bindObservables() {
        disposeBag.insert {
            loginButtonTapSubject
                .withLatestFrom(Observable.combineLatest(loginSubject, passwordSubject)) { ($1.0, $1.1) }
                .flatMapLatest { [unowned self] login, password in
                    authorizationService.login(email: login, password: password)
                }
                .catch { [weak self] error in
                    self?.errorSubject.onNext(error)
                    return .error(error)
                }
                .retry()
                .subscribe(onNext: { user in
                    print(user)
                })
        }
    }
}

extension LoginViewModel: LoginViewModelProtocol {
    var isLoginButtonEnabled: Driver<Bool> {
        .combineLatest(loginValidationResult, passwordValidationResult) { $0.isValid && $1.isValid }.startWith(false)
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
