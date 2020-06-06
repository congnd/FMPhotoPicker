@version = "1.0.0"

Pod::Spec.new do |s|
  s.name          = "FMPhotoPicker"
  s.version       = @version
  s.summary       = "A modern, simple and zero-dependency photo picker with an elegant and customizable image editor"
  s.homepage      = "https://github.com/congnd/FMPhotoPicker"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { "Cong Nguyen" => "congnd@outlook.com" }
  s.ios.deployment_target   = '9.0'
  s.source        = { :git => "https://github.com/congnd/FMPhotoPicker.git", :tag => s.version }
  s.source_files  = 'Classes', 'FMPhotoPicker/FMPhotoPicker/source/**/*.swift'
  s.resources     = ['FMPhotoPicker/FMPhotoPicker/source/Assets.xcassets', 'FMPhotoPicker/FMPhotoPicker/source/**/*.xib']
  s.swift_version = ["4.2", "5.0"]
end
