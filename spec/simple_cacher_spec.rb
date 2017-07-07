require_relative '../lib/simple_cacher'
require 'redis'

describe 'test rspec' do
  before { subject.redis.flushall }
  subject { SimpleCacher.new(namespace: 'should_be_a_unique_namespace_for_used_project') }

  it 'return MD5 encoded namespace' do
    expect(subject.namespace).to eq Digest::MD5.new.update('should_be_a_unique_namespace_for_used_project').to_s
  end

  it 'use correct redis db' do
    expect(subject.redis.client.options[:url]).to eq 'redis://127.0.0.1:6379/15'
  end

  it 'should fail a message if import a empty key' do
    expect { subject.import(key: 'test_key') }.to raise_error(RuntimeError, 'Import failed, key not exist!')
  end

  it 'export a key success' do
    subject.export(key: 'test_key', data: {'key1' => 'value1', 'key2' => 'value2'})
    expect(subject.import(key: 'test_key')).to eq('key1' => 'value1', 'key2' => 'value2')
    expect { subject.export(key: 'test_key', data: {'key3' => 'value3', 'key4' => 'value4'}) }.to(
      raise_error(RuntimeError, 'Export failed, key was exist!')
    )
    subject.export!(key: 'test_key', data: {'key3' => 'value3', 'key4' => 'value4'})
  end

  it 'export a key with a expire time' do
    subject.export(key: 'test_key', data: {'key1' => 'value1', 'key2' => 'value2'}, expire: 2)
    expect(subject.exists?(key: 'test_key')).to be true
    warn 'waiting 3 seconds'
    sleep 3
    expect(subject.exists?(key: 'test_key')).to be false
    subject.export(key: 'test_key', data: {'key3' => 'value3', 'key4' => 'value4'}, expire: 2)
  end

  it 'export a counter key' do
    value = subject.reach_limit?(key: 'test_counter', limit: 20, expire: 2)
    expect(subject.import(key: 'test_counter')).to be 1
    expect(value).to be false
    warn 'waiting 3 seconds'
    sleep 3
    expect(subject.exists?(key: 'test_key')).to be false

    values = (1..21).map { subject.reach_limit?(key: 'test_counter', limit: 20, expire: 20) }
    expect(values).to eq [
      false, false, false, false, false, false, false,
      false, false, false, false, false, false, false,
      false, false, false, false, false, false, true
    ]
  end
end
