//
//  AuthCoordinator.swift
//  
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import RxSwift
import RxCocoa
import SmartbookCore
import UIKit

public final class AuthCoordinator: BaseCoordinator<User> {
    private let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public override func start(nextScene: SceneProtocol? = nil, animated: Bool = false) -> Driver<User> {
        startLoginScene()
    }

    private func startLoginScene() -> Driver<User> {
        coordinate(to: LoginCoordinator(navigationController: navigationController))
    }
}
