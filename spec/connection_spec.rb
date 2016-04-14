require 'spec_helper'

describe SFRest::Connection do
  before :each do
    @conn = SFRest.new 'http://www.exammple.com', 'user', 'password'
  end

  describe '#base_url' do
    it 'has a base url' do
      expect(@conn.base_url).to eq('http://www.exammple.com')
    end
    it 'can set a base url' do
      new_url = 'http://foo.example.com'
      @conn.base_url = new_url
      expect(@conn.base_url).to eq(new_url)
    end
  end

  describe '#password' do
    it 'has a password' do
      expect(@conn.password).to eq('password')
    end
    it 'can set a password' do
      new_pass = 'p0wn3d'
      @conn.password = new_pass
      expect(@conn.password).to eq(new_pass)
    end
  end

  describe '#username' do
    it 'has a username' do
      expect(@conn.username).to eq('user')
    end
    it 'can set a username' do
      new_user = 'foouser'
      @conn.username = new_user
      expect(@conn.username).to eq(new_user)
    end
  end

  describe '#get' do
    it 'returns json if the body is parsable.' do
      allow(Excon).to receive(:get).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('{"a":"b"}')
      expect(@conn.get('/')).to be_a(Hash)
    end

    it 'returns the if the body is not parsable.' do
      allow(Excon).to receive(:get).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('This is not json')
      expect(@conn.get('/')).to eq('This is not json')
    end
  end

  describe '#get_with_status' do
    it 'returns json and status if the body is parsable.' do
      allow(Excon).to receive(:get).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('{"a":"b"}')
      allow(Excon::Response).to receive(:status).and_return(200)
      res = @conn.get_with_status '/'
      expect(res[0]).to eq 200
      expect(res[1]).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      allow(Excon).to receive(:get).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('This is not json')
      allow(Excon::Response).to receive(:status).and_return(200)
      res = @conn.get_with_status '/'
      expect(res[0]).to eq 200
      expect(res[1]).to eq('This is not json')
    end
  end

  describe '#post' do
    it 'returns json if the body is parsable.' do
      allow(Excon).to receive(:post).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('{"a":"b"}')
      res = @conn.post '/', {}
      expect(res).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      allow(Excon).to receive(:post).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('This is not json')
      res = @conn.post '/', {}
      expect(res).to eq('This is not json')
    end
  end

  describe '#put' do
    it 'returns json if the body is parsable.' do
      allow(Excon).to receive(:put).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('{"a":"b"}')
      res = @conn.put '/', {}
      expect(res).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      allow(Excon).to receive(:put).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('This is not json')
      res = @conn.put '/', {}
      expect(res).to eq('This is not json')
    end
  end

  describe '#delete' do
    it 'returns json if the body is parsable.' do
      allow(Excon).to receive(:delete).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('{"a":"b"}')
      res = @conn.delete '/'
      expect(res).to be_a(Hash)
    end
    it 'returns the if the body is not parsable.' do
      allow(Excon).to receive(:delete).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('This is not json')
      res = @conn.delete '/'
      expect(res).to eq('This is not json')
    end
  end

  describe '#access_check' do
    it 'throws access denied error' do
      allow(Excon).to receive(:get).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('{"message":"Access denied"}')
      expect{@conn.get('/')}.to raise_error(SFRest::AccessDeniedError)
    end
    it 'throws access denied error' do
      allow(Excon).to receive(:get).and_return(Excon::Response)
      allow(Excon::Response).to receive(:body).and_return('{"message":"Forbidden: "}')
      expect{@conn.get('/')}.to raise_error(SFRest::ActionForbiddenError)
    end
  end

end
