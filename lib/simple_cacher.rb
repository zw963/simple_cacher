#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class SimpleCacher
  attr_reader :redis, :namespace

  def initialize(namespace:)
    @redis = Redis.new(url: 'redis://127.0.0.1:6379/15')
    @namespace = Digest::MD5.new.update(namespace).to_s
  end

  def nskey(key)
    "#{namespace}:#{key}"
  end

  def import(key:)
    JSON.parse(redis.get(nskey(key)))
  end

  def export(data: true, key:, expire: nil)
    key = nskey(key)
    hash = @redis.set(key, data.to_json)
    @redis.expire(key, expire.to_i) unless expire.nil?
    hash
  end

  def fresh?(key:)
    (Rails.env.production? or Rails.env.test?) &&
      redis.exists(nskey(key))
  end
  alias exists? fresh?
end
