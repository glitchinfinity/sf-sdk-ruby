# Simple wrappper around RestClient.Resource
$LOAD_PATH.unshift(File.dirname(__FILE__)) unless
    $LOAD_PATH.include?(File.dirname(__FILE__)) ||
    $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'excon'
require 'json'

require 'sfrest/audit'
require 'sfrest/backup'
require 'sfrest/collection'
require 'sfrest/connection'
require 'sfrest/domains'
require 'sfrest/error'
require 'sfrest/group'
require 'sfrest/info'
require 'sfrest/pathbuilder'
require 'sfrest/role'
require 'sfrest/site'
require 'sfrest/stage'
require 'sfrest/task'
require 'sfrest/theme'
require 'sfrest/update'
require 'sfrest/usage'
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

  # Extract the return data for 'key' based on the result object
  # @param [Hash] res result from a request to /collections or /site
  # @param [String] field data field to search
  # @param [String] datapat regex-like pattern to match to the data field
  # @param [String] key one of the user data returned (id, name, domain...)
  # @return [Object] Integer, String, Array, Hash depending on the collection data
  def self.find_data_from_results(res, field, datapat, key)
    data = res.select { |k| !k.to_s.match(/time|count/) }
    raise InvalidDataError('The data you are searching is not a hash') unless data.is_a?(Hash)
    data.each_value do |datum|
      datum.each do |dat|
        return dat[key] if dat[field].to_s =~ /#{datapat}/
      end
    end
    nil
  end
end
