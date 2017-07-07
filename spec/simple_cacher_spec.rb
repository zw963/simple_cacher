require 'simple_cacher'
require 'redis'

describe 'test rspec' do
  subject { SimpleCacher.new(namespace: 'should_be_a_unique_namespace_for_used_project') }

  it 'return MD5 encoded namespace' do
    expect(subject.namespace).to eq Digest::MD5.new.update('should_be_a_unique_namespace_for_used_project').to_s
  end
end
