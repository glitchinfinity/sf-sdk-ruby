module SFRest
  # Backup a site or restore onto that site
  class Backup
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # cool stuff goes here
    # @param [Integer] site_id the node id of the site node
    # @return [Hash]
    def get_backups(site_id, datum = nil)
      current_path = "/api/v1/sites/#{site_id}/backups"
      pb = SFRest::Pathbuilder.new
      @conn.get URI.parse(pb.build_url_query(current_path, datum)).to_s
    end

    # Deletes a site backup.
    # @param [Integer] site_id Node id of site
    # @param [Integer] backup_id Id of backup to delete
    def delete_backup(site_id, backup_id)
      current_path = "/api/v1/sites/#{site_id}/backups/#{backup_id}"
      @conn.delete(current_path)
    end

    # Backs up a site.
    # @param [Integer] site_id
    # @param [Hash] datum Options to the backup
    # @option datum [String] 'label'
    # @option datum [Url] 'callback_url'
    # @option datum [String] 'callback_method' GET|POST
    # @option datum [Json] 'caller_data' json encoded string
    def create_backup(site_id, datum = nil)
      current_path = "/api/v1/sites/#{site_id}/backup"
      @conn.post(current_path, datum.to_json)
    end

    # Gets a url to download a backup
    # @param [Integer] site_id Node id of site
    # @param [Integer] backup_id Id of backup to delete
    # @param [Integer] lifetime TTL of the url
    def backup_url(site_id, backup_id, lifetime = 60)
      @conn.get("/api/v1/sites/#{site_id}/backups/#{backup_id}/url?lifetime=#{lifetime}")
    end
  end
end
