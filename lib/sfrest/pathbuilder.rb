# frozen_string_literal: true

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
        current_path += URI.encode_www_form datum
      end
      current_path
    end
  end
end
