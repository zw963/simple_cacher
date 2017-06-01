#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

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
      fail 'Key not exist, import failed!'
    end
  end

  def export(key:, data: nil, expire: nil)
    key = nskey(key)
    expire = Integer(expire) unless expire.nil?

    if redis.setnx(key, data.to_json)
      redis.expire(key, expire) unless expire.nil?
    else
      fail 'Key alreday exist in cacher, export failed!'
    end
    import(key: key)
  end

  def expire!(key)
    key = nskey(key)

    redis.expire(key, -1)
  end

  def reach_limit?(key:, limit:, expire: nil)
    key = nskey(key)
    expire = Integer(expire) unless expire.nil?
    limit = Integer(limit)

    if redis.exists(key)
      redis.incr(key) > limit ? true : false
    else
      redis.set(key, '1')
      redis.expire(key, expire) unless expire.nil?
      false
    end
  end

  def fresh?(key:)
    # if in develpment mode, not use cache
    return false if defined?(Rails) && Rails.env.development?

    redis.exists(nskey(key))
  end
  alias exists? fresh?

  private

  def nskey(key)
    "#{namespace}:#{key}"
  end
end
