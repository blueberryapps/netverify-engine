$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'netverify/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'netverify'
  s.version     = Netverify::VERSION
  s.date        = '2014-03-11'
  s.summary     = 'NetVerify KYC service integration'
  s.description = 'NetVerify KYC service integration for Ruby'
  s.authors     = ['Tomas Dundacek']
  s.email       = 'tdundacek@blueberryapps.com'

  s.files =
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.1.0.rc1'
  s.add_dependency 'faraday'
  s.add_dependency 'uuid'

  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'
end
