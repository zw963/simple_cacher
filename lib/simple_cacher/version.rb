#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class SimpleCacher
  VERSION = [0, 2, 2]

  class << VERSION
    def to_s
      join('.')
    end
  end
end
