require 'spec_helper'

describe SFRest::Collection do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_collection_id' do
    collections_data = generate_collections_data
    collection = collections_data['collections'].sample
    collectionname = collection['name']
    collectionid = collection['id']
    collection_count = collections_data['count']
    collections_data2 = generate_collections_data
    collection2 = collections_data2['collections'].sample
    collectionname2 = collection2['name']
    collectionid2 = collection2['id']
    collection_count = collections_data2['count'] + collection_count + 100
    collections_data['count'] = collection_count
    collections_data2['count'] = collection_count

    it 'can get a collection id' do
      stub_factory '/api/v1/collections', collections_data.to_json
      expect(@conn.collection.get_collection_id(collectionname)).to eq collectionid
    end
    it 'can make more than one request to get a collection id' do
      stub_factory '/api/v1/collections', [collections_data.to_json, collections_data2.to_json,
                                           { 'count' => collection_count, 'collections' => [] }.to_json]
      expect(@conn.collection.get_collection_id(collectionname2)).to eq collectionid2
    end
    it 'returns nothing on not found' do
      stub_factory '/api/v1/collections', collections_data.to_json
      expect(@conn.collection.get_collection_id('boogah123')).to eq nil
    end
  end

  describe '#collection_data_from_results' do
    collections_data = generate_collections_data
    collection = collections_data['collections'].sample
    collectionname = collection['name']
    key = collection.keys.sample
    target_value = collection[key]
    it 'can get a specific piece of site data' do
      expect(@conn.collection.collection_data_from_results(collections_data, collectionname, key)).to eq target_value
    end
  end

  describe '#get_collection_data' do
    collection = generate_collection_data
    collectionid = collection['id']
    it 'can get a collection data' do
      stub_factory '/api/v1/collections/' + collectionid.to_s, collection.to_json
      expect(@conn.collection.get_collection_data(collectionid)['id']).to eq collectionid
    end
  end

  describe '#first_collection_id' do
    collections_data = generate_collections_data
    collectionid = collections_data['collections'].first['id']
    it 'can get a collection id' do
      stub_factory '/api/v1/collections', collections_data.to_json
      expect(@conn.collection.first_collection_id).to eq collectionid
    end
  end

  describe '#collection_list' do
    collections_data = generate_collections_data
    collection_count = collections_data['count']
    collections = collections_data['collections']
    collections_data2 = generate_collections_data
    collections2 = collections_data2['collections']
    collection_count = collections_data2['count'] + collection_count
    collections_data['count'] = collection_count
    collections_data2['count'] = collection_count

    it 'can get a set of collections data' do
      stub_factory '/api/v1/collections',
                   [collections_data.to_json,
                    collections_data2.to_json,
                    { 'count' => collection_count, 'collections' => [] }.to_json]
      res = @conn.collection.collection_list
      expect(res['count']).to eq collection_count
      expect(res['collections']).to eq collections + collections2
    end

    it 'returns the error message from the api' do
      stub_factory '/api/v1/collections', { 'message' => 'Danger Will Robinson!' }.to_json
      res = @conn.collection.collection_list
      expect(res['message']).to eq 'Danger Will Robinson!'
    end
  end

  describe '#create' do
    it 'can create a site collection' do
      collection_data = generate_collection_creation_data
      collection_name = collection_data['name']
      group_count = rand(3) + 1
      groups = []
      group_count.times { |i| groups[i] = rand(100).to_i }

      site_count = rand(3) + 1
      sites = []
      site_count.times { |i| sites[i] = rand(100).to_i }

      stub_factory '/api/v1/collections', collection_data.to_json
      res = @conn.collection.create collection_name, sites, groups
      expect(res['name']).to eq collection_name
    end

    it 'can create a site collection with an internal domain' do
      collection_data = generate_collection_creation_data Faker::Internet.domain_word
      collection_name = collection_data['name']
      internal_domain = collection_data['internal_domain']
      group_count = rand(3) + 1
      groups = []
      group_count.times { |i| groups[i] = rand(100).to_i }

      site_count = rand(3) + 1
      sites = []
      site_count.times { |i| sites[i] = rand(100).to_i }

      stub_factory '/api/v1/collections', collection_data.to_json
      res = @conn.collection.create collection_name, sites, groups
      expect(res['name']).to eq collection_name
      expect(res['internal_domain']).to eq internal_domain
    end
  end

  describe '#delete' do
    it 'can delete a site collection' do
      collection_data = generate_collection_deletion_data
      id = collection_data['id']
      stub_factory '/api/v1/collections', collection_data.to_json
      res = @conn.collection.delete id
      expect(res['id']).to eq id
    end
  end

  describe '#add_sites' do
    it 'can add sites to a site collection' do
      collection_data = generate_collection_add_site_data
      stub_factory '/api/v1/collections', collection_data.to_json
      res = @conn.collection.add_sites(collection_data['id'], collection_data['sites_added'])
      expect(res['id']).to eq collection_data['id']
      expect(res['name']).to eq collection_data['name']
      expect(res['sites_added']).to eq collection_data['sites_added']
      expect(res['added']).to eq collection_data['added']
      expect(res['message']).to eq collection_data['message']
    end
  end

  describe '#remove_sites' do
    it 'can remove sites from a site collection' do
      collection_data = generate_collection_remove_site_data
      stub_factory '/api/v1/collections', collection_data.to_json
      res = @conn.collection.remove_sites(collection_data['id'], collection_data['site_ids_removed'])
      expect(res['id']).to eq collection_data['id']
      expect(res['name']).to eq collection_data['name']
      expect(res['sites_ids_removed']).to eq collection_data['sites_ids_removed']
      expect(res['removed']).to eq collection_data['removed']
      expect(res['message']).to eq collection_data['message']
    end
  end

  describe '#set_primary_site' do
    it 'can set a site to be the primary site in a a site collection' do
      collection_data = generate_collection_set_primary_site_data
      stub_factory '/api/v1/collections', collection_data.to_json
      res = @conn.collection.set_primary_site(collection_data['id'], collection_data['primary_site_id'])
      expect(res['id']).to eq collection_data['id']
      expect(res['name']).to eq collection_data['name']
      expect(res['primary_site_id']).to eq collection_data['primary_site_id']
      expect(res['switched']).to eq collection_data['switched']
      expect(res['message']).to eq collection_data['message']
    end
  end
end
