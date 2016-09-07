$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cdx_api_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cdx_api_core"
  s.version     = CdxApiCore::VERSION
  s.authors     = ["Jorge Alvarez"]
  s.email       = ["jorge@alvareznavarro.es"]
  s.homepage    = "http://www.thecdp.org"
  s.summary     = "API core functionality"
  s.description = "Main functionality of the CPD API."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"

  s.add_dependency "cdx_core", "~> 1.1.0"
end
