module SFRest
  # Drive updates on the Site Factory
  class Update
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Gets the status information.
    def status_info
      current_path = '/api/v1/status'
      @conn.get(current_path)
    end

    # Modifies the status information.
    def modify_status(site_creation, site_duplication, domain_management, bulk_operations)
      current_path = '/api/v1/status'
      payload = { 'site_creation' => site_creation,
                  'site_duplication' => site_duplication,
                  'domain_management' => domain_management,
                  'bulk_operations' => bulk_operations }.to_json
      @conn.put(current_path, payload)
    end

    # Lists vcs refs.
    def list_vcs_refs(type = 'sites', stack_id = 1)
      current_path = '/api/v1/vcs?type=' << type << '&stack_id=' << stack_id.to_s
      @conn.get(current_path)
    end

    # Starts an update.
    def start_update(ref)
      if update_version == 'v2'
        raise InvalidApiVersion, 'There is more than one codebase use sfrest.update.update directly.'
      end
      update_data = { scope: 'sites', sites_type: 'code, db', sites_ref: ref }
      update(update_data)
    end

    # Starts an update. The rest api supports the following
    # scope: sites|factory|both (defaults to 'sites')
    # start_time:
    # sites_type: code|code, db| code, db, registry (defaults to 'code, db')
    # factory_type: code|code, db (defaults to 'code, db')
    # sites_ref:
    # factory_ref:
    # This method does not filter or validate so that it can be used for
    # negative cases. (missing data)
    def update(datum)
      validate_request datum
      current_path = "/api/#{update_version}/update"
      payload = datum.to_json
      @conn.post(current_path, payload)
    end

    def validate_request(datum)
      v1_keys = %i[scope sites_ref factory_ref sites_type factory_type db_update_arguments]
      v2_keys = %i[sites factory]
      key_overlap = binding.local_variable_get("#{update_version}_keys") & datum.keys
      raise InvalidDataError, "An invalid stucture was passed to the #{update_version} endpoint" if key_overlap.empty?
    end

    # Gets the list of updates.
    def update_list
      current_path = '/api/v1/update'
      @conn.get(current_path)
    end

    # Gets the progress of an update by id.
    def update_progress(update_id)
      current_path = '/api/v1/update/' + update_id.to_s + '/status'
      @conn.get(current_path)
    end

    # Pauses current update.
    def pause_update
      current_path = '/api/v1/update/pause'
      payload = { 'pause' => true }.to_json
      @conn.post(current_path, payload)
    end

    # Resumes current update.
    def resume_update
      current_path = '/api/v1/update/pause'
      payload = { 'pause' => false }.to_json
      @conn.post(current_path, payload)
    end

    # Determines the api version to use for updates.
    def update_version
      @conn.codebase.list['stacks'].size > 1 ? 'v2' : 'v1'
    end
  end
end
