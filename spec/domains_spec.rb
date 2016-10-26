require 'spec_helper'

describe SFRest::Domains do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_domains' do
    path = '/api/v1/domains'
    domains_data = generate_domains
    it 'gets the domains on a node' do
      stub_factory path, [domains_data.to_json]
      nid = rand 10**5
      expect(@conn.domains.list(nid)).to eq domains_data
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
