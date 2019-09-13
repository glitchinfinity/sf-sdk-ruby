# frozen_string_literal: true

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
      stub_group_request(path)
      gname = SecureRandom.urlsafe_base64
      res = @conn.group.create_group gname
      uri = URI res['uri']
      expect(uri.path).to eq path
      expect(JSON(res['body'])['group_name']).to eq gname
      expect(res['method']).to eq 'post'
    end
  end

  describe '#rename_group' do
    path = '/api/v1/groups'

    it 'calls the rename group endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      gname = SecureRandom.urlsafe_base64
      res = @conn.group.rename_group(gid, gname)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/update"
      expect(JSON(res['body'])['group_name']).to eq gname
      expect(res['method']).to eq 'put'
    end
  end

  describe '#delete_group' do
    path = '/api/v1/groups'

    it 'calls the delete group endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      res = @conn.group.delete_group gid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}"
      expect(res['method']).to eq 'delete'
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

  describe '#get_members' do
    path = '/api/v1/groups'
    it 'calls the get members endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      res = @conn.group.get_members gid
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/members"
      expect(res['method']).to eq 'get'
    end
  end

  describe '#add_members' do
    path = '/api/v1/groups'
    it 'calls the add members endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      uids = [1, 2, 42]
      res = @conn.group.add_members(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/members"
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['uids']).to eq uids
    end

    it 'can add stringy members' do
      stub_group_request(path)
      gid = rand 10**5
      uids = %w[1 2 42]
      res = @conn.group.add_members(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/members"
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['uids']).to_not eq uids
      expect(JSON(res['body'])['uids']).to eq uids.map(&:to_i)
    end
  end

  describe '#remove_members' do
    path = '/api/v1/groups'
    it 'calls the remove members endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      uids = [1, 2, 42]
      res = @conn.group.remove_members(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/members"
      expect(res['method']).to eq 'delete'
      expect(JSON(res['body'])['uids']).to eq uids
    end

    it 'can remove stringy members' do
      stub_group_request(path)
      gid = rand 10**5
      uids = %w[1 2 42]
      res = @conn.group.remove_members(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/members"
      expect(res['method']).to eq 'delete'
      expect(JSON(res['body'])['uids']).to_not eq uids
      expect(JSON(res['body'])['uids']).to eq uids.map(&:to_i)
    end
  end

  describe '#promote_to_admins' do
    path = '/api/v1/groups'
    it 'calls the promote to admins endpoint' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      gid = rand 10**5
      uids = [1, 2, 42]
      res = @conn.group.promote_to_admins(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/admins"
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['uids']).to eq uids
    end

    it 'can promote stringy admins' do
      stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
        .with(headers: @mock_headers)
        .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
      gid = rand 10**5
      uids = %w[1 2 42]
      res = @conn.group.promote_to_admins(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/admins"
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['uids']).to_not eq uids
      expect(JSON(res['body'])['uids']).to eq uids.map(&:to_i)
    end
  end

  describe '#demote_from_admins' do
    path = '/api/v1/groups'
    it 'calls the demote from admins endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      uids = [1, 2, 42]
      res = @conn.group.demote_from_admins(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/admins"
      expect(res['method']).to eq 'delete'
      expect(JSON(res['body'])['uids']).to eq uids
    end

    it 'can demote stringy admins' do
      stub_group_request(path)
      gid = rand 10**5
      uids = %w[1 2 42]
      res = @conn.group.demote_from_admins(gid, uids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/admins"
      expect(res['method']).to eq 'delete'
      expect(JSON(res['body'])['uids']).to_not eq uids
      expect(JSON(res['body'])['uids']).to eq uids.map(&:to_i)
    end
  end

  describe '#add_sites' do
    path = '/api/v1/groups'
    it 'calls the add sites endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      site_ids = [1, 2, 42]
      res = @conn.group.add_sites(gid, site_ids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/sites"
      expect(res['method']).to eq 'post'
      expect(JSON(res['body'])['site_ids']).to eq site_ids
    end
  end

  describe '#remove_sites' do
    path = '/api/v1/groups'
    it 'calls the remove sites endpoint' do
      stub_group_request(path)
      gid = rand 10**5
      site_ids = [1, 2, 42]
      res = @conn.group.remove_sites(gid, site_ids)
      uri = URI res['uri']
      expect(uri.path).to eq "#{path}/#{gid}/sites"
      expect(res['method']).to eq 'delete'
      expect(JSON(res['body'])['site_ids']).to eq site_ids
    end
  end

  describe '#group_data_from_results' do
    groups_data = generate_groups_data
    group = groups_data['groups'].sample
    groupname = group['group_name']
    key = group.keys.sample
    target_value = group[key]
    it 'can get a specific piece of site data' do
      expect(@conn.group.group_data_from_results(groups_data, groupname, key)).to eq target_value
    end
  end

  describe '#get_group_id' do
    groups_data = generate_groups_data
    group = groups_data['groups'].sample
    groupname = group['group_name']
    groupid = group['group_id']
    group_count = groups_data['count']
    groups_data2 = generate_groups_data
    group2 = groups_data2['groups'].sample
    groupname2 = group2['group_name']
    groupid2 = group2['group_id']
    group_count = groups_data2['count'] + group_count + 100
    groups_data['count'] = group_count
    groups_data2['count'] = group_count

    it 'can get a group id' do
      stub_factory '/api/v1/groups', [groups_data.to_json,
                                      groups_data2.to_json,
                                      { 'count' => group_count, 'groups' => [] }.to_json]
      expect(@conn.group.get_group_id(groupname)).to eq groupid
    end

    it 'can make more than one request to get a group id' do
      stub_factory '/api/v1/groups', [groups_data.to_json,
                                      groups_data2.to_json,
                                      { 'count' => group_count, 'groups' => [] }.to_json]
      expect(@conn.group.get_group_id(groupname2)).to eq groupid2
    end

    it 'returns nothing on not found' do
      stub_factory '/api/v1/groups', [groups_data.to_json,
                                      groups_data2.to_json,
                                      { 'count' => group_count, 'groups' => [] }.to_json]
      expect(@conn.group.get_group_id('boogah123')).to eq nil
    end
  end

  def stub_group_request(path)
    stub_request(:any, /.*#{@mock_endpoint}.*#{path}/)
      .with(headers: @mock_headers)
      .to_return { |request| { body: { uri: request.uri, body: request.body, method: request.method }.to_json } }
  end
end
