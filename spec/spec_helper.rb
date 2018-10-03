require "bundler/setup"
require "scenic/oracle_adapter"

ActiveRecord::Base.establish_connection(
  ENV["DATABASE_URL"] || "oracle-enhanced://scenic_oracle_adapter_test:changeme@localhost/xe:1521"
)

def view_exists?(name)
  ActiveRecord::Base.connection.select_value("select count(*) from user_views where view_name = upper('#{name}')") == 1
end

def drop_all_views
  ActiveRecord::Base.connection.select_values("select view_name from user_views").each do |view|
    ActiveRecord::Base.connection.execute("drop view #{view}")
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
