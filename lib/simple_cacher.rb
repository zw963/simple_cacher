require 'json'
require 'redis'
require 'simple_cacher/version'

class SimpleCacher
  attr_reader :redis, :namespace

  def initialize(namespace:, host: '127.0.0.1', port: '6379', db: '15')
    @redis = Redis.new(url: "redis://#{host}:#{port}/#{db}")
    @namespace = Digest::MD5.new.update(namespace).to_s
  end

  def import(key:)
    key = nskey(key)
    if redis.exists(key)
      JSON.load(redis.get(key))
    else
      fail 'Import failed, key not exist!'
    end
  end

  def export(key:, data: nil, expire: nil)
    key = nskey(key)
    # nx == true set key only when key not exists
    nx = __callee__ == :export
    expire = Integer(expire) unless expire.nil?

    if redis.set(key, data.to_json, nx: nx, ex: expire)
      JSON.load(redis.get(key))
    else
      fail 'Export failed, key was exist!'
    end
  end
  # export! always set key regardless of key if exist
  alias export! export

  def reach_limit?(key:, limit:, expire: nil)
    key = nskey(key)
    expire = Integer(expire) unless expire.nil?

    if redis.exists(key)
      redis.incr(key) >= Integer(limit) ? true : false
    else
      redis.set(key, '1', ex: expire)
      false
    end
  end

  def exists?(key:)
    # if use with rails in develpment mode, not detect key existance.
    return false if defined?(Rails) && Rails.env.development?

    redis.exists(nskey(key))
  end

  private

  def nskey(key)
    "#{namespace}:#{key}"
  end
end
