
Pod::Spec.new do |s|

  s.name         = "SANetworking"
  s.version      = "4.2"
  s.summary      = "SANetworking is basically developed for send GET,POST requests to Server and Uploading/Downloading files. Its very easy to use"

  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/subhasharya/SANetworking"
  s.license      = "MIT (example)"
  s.author             = { "Subhash Arya" => "subhasharya2@gmail.com" }
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/subhasharya/SANetworking", :tag => "#{s.version}" }
  s.source_files  = "SANetworking"
  s.exclude_files = "Classes/Exclude"
 
end
