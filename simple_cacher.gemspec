#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require File.expand_path('../lib/simple_cacher/version', __FILE__)

Gem::Specification.new do |s|
  s.name                        = 'simple_cacher'
  s.version                     = SimpleCacher::VERSION
  s.date                        = Time.now.strftime('%F')
  s.required_ruby_version       = '>= 1.9.1'
  s.authors                     = ['Billy.Zheng(zw963)']
  s.email                       = ['zw963@163.com']
  s.summary                     = ''
  s.description                 = ''
  s.homepage                    = 'http://github.com/zw963/simple_cacher'
  s.license                     = 'MIT'
  s.require_paths               = ['lib']
  s.files                       = `git ls-files bin lib *.md LICENSE`.split("\n")
  s.files                      -= Dir['images/*.png']
  s.executables                 = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f) }

  s.add_runtime_dependency 'redis', '>1.0'
  s.add_development_dependency 'ritual', '~>0.4'
end
