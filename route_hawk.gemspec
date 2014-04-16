$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "route_hawk/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "route_hawk"
  s.version     = RouteHawk::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of RouteHawk."
  s.description = "TODO: Description of RouteHawk."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'shoulda-matchers'
end
