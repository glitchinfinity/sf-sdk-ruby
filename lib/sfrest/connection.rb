module SFRest
  # Generic http methods
  # accessors for all the sub classes.
  class Connection
    attr_accessor :base_url, :username, :password

    def initialize(url, user, password)
      @base_url = url
      @username = user
      @password = password
    end

    def get(uri)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.get(@base_url + uri.to_s,
                      headers: headers,
                      user: username,
                      password: password,
                      ssl_verify_peer: false)
      begin
        access_check JSON(res.body)
      rescue JSON::ParserError
        res.body
      end
    end

    def get_with_status(uri)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.get(@base_url + uri.to_s,
                      headers: headers,
                      user: username,
                      password: password,
                      ssl_verify_peer: false)
      begin
        data = access_check JSON(res.body)
        return res.status, data

      rescue JSON::ParserError
        return res.status, res.body
      end
    end

    def post(uri, payload)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.post(@base_url + uri.to_s,
                       headers: headers,
                       user: username,
                       password: password,
                       ssl_verify_peer: false,
                       body: payload)
      begin
        access_check JSON(res.body)
      rescue JSON::ParserError
        res.body
      end
    end

    def put(uri, payload)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.put(@base_url + uri.to_s,
                      headers: headers,
                      user: username,
                      password: password,
                      ssl_verify_peer: false,
                      body: payload)
      begin
        access_check JSON(res.body)
      rescue JSON::ParserError
        res.body
      end
    end

    def delete(uri)
      headers = { 'Content-Type' => 'application/json' }
      res = Excon.delete(@base_url + uri.to_s,
                         headers: headers,
                         user: username,
                         password: password,
                         ssl_verify_peer: false)
      begin
        access_check JSON(res.body)
      rescue JSON::ParserError
        res.body
      end
    end

    def access_check(data)
      return data unless data.is_a?(Hash) # if there is an error message, it will be in a hash.
      unless data['message'].nil?
        raise SFRest::AccessDeniedError, data['message'] if data['message'] =~ /Access denied/
        raise SFRest::ActionForbiddenError, data['message'] if data['message'] =~ /Forbidden: /
        raise SFRest::BadRequestError, data['message'] if data['message'] =~ /Bad Request:/
      end
      data
    end

    # pings the SF api
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
    REST_METHODS = %w(audit
                      backup
                      group
                      role
                      site
                      stage
                      task
                      theme
                      update
                      user
                      variable).freeze

    REST_METHODS.each do |m|
      define_method(m) do
        m.capitalize!
        sfrest_klass = "SFRest::#{m}"
        Object.const_get(sfrest_klass).new(self)
      end
    end
  end
end
