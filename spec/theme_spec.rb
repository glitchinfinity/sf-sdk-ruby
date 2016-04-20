require 'spec_helper'

describe SFRest::Theme do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#send_theme_notification' do
    path = '/api/v1/theme/notification'

    it 'send the default notifcation' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.theme.send_theme_notification
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['scope']).to eq 'site'
      expect(JSON(res['body'])['event']).to eq 'modify'
      expect(JSON(res['body'])['nid']).to eq 0
      expect(JSON(res['body'])['theme']).to eq ''
    end

    it 'sends a non default notifcation' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      scope = SecureRandom.urlsafe_base64
      event = SecureRandom.urlsafe_base64
      theme = SecureRandom.urlsafe_base64
      nid = rand 1000
      res = @conn.theme.send_theme_notification scope, event, nid, theme
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['scope']).to eq scope
      expect(JSON(res['body'])['event']).to eq event
      expect(JSON(res['body'])['nid']).to eq nid
      expect(JSON(res['body'])['theme']).to eq theme
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
end
