#
# Be sure to run `pod lib lint DWGNicoVideoExtractor.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DWGNicoVideoExtractor"
  s.version          = "0.1.0"
  s.summary          = "Nico Nico Douga (nicovideo.jp) Video URL Extractor"
  s.description      = <<-DESC
                       Nico Nico Douga (nicovideo.jp) Video URL Extractor.
                       DESC
  s.homepage         = "https://github.com/konomae/DWGNicoVideoExtractor"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "konomae" => "konomae@users.noreply.github.com" }
  s.source           = { :git => "https://github.com/konomae/DWGNicoVideoExtractor.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'DWGNicoVideoExtractor' => ['Pod/Assets/*.png']
  }
end
