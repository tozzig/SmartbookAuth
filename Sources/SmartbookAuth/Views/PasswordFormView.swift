//
//  PasswordFormView.swift
//  
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import SmartbookCore

final class PasswordFormView: FormView {

    override func createTextField() -> TextField {
        PasswordTextField()
    }
}
