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

    # Deletes the group with the specified id
    # @param [Integer] group_id Id of the group to fetch
    def delete_group(group_id)
      current_path = '/api/v1/groups/' << group_id.to_s
      @conn.delete(current_path)
    end

    # Renames existing group.
    # @param [Integer] group_id Id of the group to rename.
    # @param [String] groupname New name for the group.
    def rename_group(group_id, groupname)
      current_path = '/api/v1/groups/' + group_id.to_s + '/update'
      payload = { 'group_name' => groupname }.to_json
      @conn.put(current_path, payload)
    end

    # Gets a site group with a specified group id.
    # @param [Integer] group_id Id of the group to fetch
    # @return [Hash] group object from the SF Api
    def get_group(group_id = 0)
      current_path = '/api/v1/groups/' << group_id.to_s
      @conn.get(current_path)
    end

    # Gets all users that are members of this group
    # @param [Integer] group_id Id of the group to fetch
    # @return [Hash] {'count' => count, 'members' => Hash }
    def get_members(group_id = 0)
      current_path = '/api/v1/groups/' + group_id.to_s + '/members'
      @conn.get(current_path)
    end

    # Add users to this group
    # @param [Integer] group_id Id of the group
    # @param [Array] uids of the users that need to be added
    # @return [Hash] {'count' => count, 'uids_added' => Hash }
    def add_members(group_id, uids)
      current_path = '/api/v1/groups/' + group_id.to_s + '/members'
      payload = { 'uids' => uids.map(&:to_i) }.to_json
      @conn.post(current_path, payload)
    end

    # Remove members from this group
    # @param [Integer] group_id Id of the group
    # @param [Array] uids of the users that need to be removed
    # @return [Hash] {'group_id' => 123, 'uids_removed' => [1, 2, ...]}
    def remove_members(group_id, uids)
      current_path = '/api/v1/groups/' + group_id.to_s + '/members'
      payload = { 'uids' => uids.map(&:to_i) }.to_json
      @conn.delete(current_path, payload)
    end

    # Promote users to group admins
    # @param [Integer] group_id Id of the group
    # @param [Array] uids of the users that need to be promoted
    # @return [Hash] {'count' => count, 'uids_promoted' => [1, 2, ...] }
    def promote_to_admins(group_id, uids)
      current_path = '/api/v1/groups/' + group_id.to_s + '/admins'
      payload = { 'uids' => uids.map(&:to_i) }.to_json
      @conn.post(current_path, payload)
    end

    # Demote users from group admins
    # @param [Integer] group_id Id of the group
    # @param [Array] uids of the users that need to be demoted
    # @return [Hash] {'count' => count, 'uids_demoted' => Hash }
    def demote_from_admins(group_id, uids)
      current_path = '/api/v1/groups/' + group_id.to_s + '/admins'
      payload = { 'uids' => uids.map(&:to_i) }.to_json
      @conn.delete(current_path, payload)
    end

    # Add sites to this group
    # @param [Integer] group_id Id of the group
    # @param [Array] site_ids Ids of the sites that need to be added
    # @return [Hash] {'group_id' => 123, 'site_ids_added' => [1, 2, ...]}
    def add_sites(group_id, site_ids)
      current_path = '/api/v1/groups/' + group_id.to_s + '/sites'
      payload = { 'site_ids' => site_ids }.to_json
      @conn.post(current_path, payload)
    end

    # Remove sites from this group
    # @param [Integer] group_id Id of the group
    # @param [Array] site_ids Ids of the sites that need to be removed.
    # @return [Hash] {'group_id' => 123, 'site_ids_removed' => [1, 2, ...], 'site_ids_failed' => [3, 4, ...]}
    def remove_sites(group_id, site_ids)
      current_path = '/api/v1/groups/' + group_id.to_s + '/sites'
      payload = { 'site_ids' => site_ids }.to_json
      @conn.delete(current_path, payload)
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

    # gets the group ID for the group named groupname
    # will page through all the groups available searching for the group
    # @param [String] group the name of the group
    # @return [Integer] the id of groupname
    def get_group_id(groupname)
      res = group_list
      id = group_data_from_results(res, groupname, 'group_id')
      return id if id
    end

    # Extract the group data for 'key' based on the site result object
    # @param [Hash] res result from a request to /sites
    # @param [String] groupname
    # @param [String] key one of the user data returned (id, site, domain...)
    # @return [Object] Integer, String, Array, Hash depending on the site data
    def group_data_from_results(res, groupname, key)
      groups = res['groups']
      groups.each do |group|
        return group[key] if group['group_name'] == groupname
      end
      nil
    end
  end
end
