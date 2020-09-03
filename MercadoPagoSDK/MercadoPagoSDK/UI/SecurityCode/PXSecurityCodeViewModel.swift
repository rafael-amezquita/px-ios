//
//  PXSecurityCodeViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 02/09/2020.
//

import Foundation
import MLCardDrawer

final class PXSecurityCodeViewModel {

    enum Reason: String {
        case SAVED_CARD = "saved_card"
        case INVALID_ESC = "invalid_esc"
        case INVALID_FINGERPRINT = "invalid_fingerprint"
        case UNEXPECTED_TOKENIZATION_ERROR = "unexpected_tokenization_error"
        case ESC_DISABLED = "esc_disabled"
        case ESC_CAP = "esc_cap"
        case CALL_FOR_AUTH = "call_for_auth"
        case NO_REASON = "no_reason"
    }

    var paymentMethod: PXPaymentMethod
    var cardInfo: PXCardInformationForm
    var reason: Reason
    let cardUI: CardUI?
    let cardData: CardData?

    // MARK: Protocols
    weak var internetProtocol: InternetConnectionProtocol?

    public init(paymentMethod: PXPaymentMethod, cardInfo: PXCardInformationForm, reason: Reason, cardUI: CardUI?, cardData: CardData?, internetProtocol: InternetConnectionProtocol) {
        self.paymentMethod = paymentMethod
        self.cardInfo = cardInfo
        self.reason = reason
        self.cardUI = cardUI
        self.cardData = cardData
        self.internetProtocol = internetProtocol
    }
}

// MARK: Publics
extension PXSecurityCodeViewModel {
    func shouldShowCard() -> Bool {
        return !UIDevice.isSmallDevice() && !isVirtualCard()
    }

    func isVirtualCard() -> Bool {
        paymentMethod.creditsDisplayInfo?.cvvInfo != nil
    }

    func getVirtualCardTitle() -> String? {
        return paymentMethod.creditsDisplayInfo?.cvvInfo?.title
    }

    func getVirtualCardSubtitle() -> String? {
        return paymentMethod.creditsDisplayInfo?.cvvInfo?.message
    }
}

// MARK: Static methods
extension PXSecurityCodeViewModel {
    static func getSecurityCodeReason(invalidESCReason: PXESCDeleteReason?, isCallForAuth: Bool = false) -> PXSecurityCodeViewModel.Reason {
        if isCallForAuth {
            return .CALL_FOR_AUTH
        }

        if !PXConfiguratorManager.escProtocol.hasESCEnable() {
            return .ESC_DISABLED
        }

        guard let invalidESCReason = invalidESCReason else { return .SAVED_CARD }

        switch invalidESCReason {
        case .INVALID_ESC:
            return .INVALID_ESC
        case .INVALID_FINGERPRINT:
            return .INVALID_FINGERPRINT
        case .UNEXPECTED_TOKENIZATION_ERROR:
            return .UNEXPECTED_TOKENIZATION_ERROR
        case .ESC_CAP:
            return .ESC_CAP
        default:
            return .NO_REASON
        }
    }
}

// MARK: Tracking
extension PXSecurityCodeViewModel {
    func getScreenProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        if let token = cardInfo as? PXCardInformation {
            properties["card_id"] =  token.getCardId()
        }
        properties["reason"] = reason.rawValue
        return properties
    }

    func getInvalidUserInputErrorProperties(message: String) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = TrackingPaths.Screens.getSecurityCodePath(paymentTypeId: paymentMethod.paymentTypeId)
        properties["style"] = Tracking.Style.customComponent
        properties["id"] = Tracking.Error.Id.invalidCVV
        properties["message"] = message
        properties["attributable_to"] = Tracking.Error.Atrributable.user
        var extraDic: [String: Any] = [:]
        extraDic["payment_method_type"] = paymentMethod.getPaymentTypeForTracking()
        extraDic["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        properties["extra_info"] = extraDic
        return properties
    }
}
