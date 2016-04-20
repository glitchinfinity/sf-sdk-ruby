require 'spec_helper'

describe SFRest::Update do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#status_info' do
    path = '/api/v1/status'

    it 'can get status' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.status_info
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'get'
    end
  end

  describe '#modify_status' do
    path = '/api/v1/status'

    it 'can set maintenance mode' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.modify_status 'on', 'on', 'on', 'on'
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['site_creation']).to eq 'on'
      expect(JSON(res['body'])['site_duplication']).to eq 'on'
      expect(JSON(res['body'])['domain_management']).to eq 'on'
      expect(JSON(res['body'])['bulk_operations']).to eq 'on'
      expect(res['method']).to eq 'put'
    end
  end

  describe '#process_theme_notification' do
    path = '/api/v1/theme/process'

    it 'can process notifications' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.theme.process_theme_notification
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['sitegroup_id']).to eq 0
    end

    it 'can process sitegroup notifications' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      sid = rand 1000
      res = @conn.theme.process_theme_notification sid
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['sitegroup_id']).to eq sid
    end
  end

  describe '#start_update' do
    path = '/api/v1/update'

    it 'can start an update' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      ref = SecureRandom.urlsafe_base64
      res = @conn.update.start_update ref
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['scope']).to eq 'sites'
      expect(JSON(res['body'])['sites_type']).to eq 'code, db'
      expect(JSON(res['body'])['sites_ref']).to eq ref
      expect(res['method']).to eq 'post'
    end
  end

  describe '#list_vcs_refs' do
    path = '/api/v1/vcs'

    it 'can list vcs refs' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.list_vcs_refs
      uri = URI res['uri']
      query_hash = URI.decode_www_form(uri.query).to_h
      expect(uri.path).to eq path
      expect(query_hash['type']).to eq 'sites'
      expect(res['method']).to eq 'get'
    end

    it 'can list factory vcs refs' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.list_vcs_refs 'factory'
      uri = URI res['uri']
      query_hash = URI.decode_www_form(uri.query).to_h
      expect(uri.path).to eq path
      expect(query_hash['type']).to eq 'factory'
      expect(res['method']).to eq 'get'
    end
  end

  describe '#update_list' do
    path = '/api/v1/update'

    it 'list updates' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.update_list
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'get'
    end
  end

  describe '#update_progress' do
    path = '/api/v1/update'

    it 'get the status of an update' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      upid = rand 1000
      res = @conn.update.update_progress upid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{upid}/status"
      expect(res['method']).to eq 'get'
    end
  end

  describe '#pause_update' do
    path = '/api/v1/update'

    it 'can pause updates' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.pause_update
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/pause"
      expect(JSON(res['body'])['pause']).to eq true
      expect(res['method']).to eq 'post'
    end
  end

  describe '#resume_update' do
    path = '/api/v1/update'

    it 'can resume updates' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.resume_update
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/pause"
      expect(JSON(res['body'])['pause']).to eq false
      expect(res['method']).to eq 'post'
    end
  end
end
