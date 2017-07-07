require 'json'

class SimpleCacher
  attr_reader :redis, :namespace

  def initialize(namespace:)
    # 默认使用最后一个 db, 避免冲突.
    # TODO: 使得 db 可配置
    @redis = Redis.new(url: 'redis://127.0.0.1:6379/15')
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
    nx = __callee__ == :export
    expire = Integer(expire) unless expire.nil?

    if redis.set(key, data.to_json, nx: nx, ex: expire)
      JSON.load(redis.get(key))
    else
      fail 'Export failed, key was exist!'
    end
  end
  alias export! export

  def reach_limit?(key:, limit:, expire: nil)
    key = nskey(key)
    expire = Integer(expire) unless expire.nil?

    if redis.exists(key)
      redis.incr(key) > Integer(limit) ? true : false
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
