module SFRest
  # Find Staging envs and stage a set of sites
  class Stage
    def initialize(conn)
      @conn = conn
    end

    # Stage a site
    # @param to_env [string] the name of of target env. defaults to test
    # @param sites [array] Array of site nids to stage
    # @param email_site_status [boolean] send an email about the staging status of each site
    # @param skip_gardener [boolean] skip staging the gardener and only stage the sites
    #
    # @returns task_id [int] Id of the staging task created.
    def stage(to_env = 'test', sites = nil, email_site_status = false, skip_gardener = false)
      payload = { 'to_env' => to_env, 'sites' => sites,
                  'detailed_status' => email_site_status,
                  'skip_gardener' => skip_gardener }.to_json
      @conn.post('/api/v1/stage', payload)
    end

    # Query for available staging environments
    #
    # @returns environments
    def list_staging_environments
      current_path = '/api/v1/stage'
      @conn.get(current_path)
    end
  end
end
