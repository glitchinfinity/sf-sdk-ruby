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
    path = '/api/v(1|2)/update'
    stacks_path = '/api/v1/stacks'
    it 'can start an update' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde' } }.to_json)
      ref = SecureRandom.urlsafe_base64
      res = @conn.update.start_update ref
      uri = URI res['uri']
      expect(uri.path).to match path
      expect(JSON(res['body'])['scope']).to eq 'sites'
      expect(JSON(res['body'])['sites_type']).to eq 'code, db'
      expect(JSON(res['body'])['sites_ref']).to eq ref
      expect(res['method']).to eq 'post'
    end

    it 'cannot update a multistack' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde', 2 => 'fghij' } }.to_json)
      ref = SecureRandom.urlsafe_base64
      expect { @conn.update.start_update ref }.to raise_error SFRest::InvalidApiVersion
    end
  end

  describe '#update' do
    path = '/api/v(1|2)/update'
    stacks_path = '/api/v1/stacks'
    it 'can start a multistack update' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde', 2 => 'fghij' } }.to_json)
      ref = SecureRandom.urlsafe_base64
      res = @conn.update.update sites: [{ name: 'foo', ref: ref }]
      uri = URI res['uri']
      expect(uri.path).to match path
      expect(JSON(res['body'])['sites']).to eq ['name' => 'foo', 'ref' => ref]
      expect(res['method']).to eq 'post'
    end

    it 'can start a single stack update' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde' } }.to_json)
      ref = SecureRandom.urlsafe_base64
      res = @conn.update.update scope: 'sites', sites_ref: ref, sites_type: 'code, db'
      uri = URI res['uri']
      expect(uri.path).to match path
      expect(JSON(res['body'])['scope']).to eq 'sites'
      expect(JSON(res['body'])['sites_type']).to eq 'code, db'
      expect(JSON(res['body'])['sites_ref']).to eq ref
    end

    it 'can not start an update on the wrong version' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde' } }.to_json)
      ref = SecureRandom.urlsafe_base64
      expect { @conn.update.update sites: [{ name: 'foo', ref: ref }] }.to raise_error SFRest::InvalidDataError
    end
  end

  describe '#update_version' do
    stacks_path = '/api/v1/stacks'
    it 'returns v1 if 1 stack' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde' } }.to_json)
      expect(@conn.update.update_version).to eq 'v1'
    end

    it 'returns v2 if 2 stacks' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde', 2 => 'fghij' } }.to_json)
      expect(@conn.update.update_version).to eq 'v2'
    end
  end

  describe '#validate_request' do
    stacks_path = '/api/v1/stacks'
    v1_datum = { scope: 'both',
                 sites_ref: 'tags/1234',
                 factory_ref: 'tags/2345',
                 sites_type: 'code',
                 factory_type: 'code, db',
                 db_update_arguments: 'arg1 arg2' }
    v2_datum = { sites: [{ name: 's3tg42', ref: 'tags/12345', type: 'code', db_update_arguments: 'arg1 arg2' }],
                 factory: { ref: 'tags/5678', type: 'code' } }

    it 'will use a v1 data set' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde' } }.to_json)
      expect(@conn.update.validate_request(v1_datum)).to be nil
    end

    it 'will raise if v2 tries to use v1 data' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde', 2 => 'fghij' } }.to_json)
      expect { @conn.update.validate_request(v1_datum) }.to raise_error SFRest::InvalidDataError
    end

    it 'will use a v2 data set' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde', 2 => 'fghij' } }.to_json)
      expect(@conn.update.validate_request(v2_datum)).to be nil
    end

    it 'will raise if v1 tries to use v2 data' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{stacks_path}/)
        .with(headers: @mock_headers)
        .to_return(body: { 'stacks' => { 1 => 'abcde' } }.to_json)
      expect { @conn.update.validate_request(v2_datum) }.to raise_error SFRest::InvalidDataError
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

    it 'can list refs refs on other stacks' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.update.list_vcs_refs 'sites', 2
      uri = URI res['uri']
      query_hash = URI.decode_www_form(uri.query).to_h
      expect(uri.path).to eq path
      expect(query_hash['type']).to eq 'sites'
      expect(query_hash['stack_id']).to eq '2'
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
