
Pod::Spec.new do |s|

  s.platform = :ios
  s.ios.deployment_target = '12.0'
  s.name = "NetworkLayer"
  s.summary = "Lighweit list of classes for networking"
  s.requires_arc = true
  s.version = "0.0.6"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Denis Al" => "denis.aleshin@gismart.com" }
  s.homepage = "https://github.com/Denisaleshin/CPod"
  s.source = { :git => "https://github.com/Denisaleshin/CPod.git", :tag => "#{s.version}" }
  s.framework = "Foundation"
  s.source_files = "*.swift"
  s.swift_version = "5"

 end
