module SFRest
  # Find Staging envs and stage a set of sites
  class Stage
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Stage a site
    # @param [String] to_env the name of of target env. defaults to test
    # @param [Array] sites Array of site nids to stage
    # @param [Boolean] email_site_status send an email about the staging status of each site
    # @param [Boolean] skip_gardener skip staging the gardener and only stage the sites
    #
    # @return [Integer] Id of the staging task created.
    def stage(to_env = 'test', sites = nil, email_site_status = false, skip_gardener = false)
      payload = { 'to_env' => to_env, 'sites' => sites,
                  'detailed_status' => email_site_status,
                  'skip_gardener' => skip_gardener }.to_json
      @conn.post('/api/v1/stage', payload)
    end

    # Query for available staging environments
    #
    # @return environments
    def list_staging_environments
      current_path = '/api/v1/stage'
      @conn.get(current_path)
    end
  end
end
