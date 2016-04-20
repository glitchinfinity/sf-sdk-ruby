require 'spec_helper'

describe SFRest::Stage do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#list_staging_environments' do
    path = '/api/v1/stage'

    it 'calls the get list envs endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.stage.list_staging_environments
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'get'
    end
  end

  describe '#stage' do
    path = '/api/v1/stage'

    it 'calls the staging endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      to_env = SecureRandom.urlsafe_base64
      res = @conn.stage.stage to_env
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['to_env']).to eq to_env
      expect(res['method']).to eq 'post'
    end
  end
end
