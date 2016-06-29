Pod::Spec.new do |s|

  s.name             = 'MTKPrivacyPods'
  s.version          = '0.1.0'
  s.summary          = 'PrivacyPods For XiaoMai'
  s.homepage         = 'http://192.168.1.58/Joy/iOS-CocoaPods-Privacy'
  s.requires_arc     = true
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Joy' => 'joy@caizhu.com' }
  s.source           = { :git => 'https://github.com/CLJian/MTKPrivacyPods.git', :tag => s.version.to_s }
  s.public_header_files = 'MTKPrivacyPods/MTKPrivacyPods.h'
  s.source_files = 'MTKPrivacyPods/MTKPrivacyPods.h'

  s.subspec 'MTKModel' do |ss|
    ss.source_files = 'MTKPrivacyPods/MTKModel/*.{h,m}'
    ss.public_header_files = 'MTKPrivacyPods/MTKModel/*.h'
    ss.library = 'sqlite3'
  end

  s.subspec 'MTKExtension' do |ss|
  ss.source_files = 'MTKPrivacyPods/MTKExtension/*.{h,m}'
  ss.public_header_files = 'MTKPrivacyPods/MTKExtension/*.h'
  end

  s.subspec 'MTKView' do |ss|
  ss.source_files = 'MTKPrivacyPods/MTKView/*.{h,m}'
  ss.public_header_files = 'MTKPrivacyPods/MTKView/*.h'
  end

end
