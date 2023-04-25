//
//  LoginCoordinator.swift
//  
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import SmartbookCore
import RxCocoa
import UIKit

final class LoginCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start(nextScene: SceneProtocol? = nil, animated: Bool = true) -> Driver<Void> {
        let viewModel = LoginViewModel()
        let viewController = LoginViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        return viewController.view.rx.deallocated.asDriverOnErrorJustComplete()
    }
}
