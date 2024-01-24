package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-ticketmaster"
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']

  s.authors      = package['author']
  s.homepage     = package['homepage']
  s.platform     = :ios, "14.0"

  s.source       = { :git => "https://github.com/squidcloudio/react-native-ticketmaster.git", :tag => "{s.version}" }
  s.source_files  = "ios/**/*.{h,m,swift}"

  s.dependency "React-Core"
  s.dependency "TM-Ignite-Test"
end