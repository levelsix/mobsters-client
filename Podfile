source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
pod 'AFNetworking', '~> 2.0'
pod 'NRTouchPoints'
pod 'UIImage+BlurredFrame'
pod 'GPUImage'
pod 'Amplitude-iOS', '~> 2.1'
pod 'ProtocolBuffers', '1.9.2'
#pod 'Reachability'
#pod 'Adjust', :git => 'git://github.com/adjust/ios_sdk.git', :tag => 'v3.3.4'

#pod 'Lookback', :configurations => ['Debug', 'Release']
#pod 'LookbackSafe', :configurations => ['App Store']

target :Mobsters do
  pod 'OpenSSL'
end

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
