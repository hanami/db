# frozen_string_literal: true

RSpec.describe Hanami::DB::Testing do
  subject { described_class.method(:database_url) }

  shared_examples "URL Transforms" do |scheme|
    define_method(:url) { |path| URI.join("#{scheme}://localhost", path).to_s }

    it "transforms _dev to _test" do
      expect(subject.call(url("/bookshelf_dev"))).to eq url("/bookshelf_test")
    end

    it "transforms _development to _test" do
      expect(subject.call(url("/bookshelf_development"))).to eq url("/bookshelf_test")
    end

    it "does not transform _test" do
      expect(subject.call(url("/bookshelf_test"))).to eq url("/bookshelf_test")
    end

    it "appends to non-conforming paths" do
      expect(subject.call(url("/bookshelf_database"))).to eq url("/bookshelf_database_test")
    end

    it "accepts any #to_s object such as URI" do
      url = URI("#{scheme}://localhost:5432/bookshelf_development")
      expect(subject.call(url)).to eq "#{scheme}://localhost:5432/bookshelf_test"
    end
  end

  context "postgres scheme" do
    include_examples "URL Transforms", :postgres

    it "preserves query params" do
      url = "postgres://user:pass@/bookshelf_development?host=/var/run/postgresql/.s.PGSQL.5432"
      expect(subject.call(url)).to eq "postgres://user:pass@/bookshelf_test?host=/var/run/postgresql/.s.PGSQL.5432"
    end
  end

  context "postgresql scheme" do
    include_examples "URL Transforms", :postgresql

    it "preserves query params" do
      url = "postgresql://user:pass@/bookshelf_dev?host=/var/run/postgresql/.s.PGSQL.5432"
      expect(subject.call(url)).to eq "postgresql://user:pass@/bookshelf_test?host=/var/run/postgresql/.s.PGSQL.5432"
    end
  end

  context "mysql scheme" do
    include_examples "URL Transforms", :mysql
  end

  context "sqlite scheme" do
    it "transforms _dev.db to _test.db" do
      url = "sqlite://./config/bookshelf_dev.db"
      expect(subject.call(url)).to eq "sqlite://./config/bookshelf_test.db"
    end

    it "transforms _development.db to _test.db" do
      url = "sqlite:///app/config/bookshelf_development.db"
      expect(subject.call(url)).to eq "sqlite:///app/config/bookshelf_test.db"
    end

    it "does not transform _test.db" do
      url = "sqlite://./config/bookshelf_test.db"
      expect(subject.call(url)).to eq "sqlite://./config/bookshelf_test.db"
    end

    it "appends to non-conforming filenames" do
      url = "sqlite:///app/config/bookshelf.db"
      expect(subject.call(url)).to eq "sqlite:///app/config/bookshelf_test.db"
    end

    it "ignores non-hierarchical databases" do
      url = "sqlite::memory"
      expect(subject.call(url)).to eq "sqlite::memory"
    end
  end
end
