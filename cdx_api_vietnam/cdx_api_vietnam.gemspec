$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cdx_api_vietnam/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cdx_api_vietnam"
  s.version     = CdxApiVietnam::VERSION
  s.authors     = ["Jorge Alvarez"]
  s.email       = ["jorge@alvareznavarro.es"]
  s.homepage    = "http://www.thecdx.org"
  s.summary     = "Vietnamese customisation of the core API."
  s.description = "Language translation and customisation of the cdx_api_core engine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"

  s.add_development_dependency "cdx_api_core"
end
