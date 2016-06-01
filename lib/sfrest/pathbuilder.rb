module SFRest
  # make a url querypath
  # so that if the are multiple items in a get request
  # we can get a path like /api/v1/foo?bar=boo&bat=gah ...
  class Pathbuilder
    # build a get query
    # @param [String] current_path the uri like /api/v1/foo
    # @param [Hash] datum k,v hash of get query param and value
    def build_url_query(current_path, datum = nil)
      unless datum.nil?
        current_path += '?'
        datum.each do |key, value|
          current_path += '&' if needs_new_parameter? current_path
          current_path += key.to_s + '=' + value.to_s
        end
      end
      current_path
    end

    private def needs_new_parameter?(path)
      path[-1, 1] != '?' # if path has '?' then we need to create a new parameter
    end
  end
end
