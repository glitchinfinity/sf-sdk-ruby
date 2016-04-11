module SFRest
  # Get all the audit devents.
  class Audit
    def initialize(conn)
      @conn = conn
    end

    # Lists audit events.
    def list_audit_events
      current_path = '/api/v1/audit'
      @conn.get(current_path)
    end
  end
end
