Dir[File.dirname(__FILE__) + '../lib/**/*.rb'].each do |f|
  puts "adding file #{f}"
  require f
end
require 'simplecov'
SimpleCov.add_filter('vendor')
SimpleCov.add_filter('spec')
SimpleCov.start

require 'webmock/rspec'
#require 'bundler/setup'
#Bundler.setup


require_relative '../lib/sfrest'
require_relative '../lib/sfrest/audit'
require_relative '../lib/sfrest/connection'
require_relative '../lib/sfrest/error'
require_relative '../lib/sfrest/group'
require_relative '../lib/sfrest/role'
require_relative '../lib/sfrest/site'
require_relative '../lib/sfrest/stage'
require_relative '../lib/sfrest/task'
require_relative '../lib/sfrest/theme'
require_relative '../lib/sfrest/update'
require_relative '../lib/sfrest/user'
require_relative '../lib/sfrest/variable'
