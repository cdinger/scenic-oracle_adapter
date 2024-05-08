require "bundler/setup"
require "scenic/oracle_adapter"

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

  config.before(:suite) do
    if ENV["DATABASE_URL"]
      ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
    else
      # Default to Docker credentials
      waited = 0
      interval_in_seconds = 10
      until ActiveRecord::Base.connected?
        begin
          ActiveRecord::Base.establish_connection("oracle-enhanced://sys:thisisonlyusedlocally@db/orclpdb1?privilege=SYSDBA")
          ActiveRecord::Base.connection.select_value("select 1 from dual")
          puts "Connected!"
        rescue OCIError
          print "\rWaiting for database to become available (#{waited}s)... "
          waited += interval_in_seconds
          sleep interval_in_seconds
        end
      end

      unless ActiveRecord::Base.connection.select_value("select username from all_users where username = 'SCENIC_ORACLE_ADAPTER'")
        create_user_sql = <<~EOSQL
          CREATE USER scenic_oracle_adapter IDENTIFIED BY scenic_oracle_adapter
        EOSQL

        grant_sql = <<~EOSQL
          GRANT unlimited tablespace, create session, create table, create view, create materialized view, create database link TO scenic_oracle_adapter
        EOSQL

        ActiveRecord::Base.connection.execute(create_user_sql)
        ActiveRecord::Base.connection.execute(grant_sql)
      end

      ActiveRecord::Base.establish_connection("oracle-enhanced://scenic_oracle_adapter:scenic_oracle_adapter@db/orclpdb1")
    end
  end
end
