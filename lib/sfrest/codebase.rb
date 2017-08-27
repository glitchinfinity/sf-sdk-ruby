module SFRest
  # List codebases on the
  class Codebase
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # Lists the codebases
    # @return [Hash] A hash of codebases configured for the factory
    # { "stacks" => { 1 => "abcde", 2 => 'fghij' } }
    def list
      @conn.get('/api/v1/stacks')
    end
  end
end
