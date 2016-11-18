# Simple wrappper around RestClient.Resource
$LOAD_PATH.unshift(File.dirname(__FILE__)) unless
    $LOAD_PATH.include?(File.dirname(__FILE__)) ||
    $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'excon'
require 'json'

require 'sfrest/audit'
require 'sfrest/backup'
require 'sfrest/connection'
require 'sfrest/domains'
require 'sfrest/error'
require 'sfrest/group'
require 'sfrest/pathbuilder'
require 'sfrest/role'
require 'sfrest/site'
require 'sfrest/stage'
require 'sfrest/task'
require 'sfrest/theme'
require 'sfrest/update'
require 'sfrest/user'
require 'sfrest/variable'

# Base Class for SF rest API sdk
module SFRest
  # Class set to work as an sdk for the Site Factory Rest api
  # most of the interesting pieces happen in the connection class and others
  class << self
    attr_accessor :base_url, :user, :password, :conn

    # returns a connection object to the SF Rest api for a specific factory
    # @param [String] url Base url of the Site Factory
    # @param [String] user username of a user on the factory
    # @param [String] password api password for the user on the factory
    def new(url, user, password)
      @base_url = url
      @user = user
      @password = password
      @conn = SFRest::Connection.new(@base_url, @user, @password)
    end
  end
end
