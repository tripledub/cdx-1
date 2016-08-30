$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cdx_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cdx_core"
  s.version     = CdxCore::VERSION
  s.authors     = ["Jorge Alvarez"]
  s.email       = ["jorge@alvareznavarro.es"]
  s.homepage    = "http://www.thecdx.org"
  s.summary     = "Summary of CdxCore."
  s.description = "Description of CdxCore."
  s.license     = "MIT"

  s.files       = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-collection_matchers'
end
