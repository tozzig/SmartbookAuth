//
//  RegistrationCoordinator.swift
//  
//
//  Created by Anton Tsikhanau on 2.08.23.
//

import SmartbookCore
import RxCocoa
import UIKit

final class RegistrationCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start(nextScene: SceneProtocol? = nil, animated: Bool = true) -> Driver<Void> {
        let viewModel = RegistrationViewModel(authorizationService: AuthorizationService(networkProvider: NetworkProvider()))
        let viewController = RegistrationViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        viewModel.loginButtonTapped
            .drive(onNext: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        return Driver.merge(
            viewModel.registrationCompleted.do(onNext: {[weak self] in
                self?.navigationController.popViewController(animated: true)
            }),
            viewController.rx.deallocated.asDriverOnErrorJustComplete()
        )
    }
}
