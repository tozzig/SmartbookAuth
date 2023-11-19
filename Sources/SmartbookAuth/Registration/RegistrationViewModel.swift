//
//  RegistrationViewModel.swift
//  
//
//  Created by Anton Tsikhanau on 2.08.23.
//

import RxCocoa
import SmartbookCore
import RxSwift
import Foundation
import UIKit

protocol RegistrationViewModelProtocol {
    var title: Driver<String> { get }
    var loginFormTitle: Driver<String> { get }
    var passwordFormTitle: Driver<String> { get }
    var loginValidationResult: Driver<ValidationResult> { get }
    var passwordValidationResult: Driver<ValidationResult> { get }
    var registerButtonTitle: Driver<String> { get }
    var haveAccounTitle: Driver<String> { get }
    var loginButtonTitle: Driver<String> { get }
    var privacyPolicyTitle: Driver<NSAttributedString> { get }

    var isRegisterButtonEnabled: Driver<Bool> { get }
    var error: Driver<Error> { get }
    var loginButtonTapped: Driver<Void> { get }
    var registrationSuccessMessage: Observable<(String, String)> { get }
    var registrationCompleted: Driver<Void> { get }
    var login: AnyObserver<String> { get }
    var password: AnyObserver<String> { get }
    var registerButtonTap: AnyObserver<Void> { get }
    var loginButtonTap: AnyObserver<Void> { get }
    var privacyPolicyAccepted: AnyObserver<Bool> { get }
    var registrationSuccessMessageRead: AnyObserver<Void> { get }
}

final class RegistrationViewModel {
    private let disposeBag = DisposeBag()
    private let authorizationService: AuthorizationServiceProtocol
    private let registerRequestTriggerSubject = PublishSubject<Void>()

    private let loginSubject = BehaviorSubject(value: "")
    private let passwordSubject = BehaviorSubject(value: "")
    private let loginValidator = Validators.email
    private let passwordValidator = Validators.password
    private let registerButtonTapSubject = PublishSubject<Void>()
    private let loginButtonTapSubject = PublishSubject<Void>()
    private let registrationSubject = PublishSubject<Void>()
    private let errorSubject = PublishSubject<Error>()
    private let privacyPolicySubject = BehaviorSubject(value: false)
    private let registrationSuccessMessageReadSubject = PublishSubject<Void>()

    let title = Driver.just(R.string.localizable.registration())
    let loginFormTitle = Driver.just(R.string.localizable.username())
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
    let registerButtonTitle = Driver.just(R.string.localizable.register())
    let haveAccounTitle = Driver.just(R.string.localizable.alreadyHaveAnAccount())
    let loginButtonTitle = Driver.just(R.string.localizable.signInNow())
    let privacyPolicyTitle: Driver<NSAttributedString> = {
        let privacyPolicyURL = URL(string: "https://smart-book.net/policy")
        let privacyPolicy = R.string.localizable.privacyPolicy()
        let formattedString = R.string.localizable.privacyPolicyFormat(privacyPolicy)
        let font = UIFont.systemFont(ofSize: 14)
        let attributedString = NSMutableAttributedString(
            string: formattedString,
            attributes: [
                .foregroundColor: UIColor.secondaryText as Any,
                .font: font
            ]
        )
        if let privacyPolicyRange = formattedString.range(of: privacyPolicy) {
            attributedString.setAttributes(
                [
                    .foregroundColor: UIColor.main as Any,
                    .link: privacyPolicyURL as Any,
                    .font: font
                ],
                range: NSRange(privacyPolicyRange, in: formattedString)
            )
        }
        return .just(attributedString)
    }()

    init(authorizationService: AuthorizationServiceProtocol) {
        self.authorizationService = authorizationService
        bindObservables()
    }
}

private extension RegistrationViewModel {
    func bindObservables() {
        let areCredentialsValid = Observable
            .combineLatest(loginValidation, passwordValidation)
            .map { $0.0.isValid && $0.1.isValid }
        disposeBag.insert {
            registerButtonTapSubject
                .withLatestFrom(areCredentialsValid)
                .filter { $0 }
                .withLatestFrom(Observable.combineLatest(loginSubject, passwordSubject)) { ($1.0, $1.1) }
                .withUnretained(self)
                .flatMapLatest { owner, credentials in
                    owner.authorizationService.register(email: credentials.0, password: credentials.1)
                }
                .catch { [weak self] error in
                    self?.errorSubject.onNext(error)
                    return .error(error)
                }
                .retry()
                .mapTo(())
                .bind(to: registrationSubject)
        }
    }
}

extension RegistrationViewModel: RegistrationViewModelProtocol {
    var loginValidationResult: RxCocoa.Driver<ValidationResult> {
        Observable.merge(
            registerButtonTapSubject.withLatestFrom(loginValidation),
            loginSubject.mapTo(.success)
        )
        .asDriverOnErrorJustComplete()
    }
    
    var passwordValidationResult: RxCocoa.Driver<ValidationResult> {
        Observable.merge(
            registerButtonTapSubject.withLatestFrom(passwordValidation),
            passwordSubject.mapTo(.success)
        )
        .asDriverOnErrorJustComplete()
    }

    var isRegisterButtonEnabled: Driver<Bool> {
        Observable.combineLatest(
            loginSubject,
            passwordSubject,
            privacyPolicySubject
        ) { !$0.isEmpty && !$1.isEmpty && $2 }
            .asDriver(onErrorJustReturn: false)
    }
    var error: Driver<Error> {
        errorSubject.asDriverOnErrorJustComplete()
    }
    var loginButtonTapped: Driver<Void> {
        loginButtonTapSubject.asDriverOnErrorJustComplete()
    }
    var registrationSuccessMessage: Observable<(String, String)> {
        registrationSubject.mapTo((R.string.localizable.success(), R.string.localizable.emailConfirmation()))
    }
    var registrationCompleted: Driver<Void> {
        registrationSuccessMessageReadSubject.asDriverOnErrorJustComplete()
    }
    var login: AnyObserver<String> {
        loginSubject.asObserver()
    }
    var password: AnyObserver<String> {
        passwordSubject.asObserver()
    }
    var registerButtonTap: AnyObserver<Void> {
        registerButtonTapSubject.asObserver()
    }
    var loginButtonTap: AnyObserver<Void> {
        loginButtonTapSubject.asObserver()
    }
    var privacyPolicyAccepted: AnyObserver<Bool> {
        privacyPolicySubject.asObserver()
    }
    var registrationSuccessMessageRead: AnyObserver<Void> {
        registrationSuccessMessageReadSubject.asObserver()
    }
}
