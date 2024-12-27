//
//  AuthorizationAPI.swift
//
//
//  Created by Anton Tsikhanau on 23.04.23.
//

import Foundation
import CryptoKit
import SmartbookCore
import Alamofire

enum AuthorizationAPI {
    case getUser(email: String)
    case login(email: String, password: String)
    case register(email: String, password: String)
    case google(token: String, installDate: String?)
    case confirmation(token: String, installDate: String?)
    case sendConfirmation(email: String)
    case resetPassword(email: String)
}

private enum ParametersKeys: String {
    case email
    case password
    case token
    case installDate = "install_date"
}
private typealias Params = [ParametersKeys: Any]

extension AuthorizationAPI: RequestProtocol {
    var baseURL: URL {
        URL(string: "https://smart-book.net/")!
    }

    var path: String {
        switch self {
        case .getUser:
            return "user"
        case .login:
            return "user/login"
        case .register:
            return "user/registration"
        case .google:
            return "user/google"
        case .confirmation, .sendConfirmation:
            return "user/confirmation"
        case .resetPassword:
            return "user/password/reset"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUser, .google, .confirmation, .sendConfirmation, .resetPassword:
            return .get
        case .login, .register:
            return .post
        }
    }

    var headers: HTTPHeaders? {
        return [HTTPHeader(name: "P", value: "i")]
    }

    var parameters: Parameters? {
        var params = Params()
        switch self {
        case let .getUser(email), let .sendConfirmation(email), let .resetPassword(email):
            params[.email] = email
        case let .register(email, password), let .login(email, password):
            params[.email] = email
            params[.password] = password.encryptedPassword
        case let .google(token, installDate), let .confirmation(token, installDate):
            params[.token] = token
            params[.installDate] = installDate
        }
        return params.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }
    }

    var paramsEncoding: ParameterEncoding {
        switch self {
        case .getUser, .google, .confirmation, .sendConfirmation, .resetPassword:
            return URLEncoding.default
        case .login, .register:
            return JSONEncoding.default
        }
    }
}

private extension String {

    var encryptedPassword: String {
        ("android" + self).md5
    }

    private var md5: String {
        let digest = Insecure.MD5.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
