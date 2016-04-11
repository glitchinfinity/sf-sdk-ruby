module SFRest
  # Backup a site or restore onto that site
  class Backup
    def initialize(conn)
      @conn = conn
    end

    # cool stuff goes here
    # @param site_nid [int] the node id of the site node
    # @returns backups [Hash]
    def get_backups(site_nid)
      @conn.get("/api/v1/sites/#{site_nid}/backups")
    end

    # Deletes a site backup.
    def delete_backup(site_id, backup_id)
      current_path = "/api/v1/sites/#{site_id}/backups/#{backup_id}"
      @conn.delete(current_path)
    end

    # Backs up a site.
    def create_backup(site_id)
      current_path = "/api/v1/sites/#{site_id}/backup"
      payload = {}.to_json
      @conn.post(current_path, payload)
    end
  end
end
