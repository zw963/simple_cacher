#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module SimpleCacher
  VERSION = [0, 0, 6]

  class << VERSION
    def to_s
      join('.')
    end
  end
end
