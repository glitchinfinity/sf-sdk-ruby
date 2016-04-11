module SFRest
  # SF Group management
  class Group
    def initialize(conn)
      @conn = conn
    end

    # Creates a site group with specified group name.
    def create_group(groupname)
      current_path = '/api/v1/groups'
      payload = { 'group_name' => groupname }.to_json
      @conn.post(current_path, payload)
    end

    # Gets a site group with a specified group id.
    def get_group(group_id = 0)
      current_path = '/api/v1/groups/' << group_id.to_s
      @conn.get(current_path)
    end

    # Gets a list of all site groups.
    def group_list
      page = 1
      not_done = true
      count = 0
      while not_done
        current_path = '/api/v1/groups?page=' << page.to_s
        res = @conn.get(current_path)
        if res['groups'] == []
          not_done = false
        elsif !res['message'].nil?
          puts res['message']
          break
        else
          if page == 1
            count = res['count']
            groups = res['groups']
          else
            res['groups'].each do |group|
              groups << group
            end
          end
        end
        page += 1
      end
      { 'count' => count, 'groups' => groups }
    end
  end
end
