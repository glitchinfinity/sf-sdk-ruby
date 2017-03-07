module SFRest
  # Get all the audit devents.
  class Usage
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Gets the montly usage data.
    # @param stack_id [Integer] The stack of sites of interest
    # @param datum [Hash] Optional filter parameters
    #
    #   'start_from' => "YYYY-MM", # String
    #   'sort_order' => "acs|desc", # String
    #   'limit' => Integer, # Number of months to list (max 120)
    #   'page' => Integer # Page number to show
    #
    # @return [Hash] The dynamic request data.
    #
    #      { 'count' => Integer,
    #       'time' => String date,
    #       'most_recent_data' => 'YYYY-MM-DD',
    #       'dynamic_requests' => {
    #       '2016-10' => {
    #         'date' => '2016-10',
    #          'stack_id' => 1,
    #          'total_dynamic_requests'=> 106,
    #          '2xx_dynamic_requests'=> 100,
    #          '3xx_dynamic_requests'=> 3,
    #          '4xx_dynamic_requests'=> 2,
    #          '5xx_dynamic_requests'=> 1,
    #          'total_runtime'=> 101.4,
    #          '2xx_runtime'=> 100,
    #          '3xx_runtime'=> 0.9,
    #          '4xx_runtime'=> 0.4,
    #          '5xx_runtime'=> 0.1 }
    #        }
    def monthly(stack_id = 1, datum = {})
      datum[stack_id] = stack_id
      current_path = '/api/v1/dynamic-requests/monthly'
      @conn.get URI.parse(URI.encode(pb.build_url_query(current_path, datum))).to_s
    end

    # returns a Pathbuilder object for manipulating the query parameters
    # @return [SFRest::Pathbuilder]
    def pb
      @pb ||= SFRest::Pathbuilder.new
    end

    private :pb
  end
end
