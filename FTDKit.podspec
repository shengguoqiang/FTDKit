

Pod::Spec.new do |s|

  s.name         = "FTDKit"
  s.version      = "0.0.5"
  s.summary      = "整理的小框架，装有一些常用的小功能"
  s.homepage     = "https://github.com/shengguoqiang/FTDKit"
  s.license      = "MIT"
  s.author             = { "shengguoqiang" => "2420548376@qq.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/shengguoqiang/FTDKit.git", :tag => s.version }
  s.source_files  = "FTDKit/**/*"
  # s.public_header_files = "Classes/**/*.h"
  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  s.requires_arc = true
  s.dependency 'Kingfisher', '~> 3.1.4'

end
