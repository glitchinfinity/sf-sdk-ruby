module SFRest
  # Perform actions against variables in the Factory
  class Variable
    def initialize(conn)
      @conn = conn
    end

    # Gets the list of variables.
    def variable_list
      current_path = '/api/v1/variables'
      @conn.get(current_path)
    end

    # Gets the value of a specific variable.
    def get_variable(name)
      current_path = '/api/v1/variables?name=' << name
      @conn.get(current_path)
    end

    # Sets the key and value of a variable.
    def set_variable(name, value)
      current_path = '/api/v1/variables'
      payload = { 'name' => name, 'value' => value }.to_json
      @conn.put(current_path, payload)
    end
  end
end
