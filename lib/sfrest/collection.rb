module SFRest
  # Find colletions, return their data.
  class Collection
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # gets the site ID for the site named sitename
    # will page through all the sites available searching for the site
    # @param [String] name the name of the site
    # @return [Integer] the id of sitename
    def get_collection_id(name)
      pglimit = 100
      res = @conn.get('/api/v1/collections&limit=' + pglimit.to_s)
      count = res['count'].to_i
      id = collection_data_from_results(res, name, 'id')
      return id if id

      pages = (count / pglimit) + 1
      2.upto(pages) do |i|
        res = @conn.get('/api/v1/collections&limit=' + pglimit.to_s + '?page=' + i.to_s)
        id = collection_data_from_results(res, name, 'id')
        return id if id
      end
      nil
    end

    # Extract the site data for 'key' based on the site result object
    # @param [Hash] res result from a request to /collections
    # @param [String] name
    # @param [String] key one of the user data returned (id, name, domain...)
    # @return [Object] Integer, String, Array, Hash depending on the collection data
    def collection_data_from_results(res, name, key)
      collections = res['collections']
      collections.each do |collection|
        return collection[key] if collection['name'] == name
      end
      nil
    end

    # Gets the site data for a specific id
    # @param [Integer] id the site id
    # @return [Hash]
    def get_collection_data(id)
      @conn.get('/api/v1/collections/' + id.to_s)
    end

    # gets the site id of the 1st one found using the api
    # @return [Integer] the site id
    def first_collection_id
      res = @conn.get('/api/v1/collections')
      res['collections'].first['id']
    end

    # Gets the complete list of collections
    # Makes multiple requests to the factory to get all the collections on the factory
    # @return [Hash{'count' => Integer, 'sites' => Hash}]
    def collection_list
      page = 1
      not_done = true
      count = 0
      while not_done
        current_path = '/api/v1/collections?page=' << page.to_s
        res = @conn.get(current_path)
        if res['collections'] == []
          not_done = false
        elsif !res['message'].nil?
          return { 'message' => res['message'] }
        elsif page == 1
          count = res['count']
          collections = res['collections']
        else
          res['collections'].each do |collection|
            collections << collection
          end
        end
        page += 1
      end
      { 'count' => count, 'collections' => collections }
    end

    # create a site collection
    # @param [String] name site collection name
    # @param [int|Array] sites nid or array of site nids. First nid is primary
    # @param [int|Array] groups gid or array of group ids.
    # @param [String] internal_domain_prefix optional the prefix for the internal domain
    #                                 defaults to name
    # @return [Hash { "id" => Integer, "name" => String,
    #                 "time" => "2016-11-25T13:18:44+00:00",
    #                 "internal_domain" => String }]
    def create(name, sites, groups, internal_domain_prefix = nil)
      sites = Array(sites)
      groups = Array(groups)
      current_path = '/api/v1/collections'
      payload = { 'name' => name, 'site_ids' => sites, 'group_ids' => groups,
                  'internal_domain_prefix' => internal_domain_prefix }.to_json
      @conn.post(current_path, payload)
    end

    # deletes a site collection
    # performs the same action as deleting in the UI
    # @param [Integer] id the id of the site collection to delete
    # @return [Hash{ "id" => Integer,
    #                "time" => "2016-10-28T09:25:26+00:00",
    #                "deleted" => Boolean,
    #                "message" => String }]
    def delete(id)
      current_path = "/api/v1/collections/#{id}"
      @conn.delete(current_path)
    end

    # adds site(s) to a site collection
    # @param [int] id of the collection to which to add sites
    # @param [int|Array] sites nid or array of site nids.
    # @return [Hash{ "id" => Integer,
    #                "name" => String,
    #                "time" => "2016-10-28T09:25:26+00:00",
    #                "site_ids_added" => Array,
    #                "added" => Boolean,
    #                "message" => String }]
    def add_sites(id, sites)
      sites = Array(sites)
      payload = { 'site_ids' => sites }.to_json
      current_path = "/api/v1/collections/#{id}/add"
      @conn.post(current_path, payload)
    end

    # removes site(s) from a site collection
    # @param [int] id of the collection from which to remove sites
    # @param [int|Array] sites nid or array of site nids.
    # @return [Hash{ "id" => Integer,
    #                "name" => String,
    #                "time" => "2016-10-28T09:25:26+00:00",
    #                "site_ids_removed" => Array,
    #                "removed" => Boolean,
    #                "message" => String }]
    def remove_sites(id, sites)
      sites = Array(sites)
      payload = { 'site_ids' => sites }.to_json
      current_path = "/api/v1/collections/#{id}/remove"
      @conn.post(current_path, payload)
    end

    # sets a site to be a primary site in a site collection
    # @param [int] id of the collection where the primary site is being changed
    # @param [int] site nid to become the primary site
    # @return [Hash{ "id" => Integer,
    #                "name" => String,
    #                "time" => "2016-10-28T09:25:26+00:00",
    #                "primary_site_id": Integer,
    #                "switched" => Boolean,
    #                "message" => String }]
    def set_primary_site(id, site)
      payload = { 'site_id' => site }.to_json
      current_path = "/api/v1/collections/#{id}/set-primary"
      @conn.post(current_path, payload)
    end
  end
end
