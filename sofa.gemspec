$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sofa/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sofa"
  s.version     = Sofa::VERSION
  s.authors     = ["developer"]
  s.email       = ["developer@tavanv.com"]
  s.homepage    = "https://github.com/redroca/SofaRails"
  s.summary     = "Rapid Rails Framework."
  s.description = "Rapid Rails Framework."
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"

  s.files = Dir["{app,config,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 5.0.5"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "kaminari"
  s.add_development_dependency "enumerize"
  s.add_development_dependency "doorkeeper"
  s.add_development_dependency "devise"
  s.add_development_dependency "draper", "3.0.0"
end
