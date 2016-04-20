require 'spec_helper'

describe SFRest::Group do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#group_list' do
    groups_data = generate_groups_data
    group_count = groups_data['count']
    groups = groups_data['groups']
    groups_data2 = generate_groups_data
    groups2 = groups_data2['groups']
    group_count = groups_data2['count'] + group_count
    groups_data['count'] = group_count
    groups_data2['count'] = group_count

    it 'can get a set of groups data' do
      stub_factory '/api/v1/groups',
                   [groups_data.to_json,
                    groups_data2.to_json,
                    { 'count' => group_count, 'groups' => [] }.to_json]
      res = @conn.group.group_list
      expect(res['count']).to eq group_count
      expect(res['groups'].to_json).to eq((groups + groups2).to_json)
    end

    it 'returns the error message from the api' do
      stub_factory '/api/v1/groups', { 'message' => 'Danger Will Robinson!' }.to_json
      res = @conn.group.group_list
      expect(res['message']).to eq 'Danger Will Robinson!'
    end
  end

  describe '#create_group' do
    path = '/api/v1/groups'

    it 'calls the create group endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      gname = SecureRandom.urlsafe_base64
      res = @conn.group.create_group gname
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['group_name']).to eq gname
      expect(res['method']).to eq 'post'
    end
  end

  describe '#get_group' do
    path = '/api/v1/groups'

    it 'calls the get group endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      gid = rand 10**5
      res = @conn.group.get_group gid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}"
      expect(res['method']).to eq 'get'
    end
  end
end
