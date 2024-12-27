//
//  FormView.swift
//
//
//  Created by Anton Tsikhanau on 23.04.23.
//

import UIKit
import RxCocoa
import RxSwift
import SmartbookCore

class FormView: UIView {

    fileprivate let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryText
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    fileprivate lazy var textField = createTextField()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private let disposeBag = DisposeBag()

    private let validationResultSubject = PublishSubject<ValidationResult>()

    var validationResult: AnyObserver<ValidationResult> {
        validationResultSubject.asObserver()
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }

    var keyboardType: UIKeyboardType {
        get {
            textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get {
            textField.autocorrectionType
        }
        set {
            textField.autocorrectionType = newValue
        }
    }

    var text: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var errorText: String? {
        get {
            errorLabel.text
        }
        set {
            errorLabel.text = newValue
            errorLabel.isHidden = newValue == nil
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        var contentHeight = label.intrinsicContentSize.height + textField.intrinsicContentSize.height + 4
        if !errorLabel.isHidden {
            contentHeight += errorLabel.intrinsicContentSize.height + 4
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
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

    func createTextField() -> TextField {
        TextField()
    }
}

private extension FormView {
    func setupSubviews() {
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(errorLabel)
        errorLabel.isHidden = true
        addSubview(stackView)

        disposeBag.insert {
            validationResultSubject
                .asDriver(onErrorJustReturn: .success)
                .drive(onNext: applyValidationResult)
        }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func applyValidationResult(_ result: ValidationResult) {
        switch result {
        case .success:
            textField.layer.borderColor = UIColor.lightGray.cgColor
            errorText = nil
        case .error(let error):
            textField.layer.borderColor = UIColor.red.cgColor
            errorText = error.localizedDescription
        }
    }
}

extension Reactive where Base: FormView {
    var title: Binder<String?> {
        base.label.rx.text
    }
    
    var text: ControlProperty<String> {
        base.textField.rx.text.orEmpty
    }
}
