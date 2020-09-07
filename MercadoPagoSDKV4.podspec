Pod::Spec.new do |s|
  s.name             = "MercadoPagoSDKV4"
  s.version          = "4.35.7"
  s.summary          = "MercadoPagoSDK"
  s.homepage         = "https://www.mercadopago.com"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "Mercado Pago"
  s.source           = { :git => 'git@github.com:mercadopago/px-ios.git', :tag => s.version.to_s }
  s.swift_version = '4.2'
  s.platform     = :ios, '10.0'
  s.requires_arc = true
  s.default_subspec = 'Default'
  #s.static_framework = true

  s.subspec 'Default' do |default|
    default.source_files = ['MercadoPagoSDK/MercadoPagoSDK/**/**/**.{h,m,swift}']
    default.resources = ['MercadoPagoSDK/Resources/**/*.xib']
    default.resource_bundles = {
      'MercadoPagoSDKResources' => [
        'MercadoPagoSDK/Resources/**/*.xcassets',
        'MercadoPagoSDK/Resources/**/*.{lproj,strings,stringsdict}',
        'MercadoPagoSDK/Resources/**/*.plist'
      ]
    }
    s.dependency 'MLUI', '~> 5.0'
    s.dependency 'MLCardDrawer', '~> 1.4'
    s.dependency 'MLBusinessComponents', :git => 'https://github.com/rafael-amezquita/mlbusiness-components-ios.git', :branch => 'feature/Xcode12'
    s.dependency 'MLCardForm', '~> 0.7'
    s.dependency 'AndesUI', '~> 3.0'
  end


  s.subspec 'ESC' do |esc|
    esc.dependency 'MercadoPagoSDKV4/Default'
  end

  #s.test_spec do |test_spec|
    #test_spec.source_files = 'MercadoPagoSDK/MercadoPagoSDKTests/*'
    #test_spec.frameworks = 'XCTest'
  #end
end
