# scenic-oracle_adapter [![Build Status](https://travis-ci.org/cdinger/scenic-oracle_adapter.svg?branch=master)](https://travis-ci.org/cdinger/scenic-oracle_adapter)

An Oracle adapter for Thoughtbot's [scenic](https://github.com/thoughtbot/scenic) rubygem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scenic-oracle_adapter'
```

And then execute:

    $ bundle

You'll need to tell the scenic gem to use this adapter in an initializer:

```ruby
# config/initializers/scenic.rb

Scenic.configure do |config|
  config.database = Scenic::Adapters::Oracle.new
end
```

## Development

While you can use any Oracle instance to run the test suite, it's easiest to use Docker and docker-compose.

After checking out the repo, start the Oracle instance by running `docker-compose up -d`. After that, you can 
run `docker-compose exec gem bin/setup` to install dependencies. Then, run `docker-compose exec gem bin/test` (or `rspec`) to run the tests.
You can also run `docker-compose exec gem bin/console` for an interactive prompt that will allow you to experiment.

By default, the test suite will attempt to connect to a local docker Oracle instance (see `spec/spec_helper.rb` for connection details).
You can override the database URL by supplying a value to the `DATABASE_URL` environment variable.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cdinger/scenic-oracle_adapter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the scenic-oracle_adapter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cdinger/scenic-oracle_adapter/blob/master/CODE_OF_CONDUCT.md).
