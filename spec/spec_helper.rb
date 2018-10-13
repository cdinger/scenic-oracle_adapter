require "bundler/setup"
require "scenic/oracle_adapter"

ActiveRecord::Base.establish_connection(
  ENV["DATABASE_URL"] || "oracle-enhanced://scenic_oracle_adapter:scenic_oracle_adapter@localhost/xe:1521"
)

def find_view(name)
  adapter.views.find { |view| view.name == name && !view.materialized }
end

def find_mview(name)
  adapter.views.find { |view| view.name == name && view.materialized }
end

def view_exists?(name)
  !find_view(name).nil?
end

def mview_exists?(name)
  !find_mview(name).nil?
end

def drop_all_views
  ActiveRecord::Base.connection.select_values("select view_name from user_views").each do |view|
    ActiveRecord::Base.connection.execute("drop view #{view}")
  end
end

def drop_all_mviews
  ActiveRecord::Base.connection.select_values("select mview_name from user_mviews").each do |view|
    ActiveRecord::Base.connection.execute("drop materialized view #{view}")
  end
end

def drop_all_tables
  ActiveRecord::Base.connection.select_values("select table_name from user_tables").each do |table|
    ActiveRecord::Base.connection.execute("drop table #{table}")
  end
end

def select_value(sql)
  ActiveRecord::Base.connection.select_value(sql)
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
