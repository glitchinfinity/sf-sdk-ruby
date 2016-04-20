require 'spec_helper'

describe SFRest::Backup do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_backups' do
    path = '/api/v1/sites'

    it 'calls the get backups endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      nid = rand 10**5
      res = @conn.backup.get_backups nid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{nid}/backups"
      expect(res['method']).to eq 'get'
    end
  end

  describe '#delete_backups' do
    path = '/api/v1/sites'

    it 'calls the delete backups endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      nid = rand 10**5
      bid = rand 10**5
      res = @conn.backup.delete_backup nid, bid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{nid}/backups/#{bid}"
      expect(res['method']).to eq 'delete'
    end
  end

  describe '#create_backups' do
    path = '/api/v1/sites'

    it 'calls the create backups endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      nid = rand 10**5
      res = @conn.backup.create_backup nid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{nid}/backup"
      expect(res['method']).to eq 'post'
    end

    it 'can backup with options' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      nid = rand 10**5
      datum = { label: 'foo', callback_data: 'bar' }
      res = @conn.backup.create_backup nid, datum
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{nid}/backup"
      expect(JSON(res['body'])['label']).to eq 'foo'
      expect(JSON(res['body'])['callback_data']).to eq 'bar'
      expect(res['method']).to eq 'post'
    end
  end
end
