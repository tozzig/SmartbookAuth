//
//  PasswordFormView.swift
//  
//
//  Created by Anton Tsikhanau on 24.04.23.
//

import UIKit
import RxCocoa
import RxSwift
import SmartbookCore

final class PasswordFormView: UIView {
    fileprivate let label = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    fileprivate let textField = PasswordTextField()

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: label.intrinsicContentSize.height + textField.intrinsicContentSize.height + 4
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        setupConstraints()
    }
}

private extension PasswordFormView {
    func setupSubviews() {
        addSubview(label)
        addSubview(textField)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            textField.heightAnchor.constraint(equalToConstant: 44),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension Reactive where Base: PasswordFormView {
    var title: Binder<String?> {
        base.label.rx.text
    }

    var text: ControlProperty<String?> {
        base.textField.rx.text
    }
}
