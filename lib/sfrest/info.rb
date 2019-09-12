# frozen_string_literal: true

module SFRest
  # Retrieve Site Factory info.
  class Info
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Gets information about the Site Factory.
    # @return [Hash{ "factory_version" => String,
    #                "time" => "2016-10-28T09:25:26+00:00"}]
    def sfinfo
      @conn.get('/api/v1/sf-info')
    end
  end
end
