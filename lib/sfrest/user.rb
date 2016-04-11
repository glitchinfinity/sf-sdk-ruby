module SFRest
  # Do User actions within the Site Factory
  class User
    def initialize(conn)
      @conn = conn
    end

    # users
    # Gets the complete list of users
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
          puts res['message']
          break
        else
          if page == 1
            count = res['count']
            users = res['users']
          else
            res['users'].each do |user|
              users << user
            end
          end
        end
        page += 1
      end
      { 'count' => count, 'users' => users }
    end

    # gets the site ID for the site named sitename
    # will page through all the sites available searching for the site
    # @params
    # sitename:: the name of the site
    # @return the id of sitename
    def get_user_id(username)
      pglimit = 100
      res = @conn.get('/api/v1/users&limit=' + pglimit.to_s)
      usercount = res['count'].to_i
      id = user_data_from_results(res, username, 'uid')
      return id if id
      pages = (usercount / pglimit) + 1
      2.upto(pages) do |i|
        res = @conn.get('/api/v1/users&limit=' + pglimit.to_s + '?page=' + i.to_s)
        puts "trying to find #{username} from page #{i}"
        id = user_data_from_results(res, username, 'uid')
        return id if id
      end
      nil
    end

    def user_data_from_results(res, username, key)
      users = res['users']
      users.each do |user|
        return user[key] if user['name'] == username
      end
      nil
    end

    # Gets the key asked for in site data
    # @params [int] site_id the site id
    # re
    def get_user_data(uid)
      @conn.get('/api/v1/users/' + uid.to_s)
    end

    # Creates a user.
    # name, email are required
    # datum = hash with elements :pass => string, :status => 0|1, :roles => Array
    def create_user(name, email, datum = nil)
      current_path = '/api/v1/users'
      payload = { :name => name, :mail => email }
      payload.merge!(datum) unless datum.nil?
      @conn.post(current_path, payload.to_json)
    end

    # Updates a user).
    # id, is required
    # datum = hash with elements :name => string, :pass => string, :status => 0|1, :roles => Array
    # :mail => string@string, :tfa_status => 0|1
    def update_user(id, datum = nil)
      current_path = "/api/v1/users/#{id}/update"
      payload = datum.to_json unless datum.nil?
      @conn.put(current_path, payload)
    end

    # Delete a user.
    def delete_user(id)
      current_path = "/api/v1/users/#{id}"
      @conn.delete(current_path)
    end
  end
end
