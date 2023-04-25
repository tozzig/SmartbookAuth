//
//  LoginViewModel.swift
//  
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import RxCocoa
import RxSwift

protocol LoginViewModelProtocol {
    var title: Driver<String> { get }
    var loginFormTitle: Driver<String> { get }
    var passwordFormTitle: Driver<String> { get }
}

final class LoginViewModel: LoginViewModelProtocol {
    let title = Driver.just(R.string.localizable.login())
    let loginFormTitle = Driver.just(R.string.localizable.username())
    let passwordFormTitle = Driver.just(R.string.localizable.password())
}
