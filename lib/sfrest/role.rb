module SFRest
  # create, delete, update, roles
  class Role
    def initialize(conn)
      @conn = conn
    end

    # roles
    # Gets the complete list of roles
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

    # gets the site ID for the site named sitename
    # will page through all the sites available searching for the site
    # @params
    # sitename:: the name of the site
    # @return the id of sitename
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

    def role_data_from_results(res, rolename)
      roles = res['roles']
      roles.each do |role|
        return role[0].to_i if role[1] == rolename
      end
      nil
    end

    # Gets the key asked for in site data
    # @params [int] site_id the site id
    # re
    def role_data(id)
      @conn.get('/api/v1/roles/' + id.to_s)
    end

    # Creates a role.
    def create_role(name)
      current_path = '/api/v1/roles'
      payload = { 'name' => name }.to_json
      @conn.post(current_path, payload)
    end

    # Updates a role (changes the name).
    def update_role(id, name)
      current_path = "/api/v1/roles/#{id}/update"
      payload = { 'new_name' => name }.to_json
      @conn.put(current_path, payload)
    end

    # Delete a role.
    def delete_role(id)
      current_path = "/api/v1/roles/#{id}"
      @conn.delete(current_path)
    end
  end
end
