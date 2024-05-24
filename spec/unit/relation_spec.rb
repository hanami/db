# frozen_string_literal: true

RSpec.describe Hanami::DB::Relation do
  subject(:relation) { Class.new(described_class) }

  it "defaults to the :sql adapter" do
    expect(relation.adapter).to eq :sql
  end
end
