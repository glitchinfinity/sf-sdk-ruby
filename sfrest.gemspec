lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sfrest/version'
Gem::Specification.new do |s|
  s.name        = 'sfrest'
  s.version     = SFRest::VERSION
  s.date        = '2016-12-22'
  s.summary     = "Acquia Site Factory Rest API."
  s.description = "Wrapper methods around the ACSF Rest API."
  s.authors     = [
      'ACSF Engineering'
  ]
  s.files       = Dir['lib/**/*.rb']
  s.homepage    =
      'http://github.com/acquia/sf-sdk-ruby'
  s.license       = 'MIT'

  s.add_dependency('excon')

  s.add_development_dependency('bundler')
  s.add_development_dependency('rspec')
  s.add_development_dependency('simplecov', '~> 0.11')
  s.add_development_dependency('webmock', '~> 1.24')
end