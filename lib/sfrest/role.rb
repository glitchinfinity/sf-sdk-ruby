module SFRest
  # create, delete, update, roles
  class Role
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # roles
    # Gets the complete list of roles
    # @return [Hash] all the roles on the factory plus a count
    #                {'count' => count, 'roles' => Hash }
    # this will iterate through the roles pages
    def role_list
      page = 1
      not_done = true
      count = 0
      while not_done
        current_path = '/api/v1/roles?page=' << page.to_s
        res = @conn.get(current_path)
        if res['roles'] == []
          not_done = false
        elsif !res['message'].nil?
          return { 'message' => res['message'] }
        elsif page == 1
          count = res['count']
          roles = res['roles']
        else
          res['roles'].each do |roleid, rolename|
            roles[roleid] = rolename
          end
        end
        page += 1
      end
      { 'count' => count, 'roles' => roles }
    end

    # gets the role ID for the role named rolename
    # will page through all the roles available searching for the site
    # @param [String] rolename the name of the role to find
    # @return [Integer] the id of rolename
    # this will iterate through the roles pages
    def get_role_id(rolename)
      pglimit = 100
      res = @conn.get('/api/v1/roles&limit=' + pglimit.to_s)
      rolecount = res['count'].to_i
      id = role_data_from_results(res, rolename)
      return id if id
      pages = (rolecount / pglimit) + 1
      2.upto(pages) do |i|
        res = @conn.get('/api/v1/roles&limit=' + pglimit.to_s + '?page=' + i.to_s)
        id = role_data_from_results(res, rolename)
        return id if id
      end
      nil
    end

    # Extract the role data for rolename based on the role result object
    # @param [Hash] res result from a request to /roles
    # @param [String] rolename
    # @return [Object] Integer, String, Array, Hash depending on the user data
    def role_data_from_results(res, rolename)
      roles = res['roles']
      roles.each do |role|
        return role[0].to_i if role[1] == rolename
      end
      nil
    end

    # Gets role data for a specific role id
    # @param [Integer] id the role id
    # @return [Hash] the role
    def role_data(id)
      @conn.get('/api/v1/roles/' + id.to_s)
    end

    # Creates a role.
    # @param [String] name name of the role to create
    def create_role(name)
      current_path = '/api/v1/roles'
      payload = { 'name' => name }.to_json
      @conn.post(current_path, payload)
    end

    # Updates a role (changes the name).
    # @param [Integer] id the id of the role to rename
    # @param [String] name the new role name
    def update_role(id, name)
      current_path = "/api/v1/roles/#{id}/update"
      payload = { 'new_name' => name }.to_json
      @conn.put(current_path, payload)
    end

    # Delete a role.
    # @param [Integer] id the role id of the role to delete
    def delete_role(id)
      current_path = "/api/v1/roles/#{id}"
      @conn.delete(current_path)
    end
  end
end
