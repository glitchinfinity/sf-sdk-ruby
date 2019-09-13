# frozen_string_literal: true

module SFRest
  # Find sites, create a site,
  class Site
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # gets the site ID for the site named sitename
    # will page through all the sites available searching for the site
    # @param [String] sitename the name of the site
    # @return [Integer] the id of sitename
    def get_site_id(sitename)
      pglimit = 100
      res = @conn.get('/api/v1/sites&limit=' + pglimit.to_s)
      sitecount = res['count'].to_i
      id = site_data_from_results(res, sitename, 'id')
      return id if id

      pages = (sitecount / pglimit) + 1
      2.upto(pages) do |i|
        res = @conn.get('/api/v1/sites&limit=' + pglimit.to_s + '?page=' + i.to_s)
        id = site_data_from_results(res, sitename, 'id')
        return id if id
      end
      nil
    end

    # Extract the site data for 'key' based on the site result object
    # @param [Hash] res result from a request to /sites
    # @param [String] sitename
    # @param [String] key one of the user data returned (id, site, domain...)
    # @return [Object] Integer, String, Array, Hash depending on the site data
    def site_data_from_results(res, sitename, key)
      sites = res['sites']
      sites.each do |site|
        return site[key] if site['site'] == sitename
      end
      nil
    end

    # Gets the site data for a specific site id
    # @param [Integer] site_id the site id
    # @return [Hash]
    def get_site_data(site_id)
      @conn.get('/api/v1/sites/' + site_id.to_s)
    end

    # gets the site id of the 1st one found using the api
    # @return [Integer] the site id
    def first_site_id
      res = @conn.get('/api/v1/sites')
      res['sites'].first['id']
    end

    # Gets the complete list of sites
    # Makes multiple requests to the factory to get all the sites on the factory
    # @param [Boolean] show_incomplete whether to include incomplete sites in
    #   the list. The default differs from UI/SF to maintain backward compatibility.
    # @return [Hash{'count' => Integer, 'sites' => Hash}]
    def site_list(show_incomplete = true)
      page = 1
      not_done = true
      count = 0
      sites = []
      while not_done
        current_path = '/api/v1/sites?page='.dup << page.to_s
        current_path <<= '&show_incomplete=true' if show_incomplete
        res = @conn.get(current_path)
        if res['sites'] == []
          not_done = false
        elsif !res['message'].nil?
          return { 'message' => res['message'] }
        elsif page == 1
          count = res['count']
          sites = res['sites']
        else
          res['sites'].each do |site|
            sites << site
          end
        end
        page += 1
      end
      { 'count' => count, 'sites' => sites }
    end

    # Creates a site.
    # @param [String] sitename The name of the site to create.
    # @param [Integer] group_id  The Id of the group the site is to be a member of.
    # @param [String] install_profile The install profile to use when creating the site.
    # @param [Integer] codebase The codebase index to use in installs.
    def create_site(sitename, group_id, install_profile = nil, codebase = nil)
      current_path = '/api/v1/sites'
      payload = { 'site_name' => sitename, 'group_ids' => [group_id],
                  'install_profile' => install_profile, 'codebase' => codebase }.to_json
      @conn.post(current_path, payload)
    end

    # Creates a site.
    # Alias for create_site
    # @param [String] sitename The name of the site to create
    # @param [Integer] group_id  The Id of the group the site is to be a member of
    # @param [String] install_profile The install profile to use when creating the site
    # @param [Integer] codebase The codebase index to use in installs.
    alias create create_site

    # Deletes a site.
    # @param [Integer] site_id The id of the stie to be deleted
    # @return [Hash]
    def delete(site_id)
      current_path = '/api/v1/sites/' + site_id.to_s
      @conn.delete current_path
    end

    # accessors for backups/restore
    # so that you can do site.backup.list_backups
    def backup
      @conn.backup
    end

    # Clears the caches for a site.
    # @param [Integer] site_id The id of the site to be cleared
    # @return [Hash]
    def cache_clear(site_id)
      current_path = "/api/v1/sites/#{site_id}/cache-clear"
      @conn.post current_path, nil
    end
  end
end
