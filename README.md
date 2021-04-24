# scenic-oracle_adapter [![Build Status](https://github.com/cdinger/scenic-oracle_adapter/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/cdinger/scenic-oracle_adapter/actions/workflows/ci.yml?query=branch%3Amaster)

An Oracle adapter for the [scenic](https://github.com/scenic-views/scenic) rubygem.

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

While you can use any Oracle instance for development, it's easiest to use Docker and docker-compose.

Note that the Oracle container takes up to two minutes to start and become available. If you're doing active development you probably want to start the containers in detached mode: `docker-compose up -d`. This starts everything in the background and allows you to use `docker-compose exec` to run commands on the already running containers:

- Run specs: `docker-compose exec gem bin/test`
- Open a console: `docker-compose exec gem bin/console`

## Tests

If you just want to run the test suite you can use `docker-compose run --rm gem bin/test`. Again, because the Oracle container takes so long to start up, the first execution will take a while. The test suite will wait for the database container to become available. Subsequent executions will be faster.

By default, the test suite will attempt to connect to a local docker Oracle instance (see `spec/spec_helper.rb` for connection details).
You can override the database URL by supplying a value to the `DATABASE_URL` environment variable.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cdinger/scenic-oracle_adapter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the scenic-oracle_adapter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cdinger/scenic-oracle_adapter/blob/master/CODE_OF_CONDUCT.md).
