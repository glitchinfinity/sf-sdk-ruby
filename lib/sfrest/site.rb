module SFRest
  # Find sites, create a site,
  class Site
    def initialize(conn)
      @conn = conn
    end

    # gets the site ID for the site named sitename
    # will page through all the sites available searching for the site
    # @params
    # sitename:: the name of the site
    # @return the id of sitename
    def get_site_id(sitename)
      pglimit = 100
      res = @conn.get('/api/v1/sites&limit=' + pglimit.to_s)
      sitecount = res['count'].to_i
      id = site_data_from_results(res, sitename, 'id')
      return id if id
      pages = (sitecount / pglimit) + 1
      2.upto(pages) do |i|
        res = @conn.get('/api/v1/sites&limit=' + pglimit.to_s + '?page=' + i.to_s)
        puts "trying to find #{sitename} from page #{i}"
        id = site_data_from_results(res, sitename, 'id')
        return id if id
      end
      nil
    end

    def site_data_from_results(res, sitename, key)
      sites = res['sites']
      sites.each do |site|
        return site[key] if site['site'] == sitename
      end
      nil
    end

    # Gets the key asked for in site data
    # @params [int] site_id the site id
    # re
    def get_site_data(site_id)
      @conn.get('/api/v1/sites/' + site_id.to_s)
    end

    # gets the site id of the 1st one found using the api
    # @returns:: [int] the site id
    def get_a_site_id
      res = @conn.get('/api/v1/sites')
      res['sites'].first['id']
    end

    # Gets the complete list of sites
    def site_list
      page = 1
      not_done = true
      count = 0
      while not_done
        current_path = '/api/v1/sites?page=' << page.to_s
        res = @conn.get(current_path)
        if res['sites'] == []
          not_done = false
        elsif !res['message'].nil?
          puts res['message']
          break
        else
          if page == 1
            count = res['count']
            sites = res['sites']
          else
            res['sites'].each do |site|
              sites << site
            end
          end
        end
        page += 1
      end
      { 'count' => count, 'sites' => sites }
    end

    # Creates a site.
    def create_site(sitename, group_id, install_profile = nil)
      current_path = '/api/v1/sites'
      payload = { 'site_name' => sitename, 'group_ids' => [group_id],
                  'install_profile' => install_profile }.to_json
      @conn.post(current_path, payload)
    end

    # accesssors for backups/restore
    # so that you can do site.backup.list_backups
    def backup
      @conn.backup
    end
  end
end
