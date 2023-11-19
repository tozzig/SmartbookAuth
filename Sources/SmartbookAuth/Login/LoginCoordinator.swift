//
//  LoginCoordinator.swift
//
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import SmartbookCore
import RxCocoa
import UIKit

final class LoginCoordinator: BaseCoordinator<User> {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start(nextScene: SceneProtocol? = nil, animated: Bool = true) -> Driver<User> {
        let viewModel = LoginViewModel(authorizationService: AuthorizationService(networkProvider: NetworkProvider()))
        let viewController = LoginViewController(viewModel: viewModel)
        disposeBag.insert {
            viewModel.registerButtonTapped
                .flatMapLatest { [unowned self] in
                    startRegistrationScene()
                }
                .drive()
            viewModel.forgotPasswordButtonTapped
                .flatMapLatest { [unowned self] in
                    startPasswordRecoveryScene(from: viewController)
                }
                .drive()
        }
        navigationController.pushViewController(viewController, animated: true)
        return viewModel.user
    }

    private func startRegistrationScene() -> Driver<Void> {
        coordinate(to: RegistrationCoordinator(navigationController: navigationController))
    }

    private func startPasswordRecoveryScene(from viewController: UIViewController) -> Driver<Void> {
        coordinate(to: PasswordRecoveryCoordinator(presentingViewController: viewController))
    }
}
