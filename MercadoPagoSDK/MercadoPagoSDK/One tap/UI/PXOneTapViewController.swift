//
//  PXOneTapViewController.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 15/5/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit
import MercadoPagoPXTracking

final class PXOneTapViewController: PXComponentContainerViewController {
    // MARK: Tracking
    override var screenName: String { return TrackingUtil.ScreenId.REVIEW_AND_CONFIRM_ONE_TAP }
    override var screenId: String { return TrackingUtil.ScreenId.REVIEW_AND_CONFIRM_ONE_TAP }

    // MARK: Definitions
    lazy var itemViews = [UIView]()
    fileprivate var viewModel: PXOneTapViewModel
    private lazy var footerView: UIView = UIView()
    private var discountTermsConditionView: PXDiscountTermsAndConditionView?

    // MARK: Callbacks
    var callbackPaymentData: ((PaymentData) -> Void)
    var callbackConfirm: ((PaymentData) -> Void)
    var callbackExit: (() -> Void)
    var finishButtonAnimation: (() -> Void)

    var loadingButtonComponent: PXAnimatedButton?

    // MARK: Lifecycle/Publics
    init(viewModel: PXOneTapViewModel, callbackPaymentData : @escaping ((PaymentData) -> Void), callbackConfirm: @escaping ((PaymentData) -> Void), callbackExit: @escaping (() -> Void), finishButtonAnimation: @escaping (() -> Void)) {
        self.viewModel = viewModel
        self.callbackPaymentData = callbackPaymentData
        self.callbackConfirm = callbackConfirm
        self.callbackExit = callbackExit
        self.finishButtonAnimation = finishButtonAnimation
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMovingToParentViewController {
            viewModel.trackTapBackEvent()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.shouldAnimatePayButton {
            PXNotificationManager.UnsuscribeTo.animateButtonForSuccess(loadingButtonComponent)
            PXNotificationManager.UnsuscribeTo.animateButtonForError(loadingButtonComponent)
            PXNotificationManager.UnsuscribeTo.animateButtonForWarning(loadingButtonComponent)
        }
    }

    override func trackInfo() {
        self.viewModel.trackInfo()
    }

    func update(viewModel: PXOneTapViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: UI Methods.
extension PXOneTapViewController {
    private func setupNavigationBar() {
        navBarTextColor = ThemeManager.shared.labelTintColor()
        loadMPStyles()
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.whiteColor()
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.shared.labelTintColor()
    }

    private func setupUI() {
        if contentView.getSubviews().isEmpty {
            renderViews()
        }
    }

    private func renderViews() {
        contentView.prepareForRender()

        // Add item-price view.
        if let itemView = getItemComponentView() {
            contentView.addSubviewToBottom(itemView)
            PXLayout.centerHorizontally(view: itemView).isActive = true
            PXLayout.matchWidth(ofView: itemView).isActive = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.shouldOpenSummary))
            itemView.addGestureRecognizer(tapGesture)
        }

        // Add payment method.
        if let paymentMethodView = getPaymentMethodComponentView() {
            contentView.addSubviewToBottom(paymentMethodView, withMargin: PXLayout.S_MARGIN)
            PXLayout.pinLeft(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: paymentMethodView, withMargin: PXLayout.M_MARGIN).isActive = true
            let paymentMethodTapAction = UITapGestureRecognizer(target: self, action: #selector(self.shouldChangePaymentMethod))
            paymentMethodView.addGestureRecognizer(paymentMethodTapAction)
        }

        // Add discount terms and conditions.
        if self.viewModel.shouldShowDiscountTermsAndCondition() {
            let discountTCView = getDiscountTermsAndConditionView()
            discountTermsConditionView = discountTCView
            contentView.addSubviewToBottom(discountTCView, withMargin: PXLayout.S_MARGIN)
            PXLayout.matchWidth(ofView: discountTCView).isActive = true
            PXLayout.centerHorizontally(view: discountTCView).isActive = true
            discountTCView.delegate = self
        }

        // Add footer payment button.
        if let footerView = getFooterView() {
            contentView.addSubviewToBottom(footerView, withMargin: PXLayout.M_MARGIN)
            PXLayout.centerHorizontally(view: footerView).isActive = true
            PXLayout.pinLeft(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.pinRight(view: footerView, withMargin: PXLayout.M_MARGIN).isActive = true
            PXLayout.setHeight(owner: footerView, height: PXLayout.XXL_MARGIN).isActive = true
        }

        view.layoutIfNeeded()
        refreshContentViewSize()
        if centerContentView() {
            contentView.animateContentOnY()
        }
    }
}

// MARK: Components Builders.
extension PXOneTapViewController {
    private func getItemComponentView() -> UIView? {
        if let oneTapItemComponent = viewModel.getItemComponent() {
            return oneTapItemComponent.render()
        }
        return nil
    }

    private func getPaymentMethodComponentView() -> UIView? {
        if let paymentMethodComponent = viewModel.getPaymentMethodComponent() {
            return paymentMethodComponent.oneTapRender()
        }
        return nil
    }

    private func getFooterView() -> UIView? {

        loadingButtonComponent = PXAnimatedButton(frame: .zero)
        loadingButtonComponent?.animationDelegate = self
        loadingButtonComponent?.layer.cornerRadius = 4
        loadingButtonComponent?.add(for: .touchUpInside, { [weak self] in
            self?.confirmPayment()
            if self?.viewModel.shouldAnimatePayButton ?? false {
                self?.loadingButtonComponent?.startLoading(loadingText: "Pagando...", retryText: "Pagar")
            }
        })
        loadingButtonComponent?.setTitle("Pagar".localized, for: .normal)
        loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()

        if viewModel.shouldAnimatePayButton {
            PXNotificationManager.SuscribeTo.animateButtonForSuccess(loadingButtonComponent!, selector: #selector(loadingButtonComponent?.animateFinishSuccess))
            PXNotificationManager.SuscribeTo.animateButtonForError(loadingButtonComponent!, selector: #selector(loadingButtonComponent?.animateFinishError))
            PXNotificationManager.SuscribeTo.animateButtonForWarning(loadingButtonComponent!, selector: #selector(loadingButtonComponent?.animateFinishWarning))
        }

        return loadingButtonComponent
    }

    private func getDiscountDetailView() -> UIView? {
        if self.viewModel.amountHelper.discount != nil {
            let discountDetailVC = PXDiscountDetailViewController(amountHelper: self.viewModel.amountHelper, shouldShowTitle: true)
            return discountDetailVC.getContentView()
        }
        return nil
    }

    private func getDiscountTermsAndConditionView() -> PXDiscountTermsAndConditionView {
        let discountTermsAndConditionView = PXDiscountTermsAndConditionView(amountHelper: self.viewModel.amountHelper, shouldAddMargins: false)
        return discountTermsAndConditionView
    }
}

// MARK: User Actions.
extension PXOneTapViewController: PXTermsAndConditionViewDelegate {
    @objc func shouldOpenSummary() {
        viewModel.trackTapSummaryDetailEvent()
        if viewModel.shouldShowSummaryModal() {
            if let summaryProps = viewModel.getSummaryProps(), summaryProps.count > 0 {
                let summaryViewController = PXOneTapSummaryModalViewController()
                summaryViewController.setProps(summaryProps: summaryProps, bottomCustomView: getDiscountDetailView())
                PXComponentFactory.Modal.show(viewController: summaryViewController, title: "Detalle".localized)
            } else {
                if let discountView = getDiscountDetailView() {
                    let summaryViewController = PXOneTapSummaryModalViewController()
                    summaryViewController.setProps(summaryProps: nil, bottomCustomView: discountView)
                    PXComponentFactory.Modal.show(viewController: summaryViewController, title: nil)
                }
            }
        }
    }

    @objc func shouldChangePaymentMethod() {
        viewModel.trackChangePaymentMethodEvent()
        callbackPaymentData(viewModel.getClearPaymentData())
    }

    private func confirmPayment() {
        self.viewModel.trackConfirmActionEvent()
        self.hideNavBar()
        self.hideBackButton()
        self.callbackConfirm(self.viewModel.amountHelper.paymentData)
    }

    private func cancelPayment() {
        self.callbackExit()
    }

    func shouldOpenTermsCondition(_ title: String, screenName: String, url: URL) {
        let webVC = WebViewController(url: url, screenName: screenName, navigationBarTitle: title)
        webVC.title = title
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: Payment Button animation delegate
@available(iOS 9.0, *)
extension PXOneTapViewController: PXAnimatedButtonDelegate {
    func expandAnimationInProgress() {
    }

    func didFinishAnimation() {
        self.finishButtonAnimation()
    }

    func progressButtonAnimationTimeOut() {

    }
}
