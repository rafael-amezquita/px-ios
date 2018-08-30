//
//  AvailableCardsViewController.swift
//  Pods
//
//  Created by Angie Arlanti on 8/28/17.
//
//

import UIKit

@objcMembers
internal class AvailableCardsViewController: MercadoPagoUIViewController {

    let buttonFontSize: CGFloat = 18

    @IBOutlet weak var retryButton: UIButton!
    override open var screenName: String { return "AVAILABLE_CARDS_DETAIL" }
    var availableCardsDetailView: AvailableCardsDetailView!
    var viewModel: AvailableCardsViewModel!

    init(paymentMethods: [PXPaymentMethod], callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "AvailableCardsViewController", bundle: ResourceManager.shared.getBundle())
        self.callbackCancel = callbackCancel
        self.viewModel = AvailableCardsViewModel(paymentMethods: paymentMethods)
    }

    init(viewModel: AvailableCardsViewModel, callbackCancel: (() -> Void)? = nil) {
        super.init(nibName: "AvailableCardsViewController", bundle: ResourceManager.shared.getBundle())
        self.callbackCancel = callbackCancel
        self.viewModel = viewModel
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ThemeManager.shared.modalComponent().backgroundColor

        self.availableCardsDetailView = AvailableCardsDetailView(frame: self.viewModel.getDatailViewFrame(), paymentMethods: self.viewModel.paymentMethods)
        self.availableCardsDetailView.layer.cornerRadius = 4
        self.availableCardsDetailView.layer.masksToBounds = true
        self.view.addSubview(self.availableCardsDetailView)

        self.retryButton.setTitle(viewModel.getEnterCardMessage(), for: .normal)
        self.retryButton.setTitleColor(ThemeManager.shared.modalComponent().tintColor, for: .normal)
        self.retryButton.titleLabel?.font = Utils.getFont(size: buttonFontSize)
    }

    @IBAction func exit() {
        guard let callbackCancel = self.callbackCancel else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.dismiss(animated: true) {
            callbackCancel()
        }

    }

}

internal class AvailableCardsViewModel {

    let MARGIN_X_SCROLL_VIEW: CGFloat = 32
    let MIN_HEIGHT_PERCENT: CGFloat = 0.73
    let screenSize: CGRect!
    let screenHeight: CGFloat!
    let screenWidth: CGFloat!

    var paymentMethods: [PXPaymentMethod]!
    init(paymentMethods: [PXPaymentMethod]) {
        self.paymentMethods = paymentMethods
        self.screenSize = UIScreen.main.bounds
        self.screenHeight = screenSize.height
        self.screenWidth = screenSize.width
    }
    func getDatailViewFrame() -> CGRect {

        let availableCardsViewWidth = screenWidth - 2 * MARGIN_X_SCROLL_VIEW
        let availableCardsViewTotalHeight = getAvailableCardsViewTotalHeight(headerHeight: AvailableCardsDetailView.HEADER_HEIGHT, paymentMethodsHeight: AvailableCardsDetailView.ITEMS_HEIGHT, paymentMethodsCount: CGFloat(self.paymentMethods.count))

        let xPos = (self.screenWidth - availableCardsViewWidth)/2
        let yPos = (self.screenHeight - availableCardsViewTotalHeight)/2
        return CGRect(x: xPos, y: yPos, width: availableCardsViewWidth, height: availableCardsViewTotalHeight)
    }

    func getEnterCardMessage() -> String {
        return "Ingresar tarjeta".localized
    }

    func getAvailableCardsViewTotalHeight(headerHeight: CGFloat, paymentMethodsHeight: CGFloat, paymentMethodsCount: CGFloat) -> CGFloat {
        var totalHeight = headerHeight + paymentMethodsHeight * paymentMethodsCount
        if totalHeight > screenHeight * MIN_HEIGHT_PERCENT {
            totalHeight = screenHeight * MIN_HEIGHT_PERCENT
        }
        return totalHeight
    }
}
