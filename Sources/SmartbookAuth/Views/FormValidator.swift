//
//  File.swift
//  
//
//  Created by Anton Tsikhanau on 26.07.23.
//

import Foundation

enum ValidationError: LocalizedError {
    case wrongDataFormat(errorMessage: String?)

    var errorDescription: String? {
        switch self {
        case .wrongDataFormat(let errorMessage):
            return errorMessage
        }
    }
}

enum ValidationResult {
    case success
    case error(Error)

    var isValid: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }
}

protocol Validator {
    func validate(_ text: String) -> ValidationResult
}

struct RegexValidator: Validator {
    private let regexPattern: String
    private let errorMessage: String?

    init(regexPattern: String, errorMessage: String?) {
        self.regexPattern = regexPattern
        self.errorMessage = errorMessage
    }

    func validate(_ text: String) -> ValidationResult {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            return matches.count == 1 ? .success : .error(ValidationError.wrongDataFormat(errorMessage: errorMessage))
        } catch {
            return .error(ValidationError.wrongDataFormat(errorMessage: errorMessage))
        }
    }
}

enum Validators {
    static var email: Validator {
        RegexValidator(regexPattern: emailRegexPattern, errorMessage: R.string.localizable.wrongEmailFormat())
    }

    static var password: Validator {
        RegexValidator(regexPattern: passwordRegexPattern, errorMessage: R.string.localizable.wrongPasswordFormat())
    }
}

private let emailRegexPattern = "^(?:[a-z0-9!#\\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"

private let passwordRegexPattern = "^[0-9a-zA-Z]{8,}$"
