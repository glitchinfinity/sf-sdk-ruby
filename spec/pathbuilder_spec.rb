require 'spec_helper'
describe SFRest::Group do
  describe '#build_url_query' do
    it 'add one item to a path' do
      new_path = '/api/v1/foo'
      datum = { bar: 'baz' }
      pb = SFRest::Pathbuilder.new
      expect(pb.build_url_query(new_path, datum)).to eq "#{new_path}?bar=baz"
    end

    it 'add many items to a path' do
      new_path = '/api/v1/foo'
      datum = { bar: 'baz', bat: 'boo', bing: 'bang' }
      pb = SFRest::Pathbuilder.new
      expect(pb.build_url_query(new_path, datum)).to eq "#{new_path}?bar=baz&bat=boo&bing=bang"
    end
  end

  describe '#needs_new_parameter' do
    it 'detects the needs for a new parameter' do
      question_path = '/api/v1/foo?'
      no_question_path = '/api/v1/foo'
      pb = SFRest::Pathbuilder.new
      expect(pb.send(:needs_new_parameter?, question_path)).to be false
      expect(pb.send(:needs_new_parameter?, no_question_path)).to be true
    end
  end
end
