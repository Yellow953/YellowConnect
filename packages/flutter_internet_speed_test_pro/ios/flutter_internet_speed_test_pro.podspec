#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_internet_speed_test_pro.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_internet_speed_test_pro'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin to test internet download and upload speed.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/redx1t/flutter_internet_speed_test_pro'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'RedX1t' => 'redx1t@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_internet_speed_test_pro/Sources/flutter_internet_speed_test_pro/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end