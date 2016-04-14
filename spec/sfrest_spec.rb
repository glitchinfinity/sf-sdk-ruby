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
end
