module SFRest
  # Do User actions within the Site Factory
  class User
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Gets the complete list of users
    # Makes multiple requests to the factory to get all the users on the factory
    # @return [Hash{'count' => Integer, 'users' => Hash}]
    def user_list
      page = 1
      not_done = true
      count = 0
      while not_done
        current_path = '/api/v1/users?page=' << page.to_s
        res = @conn.get(current_path)
        if res['users'] == []
          not_done = false
        elsif !res['message'].nil?
          return { 'message' => res['message'] }
        elsif page == 1
          count = res['count']
          users = res['users']
        else
          res['users'].each do |user|
            users << user
          end
        end
        page += 1
      end
      { 'count' => count, 'users' => users }
    end

    # gets the site ID for the site named sitename
    # will page through all the sites available searching for the site
    # @param [String] username drupal username (not email)
    # @return [Integer] the uid of the drupal user
    def get_user_id(username)
      pglimit = 100
      res = @conn.get('/api/v1/users&limit=' + pglimit.to_s)
      usercount = res['count'].to_i
      id = user_data_from_results(res, username, 'uid')
      return id if id

      pages = (usercount / pglimit) + 1
      2.upto(pages) do |i|
        res = @conn.get('/api/v1/users&limit=' + pglimit.to_s + '?page=' + i.to_s)
        id = user_data_from_results(res, username, 'uid')
        return id if id
      end
      nil
    end

    # Extract the user data for 'key' based on the user result object
    # @param [Hash] res result from a request to /users
    # @param [String] username
    # @param [String] key one of the user data returned (uid, mail, tfa_status...)
    # @return [Object] Integer, String, Array, Hash depending on the user data
    def user_data_from_results(res, username, key)
      users = res['users']
      users.each do |user|
        return user[key] if user['name'] == username
      end
      nil
    end

    # Gets the data for user UID
    # @param [int] uid site id
    # @return [Hash]
    def get_user_data(uid)
      @conn.get('/api/v1/users/' + uid.to_s)
    end

    # Creates a user.
    # @param [String] name
    # @param [String] email
    # @param [Hash] datum hash with elements :pass => string,
    #                                        :status => 0|1,
    #                                        :roles => Array
    def create_user(name, email, datum = nil)
      current_path = '/api/v1/users'
      payload = { name: name, mail: email }
      payload.merge!(datum) unless datum.nil?
      @conn.post(current_path, payload.to_json)
    end

    # Updates a user.
    # @param [Integer] uid user id of the drupal user to update
    # @param [Hash] datum hash with elements :name => string, :pass => string,
    #                                        :status => 0|1, :roles => Array,
    #                                        :mail => string@string, :tfa_status => 0|1
    def update_user(uid, datum = nil)
      current_path = "/api/v1/users/#{uid}/update"
      payload = datum.to_json unless datum.nil?
      @conn.put(current_path, payload)
    end

    # Delete a user.
    # @param [integer] uid Uid of the user to be deleted
    def delete_user(uid)
      current_path = "/api/v1/users/#{uid}"
      @conn.delete(current_path)
    end
  end
end
