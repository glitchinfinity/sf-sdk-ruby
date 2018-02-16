require 'spec_helper'

describe SFRest::Domains do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_domains' do
    path = '/api/v1/domains'
    custom_domains_data = generate_domains
    protected_domains_data = generate_domains
    nid = rand 10**5
    node_type = %w[site site_collection].sample
    domains_data = { 'node_id' => nid, 'node_type' => node_type,
                     'date' => Time.now.to_s,
                     'domains' =>
                     { 'protected_domains' => protected_domains_data,
                       'custom_domains' => custom_domains_data } }
    it 'gets the domain data for a node' do
      stub_factory path, [domains_data.to_json]
      nid = rand 10**5
      expect(@conn.domains.get(nid)).to eq domains_data
    end

    it 'gets the custom domains on a node' do
      stub_factory path, [domains_data.to_json]
      nid = rand 10**5
      expect(@conn.domains.custom_domains(nid)).to eq custom_domains_data
    end

    it 'gets the protected domains on a node' do
      stub_factory path, [domains_data.to_json]
      nid = rand 10**5
      expect(@conn.domains.protected_domains(nid)).to eq protected_domains_data
    end
  end

  describe '#add_domains' do
    path = '/api/v1/domains'
    domain = SecureRandom.urlsafe_base64(5) + '.' + SecureRandom.urlsafe_base64(5) + '.com'
    it 'adds a domain' do
      stub_factory path, [{ node_type: 'site',
                            domain: domain,
                            added: 'true',
                            messages: ['Book it done!'] }.to_json]
      nid = rand 10**5
      expect(@conn.domains.add(nid, domain)['domain']).to eq domain
    end
  end

  describe '#remove_domains' do
    path = '/api/v1/domains'
    domain = SecureRandom.urlsafe_base64(5) + '.' + SecureRandom.urlsafe_base64(5) + '.com'
    it 'deletes a domain' do
      stub_factory path, [{ node_type: 'site',
                            domain: domain,
                            removed: 'true',
                            messages: ['Book it done!'] }.to_json]
      nid = rand 10**5
      expect(@conn.domains.remove(nid, domain)['domain']).to eq domain
    end
  end
end
