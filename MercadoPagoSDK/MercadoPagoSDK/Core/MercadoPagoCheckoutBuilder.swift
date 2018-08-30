//
//  MercadoPagoCheckoutBuilder.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 9/8/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import Foundation

@objcMembers
open class MercadoPagoCheckoutBuilder: NSObject {
    internal let publicKey: String
    internal var preferenceId: String?
    internal var checkoutPreference: PXCheckoutPreference?

    internal var privateKey: String?

    internal var paymentConfig: PXPaymentConfiguration?
    internal var advancedConfig: PXAdvancedConfiguration?

    internal var defaultUIColor: UIColor?

    public init(publicKey: String, preferenceId: String) {
        self.publicKey = publicKey
        self.preferenceId = preferenceId
    }

    public init(publicKey: String, preferenceId: String, paymentConfiguration: PXPaymentConfiguration) {
        self.publicKey = publicKey
        self.preferenceId = preferenceId
        self.paymentConfig = paymentConfiguration
    }

    public init(publicKey: String, checkoutPreference: PXCheckoutPreference, paymentConfiguration: PXPaymentConfiguration) {
        self.publicKey = publicKey
        self.checkoutPreference = checkoutPreference
        self.paymentConfig = paymentConfiguration
    }
}

// MARK: - Builder
extension MercadoPagoCheckoutBuilder {
    open func setPrivateKey(key: String) -> MercadoPagoCheckoutBuilder {
        self.privateKey = key
        return self
    }

    open func setAdvancedConfiguration(config: PXAdvancedConfiguration) -> MercadoPagoCheckoutBuilder {
        self.advancedConfig = config
        return self
    }

    open func setColor(checkoutColor: UIColor) -> MercadoPagoCheckoutBuilder {
        self.defaultUIColor = checkoutColor
        return self
    }

    open func setLanguage(_ string: String) -> MercadoPagoCheckoutBuilder {
        Localizator.sharedInstance.setLanguage(string: string)
        return self
    }

    open func setTrackingListener(_ listener: PXTrackingListener) {
        MPXTracker.sharedInstance.setTrack(listener: listener)
    }
}
