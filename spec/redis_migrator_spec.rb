# frozen_string_literal: true

RSpec.describe RedisMigrator do
  it 'has a version number' do
    expect(RedisMigrator::VERSION).not_to be nil
  end

  describe described_class::Configuration do
    it { is_expected.to respond_to :target }

    describe 'defaults to ENV variables' do
      it do
        expect(subject.source.connection).to eq(
          host: 'source', port: 6379, db: 0,
          id: 'redis://source:6379/0',
          location: 'source:6379'
        )
      end

      it do
        expect(subject.target.connection).to eq(
          host: 'target', port: 6379, db: 0,
          id: 'redis://target:6379/0',
          location: 'target:6379'
        )
      end
    end
  end

  describe '.configure' do
    let(:config_block) { ->(config) {} }

    it 'yields a config block' do
      expect { |config| described_class.configure(&config) }
        .to yield_with_args(RedisMigrator::Configuration)
    end
  end
end
