require 'spec_helper'

describe SFRest::Info do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get_info' do
    it 'can retrieve Site Factory information' do
      info = generate_info_data
      stub_factory '/api/v1/sf-info', info.to_json
      res = @conn.info.sfinfo
      expect(res['factory_version']).to eq info['factory_version']
    end
  end
end
