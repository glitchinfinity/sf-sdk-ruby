# frozen_string_literal: true

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
      raise InvalidApiVersion, staging_versions unless staging_versions.include? 1

      payload = { 'to_env' => to_env, 'sites' => sites,
                  'detailed_status' => email_site_status,
                  'skip_gardener' => skip_gardener }.to_json
      @conn.post('/api/v1/stage', payload)
    end

    # Stage a site using the new method
    # @param [String] to_env the name of of target env. defaults to test
    # @param [Array] sites Array of site nids to stage
    # @param [Boolean] email_site_status send an email about the staging status of each site
    # @param [Boolean] wipe_target_environment recreate the target stage wiping all data
    # @param [synchronize_all_users] only stage the user accounts required for the related collections and groups
    # @param [Array] Stacks Array of stack ids to wipe
    #
    # @return [Integer] Id of the staging task created.
    # rubocop:disable Metrics/ParameterLists
    def enhanced_stage(env: 'test',
                       sites: nil,
                       email_site_status: false,
                       wipe_target_environment: false,
                       synchronize_all_users: true,
                       wipe_stacks: nil)
      raise InvalidApiVersion, staging_versions unless staging_versions.include? 2

      payload = { 'to_env' => env, 'sites' => sites,
                  'detailed_status' => email_site_status,
                  'wipe_target_environment' => wipe_target_environment,
                  'synchronize_all_users' => synchronize_all_users,
                  'wipe_stacks' => wipe_stacks }.to_json
      @conn.post('/api/v2/stage', payload)
    end
    # rubocop:enable Metrics/ParameterLists

    # Query for available staging environments
    #
    # @return environments
    def list_staging_environments
      current_path = "/api/v#{staging_versions.sample}/stage"
      @conn.get(current_path)
    end

    # determine what version are available for staging
    # @return [Array] Array of available api endpoints
    def staging_versions
      possible_versions = [1, 2]
      @versions ||= []
      possible_versions.each do |version|
        begin
          @conn.get "/api/v#{version}/stage"
          @versions.push version
        rescue SFRest::InvalidResponse
          nil
        end
      end
      @versions
    end
  end
end
