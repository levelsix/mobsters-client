platform :ios, '6.0'
pod 'AFNetworking', '~> 2.0'
pod 'NRTouchPoints'
pod 'UIImage+BlurredFrame'
pod 'GPUImage'
pod 'Amplitude-iOS', '~> 2.1'
#pod 'Adjust', :git => 'git://github.com/adjust/ios_sdk.git', :tag => 'v3.3.4'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
