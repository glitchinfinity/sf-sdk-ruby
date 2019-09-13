# frozen_string_literal: true

module SFRest
  # Get all the audit devents.
  class Audit
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Lists audit events.
    # @return [Hash{'count' => Integer, 'changes' => [Hash, Hash]}]
    def list_audit_events
      current_path = '/api/v1/audit'
      @conn.get(current_path)
    end
  end
end
