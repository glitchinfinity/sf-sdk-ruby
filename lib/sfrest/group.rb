module SFRest
  # SF Group management
  class Group
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Creates a site group with specified group name.
    # This currently will only create a group in the root
    # @param [String] groupname Name of the group to be created
    def create_group(groupname)
      current_path = '/api/v1/groups'
      payload = { 'group_name' => groupname }.to_json
      @conn.post(current_path, payload)
    end

    # Gets a site group with a specified group id.
    # @param [Integer] group_id Id of the group to fetch
    # @return [Hash] group object from the SF Api
    def get_group(group_id = 0)
      current_path = '/api/v1/groups/' << group_id.to_s
      @conn.get(current_path)
    end

    # Gets a list of all site groups.
    # @return [Hash] all the groups on the factory plus a count
    #                {'count' => count, 'groups' => Hash }
    # this will iterate through the group pages
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
          return { 'message' => res['message'] }
        elsif page == 1
          count = res['count']
          groups = res['groups']
        else
          res['groups'].each do |group|
            groups << group
          end
        end
        page += 1
      end
      { 'count' => count, 'groups' => groups }
    end
  end
end
