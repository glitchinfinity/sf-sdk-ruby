require 'spec_helper'

describe SFRest::Site do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_site_id' do
    sites_data = generate_sites_data
    site = sites_data['sites'].sample
    sitename = site['site']
    siteid = site['id']
    site_count = sites_data['count']
    sites_data2 = generate_sites_data
    site2 = sites_data2['sites'].sample
    sitename2 = site2['site']
    siteid2 = site2['id']
    site_count = sites_data2['count'] + site_count + 100
    sites_data['count'] = site_count
    sites_data2['count'] = site_count

    it 'can get a site id' do
      stub_factory '/api/v1/sites', sites_data.to_json
      expect(@conn.site.get_site_id(sitename)).to eq siteid
    end
    it 'can make more than one request to get a site id' do
      stub_factory '/api/v1/sites', [sites_data.to_json, sites_data2.to_json,
                                     { 'count' => site_count, 'sites' => [] }.to_json]
      expect(@conn.site.get_site_id(sitename2)).to eq siteid2
    end
    it 'returns nothing on not found' do
      stub_factory '/api/v1/sites', sites_data.to_json
      expect(@conn.site.get_site_id('boogah123')).to eq nil
    end
  end

  describe '#site_data_from_results' do
    sites_data = generate_sites_data
    site = sites_data['sites'].sample
    sitename = site['site']
    key = site.keys.sample
    target_value = site[key]
    it 'can get a specific piece of site data' do
      expect(@conn.site.site_data_from_results(sites_data, sitename, key)).to eq target_value
    end
  end

  describe '#get_site_data' do
    site = generate_site_data
    siteid = site['id']
    it 'can get a site data' do
      stub_factory '/api/v1/sites/' + siteid.to_s, site.to_json
      expect(@conn.site.get_site_data(siteid)['id']).to eq siteid
    end
  end

  describe '#first_site_id' do
    sites_data = generate_sites_data
    siteid = sites_data['sites'].first['id']
    it 'can get a site id' do
      stub_factory '/api/v1/sites', sites_data.to_json
      expect(@conn.site.first_site_id).to eq siteid
    end
  end

  describe '#site_list' do
    sites_data = generate_sites_data
    site_count = sites_data['count']
    sites = sites_data['sites']
    sites_data2 = generate_sites_data
    sites2 = sites_data2['sites']
    site_count = sites_data2['count'] + site_count
    sites_data['count'] = site_count
    sites_data2['count'] = site_count

    it 'can get a set of sites data' do
      stub_factory '/api/v1/sites',
                   [sites_data.to_json,
                    sites_data2.to_json,
                    { 'count' => site_count, 'sites' => [] }.to_json]
      res = @conn.site.site_list
      expect(res['count']).to eq site_count
      expect(res['sites']).to eq sites + sites2
    end

    it 'returns the error message from the api' do
      stub_factory '/api/v1/sites', { 'message' => 'Danger Will Robinson!' }.to_json
      res = @conn.site.site_list
      expect(res['message']).to eq 'Danger Will Robinson!'
    end
  end

  describe '#create_site' do
    site_data = generate_site_creation_data
    site_name = site_data['site']
    group_id = site_data['groups'][0]
    it 'can create a site' do
      stub_factory '/api/v1/sites', site_data.to_json
      res = @conn.site.create_site site_name, group_id
      expect(res['site']).to eq site_name
    end
  end

  describe '#delete' do
    site_data = generate_site_delete_data
    site_id = site_data['site_id']
    site_name = site_data['site']
    task_id = site_data['task_id']
    it 'can delete a site' do
      stub_factory '/api/v1/sites/' + site_id.to_s, site_data.to_json
      res = @conn.site.delete site_id
      expect(res['site']).to eq site_name
      expect(res['task_id']).to eq task_id
    end
  end

  describe '#backup' do
    it 'can get a backup object' do
      expect(@conn.site.backup).to be_kind_of(SFRest::Backup)
    end
  end
end
