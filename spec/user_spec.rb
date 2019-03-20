require 'spec_helper'

describe SFRest::User do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_user_id' do
    users_data = generate_users_data
    user = users_data['users'].sample
    username = user['name']
    userid = user['uid']
    user_count = users_data['count']
    users_data2 = generate_users_data
    user2 = users_data2['users'].sample
    username2 = user2['name']
    userid2 = user2['uid']
    user_count = users_data2['count'] + user_count + 100
    users_data['count'] = user_count
    users_data2['count'] = user_count

    it 'can get a user id' do
      stub_factory '/api/v1/users', users_data.to_json
      expect(@conn.user.get_user_id(username)).to eq userid
    end
    it 'can make more than one request to get a user id' do
      stub_factory '/api/v1/users', [users_data.to_json,
                                     users_data2.to_json,
                                     { 'count' => user_count, 'users' => [] }.to_json]
      expect(@conn.user.get_user_id(username2)).to eq userid2
    end
    it 'returns nothing on not found' do
      stub_factory '/api/v1/users', users_data.to_json
      expect(@conn.user.get_user_id('boogah123')).to eq nil
    end
  end

  describe '#user_data_from_results' do
    users_data = generate_users_data
    user = users_data['users'].sample
    username = user['name']
    key = user.keys.sample
    target_value = user[key]
    it 'can get a specific piece of user data' do
      expect(@conn.user.user_data_from_results(users_data, username, key)).to eq target_value
    end
  end

  describe '#get_user_data' do
    user = generate_user_data
    userid = user['uid']
    it 'can get a user data' do
      stub_factory '/api/v1/users/' + userid.to_s, user.to_json
      expect(@conn.user.get_user_data(userid)['uid']).to eq userid
    end
  end

  describe '#user_list' do
    users_data = generate_users_data
    user_count = users_data['count']
    users = users_data['users']
    users_data2 = generate_users_data
    users2 = users_data2['users']
    user_count = users_data2['count'] + user_count
    users_data['count'] = user_count
    users_data2['count'] = user_count

    it 'can get a set of users data' do
      stub_factory '/api/v1/users', [users_data.to_json, users_data2.to_json,
                                     { 'count' => user_count, 'users' => [] }.to_json]
      res = @conn.user.user_list
      expect(res['count']).to eq user_count
      expect(res['users'].to_json).to eq((users + users2).to_json)
    end

    it 'returns the error message from the api' do
      stub_factory '/api/v1/users', { 'message' => 'Danger Will Robinson!' }.to_json
      res = @conn.user.user_list
      expect(res['message']).to eq 'Danger Will Robinson!'
    end
  end
  describe '#create_user' do
    path = '/api/v1/users'

    it 'calls the create user endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      uname = SecureRandom.urlsafe_base64
      umail = SecureRandom.urlsafe_base64 + '@example.com'
      res = @conn.user.create_user uname, umail
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['name']).to eq uname
      expect(JSON(res['body'])['mail']).to eq umail
      expect(res['method']).to eq 'post'
    end
  end

  describe '#update_user' do
    path = '/api/v1/users'

    it 'calls the update user endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      uid = rand 1000
      res = @conn.user.update_user uid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{uid}/update"
      expect(res['method']).to eq 'put'
    end

    it 'passes new data to the user endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      uid = rand 1000
      uname = SecureRandom.urlsafe_base64
      umail = SecureRandom.urlsafe_base64 + '@example.com'
      datum = { name: uname, mail: umail }
      res = @conn.user.update_user uid, datum
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{uid}/update"
      expect(JSON(res['body'])['name']).to eq uname
      expect(JSON(res['body'])['mail']).to eq umail
      expect(res['method']).to eq 'put'
    end
  end

  describe '#delete_user' do
    path = '/api/v1/users'

    it 'calls the delete user endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      rid = rand 1000
      res = @conn.user.delete_user rid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{rid}"
      expect(res['method']).to eq 'delete'
    end
  end

  describe '#regenerate_apikey' do
    path = '/api/v1/users'

    it 'calls the regenerate apikey endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      uid = rand 1000
      res = @conn.user.regenerate_apikey uid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{uid}/api-keys"
      expect(res['method']).to eq 'delete'
    end

    it 'calls the regenerate apikeys endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      res = @conn.user.regenerate_apikeys
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/all/api-keys"
      expect(res['method']).to eq 'delete'
    end
  end
end
