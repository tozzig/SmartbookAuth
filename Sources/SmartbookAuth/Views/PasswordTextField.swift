//
//  PasswordTextField.swift
//  
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import SmartbookCore
import UIKit
import RxCocoa
import RxSwift

final class PasswordTextField: TextField {
    private let disposeBag = DisposeBag()

    private let showPasswordButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.showPassword(), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()

    private let hidePasswordButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.hidePassword(), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rightViewWidth: CGFloat = 40.0 // Ширина контейнера правого view
        let rightViewHeight: CGFloat = 24.0 // Высота кнопок
        let rightViewPadding: CGFloat = 8.0 // Отступ справа
        let rightViewRect = CGRect(
            x: bounds.width - rightViewWidth - rightViewPadding,
            y: (bounds.height - rightViewHeight) / 2,
            width: rightViewWidth,
            height: rightViewHeight
        )
        return rightViewRect
    }
}

private extension PasswordTextField {
    func setupViews() {
        isSecureTextEntry = true
        rightViewMode = .always
        showPasswordButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        hidePasswordButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        rightView = showPasswordButton

        disposeBag.insert {
            Observable
                .merge(showPasswordButton.rx.tap.map { _ in false }, hidePasswordButton.rx.tap.map { _ in true })
                .asDriverOnErrorJustComplete()
                .drive(rx.isSecureTextEntry)
            Observable
                .merge(
                    hidePasswordButton.rx.tap.mapTo(showPasswordButton),
                    showPasswordButton.rx.tap.mapTo(hidePasswordButton)
                )
                .asDriverOnErrorJustComplete()
                .drive(rx.rightView)
        }
    }
}
