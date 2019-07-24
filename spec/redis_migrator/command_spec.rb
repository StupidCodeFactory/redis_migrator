# frozen_string_literal: true

require 'redis_migrator/command'

RSpec.describe RedisMigrator::Command do
  before do
    1.upto(1000) do |i|
      RedisMigrator.source.set i, i
    end
  end

  after do
    RedisMigrator.source.flushall
    RedisMigrator.target.flushall
  end

  it 'migrates all the keys from source to target' do
    expect do
      described_class.start
    end.to change {
      RedisMigrator.target.keys.sort
    }.from([]).to(RedisMigrator.source.keys.sort)
  end
end
