//
//  File.swift
//
//
//  Created by Anton Tsikhanau on 18.11.23.
//

import SmartbookCore
import UIKit
import RxCocoa

final class PasswordRecoveryCoordinator: BaseCoordinator<Void> {
    private let presentingViewController: UIViewController

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    override func start(nextScene: SceneProtocol? = nil, animated: Bool = true) -> Driver<Void> {
        let viewModel = PasswordRecoveryViewModel(authorizationService: AuthorizationService(networkProvider: NetworkProvider()))

        let viewController = PasswordRecoveryViewController(viewModel: viewModel)
        viewController.sheetPresentationController?.detents = [.medium()]
        viewController.sheetPresentationController?.prefersGrabberVisible = true
        presentingViewController.present(viewController, animated: true)
        viewModel.flowCompleted
            .drive(onNext: { [unowned viewController] in
                viewController.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        return viewController.rx.deallocated.asDriverOnErrorJustComplete()
    }
}
