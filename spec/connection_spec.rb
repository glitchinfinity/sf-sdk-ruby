require 'spec_helper'

describe SFRest::Connection do
  before :each do
    @conn = SFRest.new "http://#{@mock_endpoint}", @mock_user, @mock_pass
  end

  describe '#get' do
    it 'returns json if the body is parsable.' do
      stub_json_request
      expect(@conn.get('/')).to be_a(Hash)
    end
    it 'raises InvalidResponse the if the body is not parsable.' do
      stub_notjson_request
      begin
        @conn.get('/')
      rescue SFRest::SFError => e
        expect(e).to be_a(SFRest::InvalidResponse)
        expect(e.message).to eq('Invalid data, status 200, body: This is not json')
      end
    end
  end

  describe '#get_with_status' do
    it 'returns json and status if the body is parsable.' do
      stub_json_request
      res = @conn.get_with_status '/'
      expect(res[0]).to eq 200
      expect(res[1]).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      stub_notjson_request
      begin
        @conn.get_with_status '/'
      rescue SFRest::SFError => e
        expect(e).to be_a(SFRest::InvalidResponse)
        expect(e.message).to eq('Invalid data, status 200, body: This is not json')
      end
    end
  end

  describe '#post' do
    it 'returns json if the body is parsable.' do
      stub_json_request
      res = @conn.post '/', '{}'
      expect(res).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      stub_notjson_request
      begin
        @conn.post '/', '{}'
      rescue SFRest::SFError => e
        expect(e).to be_a(SFRest::InvalidResponse)
        expect(e.message).to eq('Invalid data, status 200, body: This is not json')
      end
    end
  end

  describe '#put' do
    it 'returns json if the body is parsable.' do
      stub_json_request
      res = @conn.put '/', {}.to_json
      expect(res).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      stub_notjson_request
      begin
        @conn.put('/', {}.to_json)
      rescue SFRest::SFError => e
        expect(e).to be_a(SFRest::InvalidResponse)
        expect(e.message).to eq('Invalid data, status 200, body: This is not json')
      end
    end
  end

  describe '#delete' do
    it 'returns json if the body is parsable.' do
      stub_json_request
      res = @conn.delete '/'
      expect(res).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      stub_notjson_request
      begin
        @conn.delete('/')
      rescue SFRest::SFError => e
        expect(e).to be_a(SFRest::InvalidResponse)
        expect(e.message).to eq('Invalid data, status 200, body: This is not json')
      end
    end
  end

  describe '#access_check' do
    it 'throws access denied error' do
      stub_factory nil, '{ "message":"Access denied" }'
      expect { @conn.get('/') }.to raise_error(SFRest::AccessDeniedError)
    end
    it 'throws access denied error' do
      stub_factory nil, '{ "message":"Forbidden: " }'
      expect { @conn.get('/') }.to raise_error(SFRest::ActionForbiddenError)
    end
    it 'throws bad request error' do
      stub_factory nil, '{ "message":"Bad Request: " }'
      expect { @conn.get('/') }.to raise_error(SFRest::BadRequestError)
    end
    it 'throws unprocessable entity error' do
      stub_factory nil, '{ "message":"Unprocessable Entity: " }'
      expect { @conn.get('/') }.to raise_error(SFRest::UnprocessableEntity)
    end
    it 'throws an error on unqualified 4xx / 5xx http statuses' do
      stub_factory nil, '{ "message":"Random error message" }', 400
      expect { @conn.get('/') }.to raise_error(SFRest::SFError)
    end
  end

  describe '#ping' do
    it 'can ping the api' do
      stub_factory('/api/v1/ping', { 'message' => 'pong' }.to_json)
      expect(@conn.ping['message']).to eq 'pong'
    end
  end

  describe '#service_reponse' do
    it 'can ping the api' do
      stub_factory('/api/v1/ping', { 'message' => 'pong' }.to_json)
      expect(@conn.service_response['message']).to eq 'pong'
    end
  end
end
