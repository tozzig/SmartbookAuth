//
//  PasswordRecoveryViewController.swift
//  
//
//  Created by Anton Tsikhanau on 18.11.23.
//

import UIKit
import SmartbookCore

final class PasswordRecoveryViewController: ViewController {
    private let viewModel: PasswordRecoveryViewModelProtocol

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var formView: FormView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var actionButton: ActionButton!

    init(viewModel: PasswordRecoveryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindObservables()
    }
}

private extension PasswordRecoveryViewController {
    func setupViews() {
        formView.keyboardType = .emailAddress
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .darkText
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryText
        descriptionLabel.numberOfLines = 0
    }

    func bindObservables() {
        disposeBag.insert {
            viewModel.title.drive(titleLabel.rx.text)
            viewModel.description.drive(descriptionLabel.rx.text)
            viewModel.formTitle.drive(formView.rx.title)
            viewModel.actionButtonTitle.drive(actionButton.rx.title())
            viewModel.isFormHidden.drive(formView.rx.isHidden)
            viewModel.emailValidationResult.drive(formView.validationResult)
            viewModel.isButtonEnabled.drive(actionButton.rx.isEnabled)
            viewModel.isLoading.map(!).drive(spinner.rx.isHidden)
            viewModel.isLoading.drive(spinner.rx.isAnimating)
            viewModel.isLoading.drive(
                titleLabel.rx.isHidden,
                descriptionLabel.rx.isHidden,
                actionButton.rx.isHidden
            )
            viewModel.error.drive(onNext: { [weak self] error in
                self?.showError(error)
            })

            actionButton.rx.tap.bind(to: viewModel.actionButtonTap)
            formView.rx.text
                .distinctUntilChanged()
                .skip(while: \.isEmpty)
                .bind(to: viewModel.email)
        }
    }
}
