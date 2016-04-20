require 'spec_helper'

describe SFRest::Role do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_role_id' do
    roles_data = generate_roles_data
    role_ary = roles_data['roles'].to_a.sample
    role = { role_ary[0] => role_ary[1] }
    roleid = role.keys.sample
    rolename = role[roleid]
    role_count = roles_data['count']
    roles_data2 = generate_roles_data
    role_ary = roles_data2['roles'].to_a.sample
    role2 = { role_ary[0] => role_ary[1] }
    roleid2 = role2.keys.sample
    rolename2 = role2[roleid2]
    role_count = roles_data2['count'] + role_count + 100
    roles_data['count'] = role_count
    roles_data2['count'] = role_count

    it 'can get a role id' do
      stub_factory '/api/v1/roles', roles_data.to_json
      expect(@conn.role.get_role_id(rolename)).to eq roleid
    end
    it 'can make more than one request to get a role id' do
      stub_factory '/api/v1/roles',
                   [roles_data.to_json,
                    roles_data2.to_json,
                    { 'count' => role_count, 'roles' => [] }.to_json]
      expect(@conn.role.get_role_id(rolename2)).to eq roleid2
    end
    it 'returns nothing on not found' do
      stub_factory '/api/v1/roles', roles_data.to_json
      expect(@conn.role.get_role_id('boogah123')).to eq nil
    end
  end

  describe '#role_data_from_results' do
    roles_data = generate_roles_data
    role_ary = roles_data['roles'].to_a.sample
    rolename = role_ary[1]
    target_value = role_ary[0]
    it 'can get a specific piece of role data' do
      expect(@conn.role.role_data_from_results(roles_data, rolename)).to eq target_value
    end
  end

  describe '#role_data' do
    roles_data = generate_roles_data
    role_ary = roles_data['roles'].to_a.sample
    role = { 'role_id' => role_ary[0], 'role_name' => role_ary[1] }
    roleid = role_ary[0]
    it 'can get a role data' do
      stub_factory '/api/v1/roles/' + roleid.to_s, role.to_json
      @conn.role.role_data(roleid).inspect
      expect(@conn.role.role_data(roleid)['role_id']).to eq roleid
    end
  end

  describe '#role_list' do
    roles_data = generate_roles_data
    role_count = roles_data['count']
    roles = roles_data['roles']
    roles_data2 = generate_roles_data
    roles2 = roles_data2['roles']
    role_count = roles_data2['count'] + role_count
    roles_data['count'] = role_count
    roles_data2['count'] = role_count

    it 'can get a set of roles data' do
      stub_factory '/api/v1/roles',
                   [roles_data.to_json,
                    roles_data2.to_json,
                    { 'count' => role_count, 'roles' => [] }.to_json]
      res = @conn.role.role_list
      expect(res['count']).to eq role_count
      expect(res['roles'].to_json).to eq roles.merge(roles2).to_json
    end
    it 'returns the error message from the api' do
      stub_factory '/api/v1/roles', { 'message' => 'Danger Will Robinson!' }.to_json
      res = @conn.role.role_list
      expect(res['message']).to eq 'Danger Will Robinson!'
    end
  end

  describe '#create_role' do
    path = '/api/v1/roles'

    it 'calls the create role endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      rname = SecureRandom.urlsafe_base64
      res = @conn.role.create_role rname
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['name']).to eq rname
      expect(res['method']).to eq 'post'
    end
  end

  describe '#update_role' do
    path = '/api/v1/roles'

    it 'calls the update role endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      rid = rand 1000
      rname = SecureRandom.urlsafe_base64
      res = @conn.role.update_role rid, rname
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{rid}/update"
      expect(JSON(res['body'])['new_name']).to eq rname
      expect(res['method']).to eq 'put'
    end
  end

  describe '#delete_role' do
    path = '/api/v1/roles'

    it 'calls the delete role endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      rid = rand 1000
      res = @conn.role.delete_role rid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{rid}"
      expect(res['method']).to eq 'delete'
    end
  end
end
