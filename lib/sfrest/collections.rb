module SFRest
  # Find colletions, return their data.
  class Collections
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
  end
end
