module SFRest
  # Generic http methods
  # accessors for all the sub classes.
  class Connection
    attr_accessor :base_url, :username, :password

    # @param [String] url base url of the SF endpoint e.g. https://www.sfdev.acsitefactory.com
    # @param [String] user api user
    # @param [String] password api password
    def initialize(url, user, password)
      @base_url = url
      @username = user
      @password = password
    end

    # http request via get
    # @param [string] uri
    # @return [Object] ruby representation of the json response
    #                  if the reponsebody  does not parse, returns
    #                  the non-parsed body
    def get(uri)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.get(@base_url + uri.to_s,
                      headers: headers,
                      user: username,
                      password: password,
                      ssl_verify_peer: false)
      begin
        access_check JSON(res.body), res.status
      rescue JSON::ParserError
        res.body
      end
    end

    # http request via get
    # @param [string] uri
    # @return [Integer, Object] http status and the ruby representation
    #                           of the json response if the reponse body
    #                           does not parse, returns the non-parsed body
    def get_with_status(uri)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.get(@base_url + uri.to_s,
                      headers: headers,
                      user: username,
                      password: password,
                      ssl_verify_peer: false)
      begin
        data = access_check JSON(res.body), res.status
        return res.status, data
      rescue JSON::ParserError
        return res.status, res.body
      end
    end

    # http request via post
    # @param [string] uri
    # @return [Object] ruby representation of the json response
    #                  if the reponsebody  does not parse, returns
    #                  the non-parsed body
    def post(uri, payload)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.post(@base_url + uri.to_s,
                       headers: headers,
                       user: username,
                       password: password,
                       ssl_verify_peer: false,
                       body: payload)
      begin
        access_check JSON(res.body), res.status
      rescue JSON::ParserError
        res.body
      end
    end

    # http request via put
    # @param [string] uri
    # @return [Object] ruby representation of the json response
    #                  if the reponsebody  does not parse, returns
    #                  the non-parsed body
    def put(uri, payload)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.put(@base_url + uri.to_s,
                      headers: headers,
                      user: username,
                      password: password,
                      ssl_verify_peer: false,
                      body: payload)
      begin
        access_check JSON(res.body), res.status
      rescue JSON::ParserError
        res.body
      end
    end

    # http request via delete
    # @param [string] uri
    # @return [Object] ruby representation of the json response
    #                  if the reponsebody  does not parse, returns
    #                  the non-parsed body
    def delete(uri)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.delete(@base_url + uri.to_s,
                         headers: headers,
                         user: username,
                         password: password,
                         ssl_verify_peer: false)
      begin
        access_check JSON(res.body), res.status
      rescue JSON::ParserError
        res.body
      end
    end

    # Throws an SFRest exception for requests that have problems
    # @param [Object] data JSON parsed http reponse of the SFApi
    # @param [int] http_status the request's HTTP status
    # @return [Object] the data object if there are no issues
    # @raise [SFRest::AccessDeniedError] if Authentication fails
    # @raise [SFRest::ActionForbiddenError] if the users role cannot perform the request
    # @raise [SFRest::BadRequestError]  if there is something malformed in the request
    # @raise [SFRest::UnprocessableEntity] if there is an unprocessable entity in the request
    # @raise [SFRest::SFError] if the response HTTP status indicates an error but without the above qualifiers
    #
    # The cyclomatic complexity check is being ignored here because we are
    # collecting all the possible exception raising cases.
    def access_check(data, http_status) # rubocop:disable Metrics/CyclomaticComplexity
      if data.is_a?(Hash) && !data['message'].nil?
        case data['message']
        when /Access denied|Access Denied/
          raise SFRest::AccessDeniedError, data['message']
        when /Forbidden: /
          raise SFRest::ActionForbiddenError, data['message']
        when /Bad Request:/
          raise SFRest::BadRequestError, data['message']
        when /Unprocessible Entity: |Unprocessable Entity: /
          raise SFRest::UnprocessableEntity, data['message']
        end
        if http_status >= 400 && http_status <= 599
          sf_err_message = "Status: #{http_status}, Message: #{data['message']}"
          raise SFRest::SFError, sf_err_message
        end
      end
      data
    end

    # pings the SF api as an authenticated user
    # responds with a pong
    def ping
      get('/api/v1/ping')
    end

    # Pings to retrieve a service response.
    def service_response
      ping
    end

    # define the other class accessor methods.
    # this will instantiate the class with the set creds
    # and make it possible to do
    #  sfa = SFRest.new url, user, password
    #  sfa.ping
    #  sfa.site.first_site_id
    #
    # If a new class is added, add the accessor to this list.
    # NOTE: accessor == Class_name.to_lower
    REST_METHODS = %w[audit
                      backup
                      codebase
                      collection
                      domains
                      group
                      info
                      role
                      site
                      stage
                      task
                      theme
                      update
                      usage
                      user
                      variable].freeze

    REST_METHODS.each do |m|
      define_method(m) do
        m.capitalize!
        sfrest_klass = "SFRest::#{m}"
        Object.const_get(sfrest_klass).new(self)
      end
    end
  end
end
