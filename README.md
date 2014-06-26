# Barrage

[![Gem Version](https://badge.fury.io/rb/barrage.svg)](http://badge.fury.io/rb/barrage)
[![Dependency Status](https://gemnasium.com/drecom/barrage.svg)](https://gemnasium.com/drecom/barrage)
[![Coverage Status](https://img.shields.io/coveralls/drecom/barrage.svg)](https://coveralls.io/r/drecom/barrage)
[![Build Status](https://travis-ci.org/drecom/barrage.svg)](https://travis-ci.org/drecom/barrage)

Distributed ID generator(like twitter/snowflake)

## Installation

Add this line to your application's Gemfile:

    gem 'barrage'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install barrage

## Usage

### Example

```ruby
# 39bit: msec (17.4 years from start_at)
# 16bit: worker_id
# 9bit:  sequence
require 'barrage'

barrage = Barrage.new(
  "generators" => [
    {"name" => "msec", "length" => 39, "start_at" => 1396278000000},
    {"name" => "redis_worker_id", "length" => 16, "ttl" => 300},
    {"name" => "sequence", "length" => 9}
  ]
)
barrage.next
# => Generated 64bit ID
```

### Generators

#### msec
#### redis_worker_id
#### sequence

### Creating your own generator

```ruby
module Barrage::Generators
  class YourOwnGenerator < Base
    self.required_options += %w(your_option_value)
    def generate
      # generated code
    end

    def your_option_value
      options["your_option_value"]
    end
  end
end

barrage = Barrage.new("generators" => [{"name"=>"your_own", "length" => 8, "your_option_value"=>"xxx"}])
```

## Contributing

1. Fork it ( https://github.com/drecom/barrage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
