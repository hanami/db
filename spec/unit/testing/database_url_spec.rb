# frozen_string_literal: true

RSpec.describe Hanami::DB::Testing do
  subject { described_class.method(:database_url) }

  it "transforms _dev to _test" do
    expect(subject.call("/bookshelf_dev")).to eq "/bookshelf_test"
  end

  it "transforms _development to _test" do
    expect(subject.call("/bookshelf_development")).to eq "/bookshelf_test"
  end

  it "does not transform _test" do
    expect(subject.call("/bookshelf_test")).to eq "/bookshelf_test"
  end

  it "appends to non-conforming paths" do
    expect(subject.call("/bookshelf_database")).to eq "/bookshelf_database_test"
  end

  it "accepts any #to_s object such as URI" do
    url = URI("postgres://localhost:5432/bookshelf_development")
    expect(subject.call(url)).to eq "postgres://localhost:5432/bookshelf_test"
  end
end
