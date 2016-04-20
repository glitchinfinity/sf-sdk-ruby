require 'spec_helper'

describe SFRest::Variable do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#variable_list' do
    path = '/api/v1/variables'

    it 'can list variables' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.variable.variable_list
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'get'
    end
  end

  describe '#get_variable' do
    path = '/api/v1/variables'

    it 'get a variable value' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      vname = SecureRandom.urlsafe_base64
      res = @conn.variable.get_variable vname
      uri = URI res['uri']
      query_hash = URI.decode_www_form(uri.query).to_h
      expect(uri.path).to eq path
      expect(query_hash['name']).to eq vname
      expect(res['method']).to eq 'get'
    end
  end

  describe '#set_variable' do
    path = '/api/v1/variables'

    it 'can set a variable' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      vname = SecureRandom.urlsafe_base64
      vval = SecureRandom.urlsafe_base64
      res = @conn.variable.set_variable vname, vval
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'put'
      expect(JSON(res['body'])['name']).to eq vname
    end
  end
end
