$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cdx_vietnam/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cdx_vietnam"
  s.version     = CdxVietnam::VERSION
  s.authors     = ["Jorge Alvarez"]
  s.email       = ["ja@conferize.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CdxVietnam."
  s.description = "TODO: Description of CdxVietnam."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"

  s.add_development_dependency "sqlite3"
end
