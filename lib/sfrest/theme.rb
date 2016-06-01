module SFRest
  # Tell the Factory that there is theme work to do
  class Theme
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Sends a theme notification.
    def send_theme_notification(scope = 'site', event = 'modify', nid = 0, theme = '')
      current_path = '/api/v1/theme/notification'
      payload = { 'scope' => scope, 'event' => event, 'nid' => nid, 'theme' => theme }.to_json
      @conn.post(current_path, payload)
    end

    # Processes a theme notification.
    def process_theme_notification(sitegroup_id = 0)
      current_path = '/api/v1/theme/process'
      payload = { 'sitegroup_id' => sitegroup_id }.to_json
      @conn.post(current_path, payload)
    end
  end
end
