require 'spec_helper'

describe SFRest::Stage do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#staging_versions' do
    path = '/api/.*/stage'

    it 'gets the valid staging verions' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return(body: { environments: { test: 'test' } }.to_json)
      versions = @conn.stage.staging_versions
      expect(versions).to eq [1, 2]
    end

    it 'gets only the right staging version' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_raise(SFRest::InvalidResponse).then
        .to_return(body: { environments: { test: 'test' } }.to_json)
      versions = @conn.stage.staging_versions
      expect(versions).to eq [2]

      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return(body: { environments: { test: 'test' } }.to_json).then
        .to_raise(SFRest::InvalidResponse)
      versions = @conn.stage.staging_versions
      expect(versions).to eq [1]
    end
  end

  describe '#list_staging_environments' do
    path = '/api/v1/stage'

    it 'calls the get list envs endpoint' do
      stub_factory path, { 'environments' => { test: 'test' } }.to_json
      res = @conn.stage.list_staging_environments
      expect(res['environments']).to eq('test' => 'test')
    end
  end

  describe '#stage' do
    path = '/api/v1/stage'

    it 'calls the original staging endpoint' do
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

  describe '#enhanced_stage' do
    path = '/api/v2/stage'

    it 'calls the updated staging endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      to_env = SecureRandom.urlsafe_base64
      res = @conn.stage.enhanced_stage env: to_env
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['to_env']).to eq to_env
      expect(res['method']).to eq 'post'
    end
  end
end
