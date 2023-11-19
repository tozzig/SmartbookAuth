//
//  AuthorizationService.swift
//  
//
//  Created by Anton Tsikhanau on 25.07.23.
//

import Foundation
import RxSwift
import SmartbookCore
import Alamofire

protocol AuthorizationServiceProtocol {
    func getUser(email: String) -> Single<User>
    func login(email: String, password: String) -> Single<User>
    func register(email: String, password: String) -> Single<RegistrationResponse>
    func forgotPassword(email: String) -> Single<Empty>
}

enum AuthorizationError: Int, LocalizedError {
    case userAlreadyExists = 401
    case wrongPassword = 403
    case userNotFound = 404
    case emailNotVerified = -999

    var errorDescription: String? {
        switch self {
        case .userAlreadyExists:
            return R.string.localizable.userAlreadyExists()
        case .wrongPassword:
            return R.string.localizable.wrongPassword()
        case .userNotFound:
            return R.string.localizable.userNotFound()
        case .emailNotVerified:
            return R.string.localizable.emailNotVerified()
        }
    }
}

final class AuthorizationService: NetworkService<AuthorizationAPI> {
    override func request<T: Decodable>(_ request: AuthorizationAPI) -> Single<T> {
        super.request(request).filterAuthErrors()
    }
}

extension AuthorizationService: AuthorizationServiceProtocol {
    func getUser(email: String) -> Single<User> {
        request(.getUser(email: email))
    }

    func login(email: String, password: String) -> Single<User> {
        request(.login(email: email, password: password)).flatMap { response in
            guard let user = User(registrationResponse: response) else {
                return .error(AuthorizationError.emailNotVerified)
            }
            return .just(user)
        }
    }

    func register(email: String, password: String) -> Single<RegistrationResponse> {
        request(.register(email: email, password: password))
    }

    func forgotPassword(email: String) -> Single<Empty> {
        request(.resetPassword(email: email))
    }
}

private extension PrimitiveSequence {
    func filterAuthErrors() -> Self {
        self.catch { error in
            guard
                let afError = error as? AFError,
                case .responseValidationFailed(reason: .unacceptableStatusCode(code: let code)) = afError,
                let authError = AuthorizationError(rawValue: code)
            else {
                throw error
            }
            throw authError
        }
    }
}
