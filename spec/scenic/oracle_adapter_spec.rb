RSpec.describe Scenic::OracleAdapter do
  let(:adapter) { Scenic::Adapters::Oracle.new }

  after do
    drop_all_views
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
    view = adapter.views.find { |view| view.name == "blah" }
    expect(view.definition).to eq("select 2 as a from dual")
  end

  it "updates a view" do
    adapter.create_view("blah", "select 1 as a from dual")
    expect(view_exists?("blah")).to be true
    adapter.update_view("blah", "select 1 as a, 2 as b from dual")
    view = adapter.views.find { |view| view.name == "blah" }
    expect(view.definition).to eq("select 1 as a, 2 as b from dual")
  end
end
