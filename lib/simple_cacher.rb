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

  def nskey(key)
    "#{namespace}:#{key}"
  end

  def import(key:)
    key = nskey(key)

    redis.exists(key) ? JSON.load(redis.get(key)) : nil
  end

  def export(key:, data: nil, expire: nil)
    key = nskey(key)

    hash = redis.set(key, data.to_json)
    redis.expire(key, expire.to_i) unless expire.nil?
    hash
  end

  def reach_limit?(key:, limit:, expire: nil)
    key = nskey(key)

    if redis.exists(key)
      # 如果存在, 递增 1, 记录访问的次数.
      redis.incr(key)
    else
      redis.set(key, '1')
      redis.expire(key, expire.to_i) unless expire.nil?
    end

    redis.get(key).to_i > limit ? true : false
  end

  def fresh?(key:)
    (Rails.env.production? or Rails.env.test?) &&
      redis.exists(nskey(key))
  end
  alias exists? fresh?
end
