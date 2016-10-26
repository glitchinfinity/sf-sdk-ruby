module SFRest
  # Find Staging envs and stage a set of sites
  class Domains
    # @param [SFRest::Connection] conn
    def initialize(conn)
      @conn = conn
    end

    # List the domains on a node
    # @param [Integer] node_id The id of the node.
    #
    # @return [Array] domains that are on the node.
    def list(node_id)
      current_path = "/api/v1/domains/#{node_id}"
      response = @conn.get(current_path)
      response['domains'] if response.key?('domains')
    end

    # Add a domain
    # @param [Integer] node_id The id of the node to which add a domain
    # @param [String] domain_name domain to add. e.g. www.example.com
    #
    # @return [Hash] response from add request.
    # {  "node_type": "site_collection",
    #    "domain": "www.domaintoadd.com",
    #    "added": true,
    #    "messages": [
    #       "Your domain name was successfully added to the site collection."
    #        ]
    # }
    def add(node_id, domain_name)
      payload = { 'domain_name' => domain_name }.to_json
      @conn.post("/api/v1/domains/#{node_id}/add", payload)
    end

    # Remove a domain
    # @param [Integer] node_id The id of the node to which remove a domain
    # @param [String] domain_name domain to remove. e.g. www.example.com
    #
    # @return [Hash] response from delete request.
    # {  "node_type": "site_collection",
    #    "domain": "www.domaintoadd.com",
    #    "removed": true,
    #    "messages": [
    #       "Your domain name was successfully removed from the site collection."
    #        ]
    # }
    def delete(node_id, domain_name)
      payload = { 'domain_name' => domain_name }.to_json
      @conn.post("/api/v1/domains/#{node_id}/remove", payload)
    end
  end
end
