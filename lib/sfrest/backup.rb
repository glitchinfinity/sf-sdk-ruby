module SFRest
  # Backup a site or restore onto that site
  class Backup
    def initialize(conn)
      @conn = conn
    end

    # cool stuff goes here
    # @param site_nid [int] the node id of the site node
    # @returns backups [Hash]
    def get_backups(site_nid, datum = nil)
      current_path = "/api/v1/sites/#{site_nid}/backups"
      pb = SFRest::Pathbuilder.new
      @conn.get URI.parse(URI.encode(pb.build_url_query(current_path, datum))).to_s
    end

    # Deletes a site backup.
    def delete_backup(site_id, backup_id)
      current_path = "/api/v1/sites/#{site_id}/backups/#{backup_id}"
      @conn.delete(current_path)
    end

    # Backs up a site.
    def create_backup(site_id, datum = nil)
      current_path = "/api/v1/sites/#{site_id}/backup"
      @conn.post(current_path, datum.to_json)
    end

    # Gets a url to download a backup
    def backup_url(site_id, backup_id, lifetime = 60)
      @conn.get("/api/v1/sites/#{site_id}/backups/#{backup_id}/url?lifetime=#{lifetime}")
    end
  end
end
