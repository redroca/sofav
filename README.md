# Sofav
Short description and motivation.

## Usage
rails generate sofav NAME [field:type field:type] [options]
```
rails g sofav User name:string age:integer
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sofav'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install sofav
```


### Add following:
```
gem 'pg'
```

add database.yml (change dabtabase name)
```
default: &default
  adapter: postgresql
  pool: 5
  timeout: 5000
  encoding: utf-8
  host: <%= ENV['POSTGRES_HOST'] || 'localhost' %>
  username: <%= ENV['POSTGRES_USER'] || 'root'%>
  password: <%= ENV['POSTGRES_PASSWORD'] || '111'%>
  database: <%= ENV['POSTGRES_DB'] || 'mj'%>
development:
  <<: *default

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: mj-test

production:
  <<: *default
  pool: <%= ENV['POSTGRES_POOL_SIZE'] || 64 %>
  username: <%= ENV['POSTGRES_USER'] || 'root'%>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
