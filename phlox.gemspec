$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "phlox/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "phlox"
  s.version     = Phlox::VERSION
  s.authors     = ["Nicholas Cancelliere"]
  s.email       = ["ncancelliere@whiteglove.com"]
  s.homepage    = "http://www.whiteglove.com"
  s.summary     = "An OpenEMR API client implemented as a Rails engine."
  s.description = "A Rails engine that allows apps to easily integrate with the OpenEMR API (oemr501c3/openemr-api)
                   using ActiveResource."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.16"
  s.add_dependency "activeresource"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "yard"
end
