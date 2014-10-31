#
# Be sure to run `pod lib lint MUKUserNotificationController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MUKUserNotificationController"
  s.version          = "0.1.0"
  s.summary          = "A short description of MUKUserNotificationController."
  s.description      = <<-DESC
                       An optional longer description of MUKUserNotificationController

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/MUKUserNotificationController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Muccy" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/MUKUserNotificationController.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes', 'Pod/Classes/**/*.{h,m}'
  s.resource_bundles = {
    'MUKUserNotificationController' => ['Pod/Assets/*.png']
  }

  s.private_header_files = 'Pod/Classes/Private/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
