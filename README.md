# SimpleCacher [![Build Status](https://travis-ci.org/zw963/simple_cacher.svg?branch=master)](https://travis-ci.org/zw963/simple_cacher) [![Gem Version](https://badge.fury.io/rb/simple_cacher.svg)](http://badge.fury.io/rb/simple_cacher)

A very simple use/implement but very useful cacher, use Redis database.

## Getting Started

Install via Rubygems

    $ gem install simple_cacher

OR ...

Add to your Gemfile

    gem 'simple_cacher'

## Usage

### Use as a home page cache, expired within 120 second.

```rb
# The first step is need specify a namespace, one string which should unique each other
# for different purpose, in this current case (one Rails controller action), `request.url'
# is a perfect candidate.
cacher = SimpleCacher.new(namespace: request.url)

if cacher.fresh?(key: 'items')
  @items_hash = cacher.import(key: 'items')
else
  # do something get correct data and assign to a variable items_hash
  @items_hash = cacher.export(key: 'items', data: items_hash, expire: 120)
end
```

### Use as a counter, limit IP access during a time span.

```rb
counter = SimpleCacher.new(namespace: 'my_api:sms_log:user_ip')

# Sum IP 123.123.123.123 access count in one day, 
if counter.reach_limit?(key: '123.123.123.123', limit: 5, expire: 86400)
  # if exceed the limit, sent a warn info
else
  # do some sutff
end
```  

## Support

worked in MRI 2.[1,2,3,4], the only dependency is [redis-rb](https://github.com/redis/redis-rb)

## Limitations

No known limit.

## History

  See [CHANGELOG](https://github.com/zw963/simple_cacher/blob/master/CHANGELOG) for details.

## Contributing

  * [Bug reports](https://github.com/zw963/simple_cacher/issues)
  * [Source](https://github.com/zw963/simple_cacher)
  * Patches:
    * Fork on Github.
    * Run `gem install --dev simple_cacher` or `bundle`.
    * Create your feature branch: `git checkout -b my-new-feature`.
    * Commit your changes: `git commit -am 'Add some feature'`.
    * Push to the branch: `git push origin my-new-feature`.
    * Send a pull request :D.

## license

Released under the MIT license, See [LICENSE](https://github.com/zw963/simple_cacher/blob/master/LICENSE) for details.
