require 'spec_helper'

describe SFRest::Collections do
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
      expect(@conn.collections.get_collection_id(collectionname)).to eq collectionid
    end
    it 'can make more than one request to get a collection id' do
      stub_factory '/api/v1/collections', [collections_data.to_json, collections_data2.to_json,
                                           { 'count' => collection_count, 'collections' => [] }.to_json]
      expect(@conn.collections.get_collection_id(collectionname2)).to eq collectionid2
    end
    it 'returns nothing on not found' do
      stub_factory '/api/v1/collections', collections_data.to_json
      expect(@conn.collections.get_collection_id('boogah123')).to eq nil
    end
  end

  describe '#collection_data_from_results' do
    collections_data = generate_collections_data
    collection = collections_data['collections'].sample
    collectionname = collection['name']
    key = collection.keys.sample
    target_value = collection[key]
    it 'can get a specific piece of site data' do
      expect(@conn.collections.collection_data_from_results(collections_data, collectionname, key)).to eq target_value
    end
  end

  describe '#get_collection_data' do
    collection = generate_collection_data
    collectionid = collection['id']
    it 'can get a collection data' do
      stub_factory '/api/v1/collections/' + collectionid.to_s, collection.to_json
      expect(@conn.collections.get_collection_data(collectionid)['id']).to eq collectionid
    end
  end

  describe '#first_collection_id' do
    collections_data = generate_collections_data
    collectionid = collections_data['collections'].first['id']
    it 'can get a collection id' do
      stub_factory '/api/v1/collections', collections_data.to_json
      expect(@conn.collections.first_collection_id).to eq collectionid
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
      res = @conn.collections.collection_list
      expect(res['count']).to eq collection_count
      expect(res['collections']).to eq collections + collections2
    end

    it 'returns the error message from the api' do
      stub_factory '/api/v1/collections', { 'message' => 'Danger Will Robinson!' }.to_json
      res = @conn.collections.collection_list
      expect(res['message']).to eq 'Danger Will Robinson!'
    end
  end
end
