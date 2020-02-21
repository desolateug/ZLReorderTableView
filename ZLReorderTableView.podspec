#
# Be sure to run `pod lib lint ZLReorderTableView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZLReorderTableView'
  s.version          = '0.1.0'
  s.summary          = 'Using long press gesture to reorder cells in tableview.'
  s.homepage         = 'https://github.com/desolateug/ZLReorderTableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zlj' => 'zhenglingjue@qq.com' }
  s.source           = { :git => 'https://github.com/desolateug/ZLReorderTableView.git', :tag => s.version.to_s }
  
  s.requires_arc = true
  s.ios.deployment_target = '7.0'

  s.source_files = 'ZLReorderTableView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZLReorderTableView' => ['ZLReorderTableView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
