$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sofav/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sofav"
  s.version     = Sofav::VERSION
  s.authors     = ["developer"]
  s.email       = ["developer@tavanv.com"]
  s.homepage    = "https://github.com/redroca/SofaRails"
  s.summary     = "Rapid Rails Framework."
  s.description = "Rapid Rails Framework."
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"

  s.files = Dir["{app,config,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "kaminari", "1.0.1"
  s.add_dependency "enumerize", "2.1.2"
  s.add_dependency "doorkeeper", "4.2.6"
  s.add_dependency "devise", "4.3.0"
  s.add_dependency "draper", "3.0.0"
  
  s.add_development_dependency "rails", "~> 5.0.5"
  s.add_development_dependency "sqlite3"
end
