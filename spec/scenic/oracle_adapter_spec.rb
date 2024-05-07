require "scenic/adapters/oracle/refresh_dependencies"

RSpec.describe Scenic::OracleAdapter do
  context "integration" do
    let(:adapter) { Scenic::Adapters::Oracle.new }

    after do
      drop_all_views
      drop_all_mviews
      drop_all_tables
    end

    it "has a version number" do
      expect(Scenic::OracleAdapter::VERSION).not_to be nil
    end

    it ".views" do
      adapter.create_view("one", "select 1 as a from dual")
      adapter.create_view("two", "select 2 as a from dual")
      expect(adapter.views.size).to eq(2)
      one = adapter.views.find { |view| view.name == "one" }
      expect(one.name).to eq("one")
      expect(one.definition.downcase).to eq("select 1 as a from dual")
    end

    it ".create_view" do
      adapter.create_view("blah", "select 1 as a from dual")
      expect(view_exists?("blah")).to be true
    end

    it ".drop_view" do
      adapter.create_view("blah", "select 1 as a from dual")
      expect(view_exists?("blah")).to be true
      adapter.drop_view("blah")
      expect(view_exists?("blah")).to be false
    end

    it "replaces a view that doesn't exist" do
      expect(view_exists?("blah")).to be false
      adapter.replace_view("blah", "select 1 as a from dual")
      expect(view_exists?("blah")).to be true
    end

    it "replaces a view that does exist" do
      adapter.create_view("blah", "select 1 as a from dual")
      expect(view_exists?("blah")).to be true
      adapter.replace_view("blah", "select 2 as a from dual")
      expect(find_view("blah").definition).to eq("select 2 as a from dual")
    end

    it "updates a view" do
      adapter.create_view("blah", "select 1 as a from dual")
      expect(view_exists?("blah")).to be true
      adapter.update_view("blah", "select 1 as a, 2 as b from dual")
      expect(find_view("blah").definition).to eq("select 1 as a, 2 as b from dual")
    end

    it "creates a materialized view" do
      adapter.create_materialized_view("blah", "select 1 as a from dual")
      view = find_mview("blah")
      expect(view.materialized).to be true
      expect(view.definition).to eq("select 1 as a from dual")
      expect(select_value("select count(*) from blah")).to eq(1)
    end

    it "creates an unpopulated materialized view" do
      adapter.create_materialized_view("blah", "select 1 as a from dual", no_data: true)
      view = find_mview("blah")
      expect(view.materialized).to be true
      expect(view.definition).to eq("select 1 as a from dual")
      expect(select_value("select count(*) from blah")).to eq(0)
    end

    it "drops a materialized view" do
      adapter.create_materialized_view("blah", "select 1 as a from dual")
      expect(find_mview("blah").materialized).to be true
      adapter.drop_materialized_view("blah")
      expect(mview_exists?("blah")).to be false
    end

    it "updates a materialized view" do
      adapter.create_materialized_view("blah", "select 1 as a from dual")
      view = find_mview("blah")
      expect(view.materialized).to be true
      expect(view.definition).to eq("select 1 as a from dual")
      adapter.update_materialized_view("blah", "select 1 as a, 2 as b from dual")
      view = find_mview("blah")
      expect(view.materialized).to be true
      expect(view.definition).to eq("select 1 as a, 2 as b from dual")
    end

  it "updates an unpopulated materialized view" do
      adapter.create_materialized_view("blah", "select 1 as a from dual", no_data: true)
      view = find_mview("blah")
      expect(view.materialized).to be true
      expect(view.definition).to eq("select 1 as a from dual")
      expect(select_value("select count(*) from blah")).to eq(0)
      adapter.update_materialized_view("blah", "select 1 as a, 2 as b from dual", no_data: true)
      view = find_mview("blah")
      expect(view.materialized).to be true
      expect(view.definition).to eq("select 1 as a, 2 as b from dual")
      expect(select_value("select count(*) from blah")).to eq(0)
    end

    context "updates a materialized view with indexes" do
      before do
        adapter.create_materialized_view("things", "select 1 as id, 'something' as name from dual")
        adapter.execute("create unique index things_id on things(id)")
        adapter.execute("create index things_name on things(name)")
      end

      it "recreate all indexes" do
        adapter.update_materialized_view("things", "select 1 as id, 'something' as name, 123 as department from dual")

        expect(select_value("select count(*)
                             from user_indexes
                             where index_name = 'THINGS_ID'
                               and uniqueness = 'UNIQUE'")).to eq(1)
        expect(select_value("select count(*)
                             from user_indexes
                             where index_name = 'THINGS_NAME'
                               and uniqueness = 'NONUNIQUE'")).to eq(1)
      end

      it "handles invalidated indexes" do
        adapter.update_materialized_view("things", "select 1 as id, 123 as department from dual")

        expect(select_value("select count(*)
                             from user_indexes
                             where index_name = 'THINGS_ID'
                               and uniqueness = 'UNIQUE'")).to eq(1)
        expect(select_value("select count(*)
                             from user_indexes
                             where index_name = 'THINGS_NAME'
                               and uniqueness = 'NONUNIQUE'")).to eq(0)
      end
    end

    context ".refresh_materialized_view" do
      before do
        adapter.execute("create table things (id integer, name varchar(50), private char(1))")
        adapter.execute("insert into things values (1, 'these', 'Y')")
        adapter.execute("insert into things values (2, 'are', 'N')")
        adapter.execute("insert into things values (3, 'things', 'Y')")
        adapter.create_materialized_view("private_things", "select id, name, private from things where private = 'Y'")
        expect(adapter.connection.select_value("select count(*) from private_things")).to eq(2)
        adapter.execute("insert into things values (4, 'another', 'Y')")
      end

      it "refreshes a materialized view" do
        adapter.refresh_materialized_view("private_things")
        expect(adapter.connection.select_value("select count(*) from private_things")).to eq(3)
      end

      it "refreshes a materialized view concurrently" do
        adapter.refresh_materialized_view("private_things", concurrently: true)
        expect(adapter.connection.select_value("select count(*) from private_things")).to eq(3)
      end

      it "refreshes dependecies in the correct order" do
        adapter = Scenic::Adapters::Oracle.new

        adapter.create_materialized_view(
          "first",
          "SELECT 'hi' AS greeting from dual",
        )

        adapter.create_materialized_view(
          "second",
          "SELECT * from first",
        )

        adapter.create_materialized_view(
          "third",
          "SELECT * from first UNION SELECT * from second",
        )

        adapter.create_materialized_view(
          "fourth",
          "SELECT * from third",
        )

        expect(adapter).to receive(:refresh_materialized_view).
          with(:first).ordered

        expect(adapter).to receive(:refresh_materialized_view).
          with(:second).ordered

        expect(adapter).to receive(:refresh_materialized_view).
          with(:third).ordered

        Scenic::Adapters::Oracle::RefreshDependencies.call(:fourth, adapter, ActiveRecord::Base.connection)
      end

      it "does not raise an error when a view has no materialized view dependencies" do
        adapter = Scenic::Adapters::Oracle.new

        adapter.create_materialized_view(
          "first",
          "SELECT 'hi' AS greeting from dual",
        )

        expect {
          Scenic::Adapters::Oracle::RefreshDependencies.call(:first, adapter, ActiveRecord::Base.connection)
        }.not_to raise_error
      end
    end

    describe "#populated?" do
      it "returns false if a materialized view is not populated" do
        adapter.execute(<<~SQL)
          create materialized view greetings build deferred as
          select 'hi' as greeting from dual
        SQL

        expect(adapter.populated?("greetings")).to be false
      end

      it "returns true if a materialized view is populated" do
        adapter.execute(<<~SQL)
          create materialized view greetings as
          select 'hi' as greeting from dual
        SQL

        expect(adapter.populated?("greetings")).to be true
      end
    end
  end

  context "mocks" do
    describe "create_materialized_view" do
      context "with parallel enabled" do
        it "adds the parallel flag to the create command" do
          connectable = ActiveRecord::Base
          a = Scenic::Adapters::Oracle.new(connectable)
          expected = <<~EOS
            create materialized view parallel_test parallel as select 1 as id from dual
          EOS

          expect(connectable.connection).to receive(:execute).with(expected)

          a.create_materialized_view("parallel_test", "select 1 as id from dual", parallel: true)
        end
      end

      context "without parallel enabled" do
        it "omits the parallel flag in the create command" do
          connectable = ActiveRecord::Base
          a = Scenic::Adapters::Oracle.new(connectable)
          expected = <<~EOS
            create materialized view parallel_test as select 1 as id from dual
          EOS

          expect(connectable.connection).to receive(:execute).with(expected)

          a.create_materialized_view("parallel_test", "select 1 as id from dual", parallel: false)
        end

        it "defaults to disabling parallel" do
          connectable = ActiveRecord::Base
          a = Scenic::Adapters::Oracle.new(connectable)
          expected = <<~EOS
            create materialized view parallel_test as select 1 as id from dual
          EOS

          expect(connectable.connection).to receive(:execute).with(expected)

          a.create_materialized_view("parallel_test", "select 1 as id from dual")
        end
      end
    end

    it "refreshes a materialized view" do
      connectable = ActiveRecord::Base
      a = Scenic::Adapters::Oracle.new(connectable)
      expected = <<~EOS
        begin
          dbms_mview.refresh('private_things', method => '?', atomic_refresh => FALSE);
        end;
      EOS

      expect(connectable.connection).to receive(:execute).with(expected)

      a.refresh_materialized_view("private_things", concurrently: false)
    end

    it "concurrently refreshes a materialized view" do
      connectable = ActiveRecord::Base
      a = Scenic::Adapters::Oracle.new(connectable)
      expected = <<~EOS
        begin
          dbms_mview.refresh('private_things', method => '?', atomic_refresh => TRUE);
        end;
      EOS

      expect(connectable.connection).to receive(:execute).with(expected)

      a.refresh_materialized_view("private_things", concurrently: true)
    end
  end
end
