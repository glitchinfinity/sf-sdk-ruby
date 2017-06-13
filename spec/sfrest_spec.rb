require 'spec_helper'

describe SFRest do
  before :each do
    @conn = SFRest.new 'http://www.example.com', 'user', 'password'
  end

  describe '#new' do
    it 'takes a url, user and password and return an SFRest::Connection' do
      expect(@conn).to be_an_instance_of SFRest::Connection
    end
  end

  describe '#find_data_from_results' do
    sites_data = generate_sites_data
    site = sites_data['sites'].sample
    sitename = site['site']
    siteid = site['id']
    it 'Can find a value' do
      expect(SFRest.find_data_from_results(sites_data, 'site', sitename, 'id')).to eq siteid
    end
  end
end
