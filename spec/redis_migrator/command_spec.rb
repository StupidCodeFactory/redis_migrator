# frozen_string_literal: true

require 'redis_migrator/command'

RSpec.describe RedisMigrate::Command do
  describe '.start' do
    let(:key_1) { 'key_1' }
    let(:key_2) { 'key_2' }
    let(:source) { instance_spy(Redis, scan: ['0', [key_1, key_2]]) }
    let(:target) { instance_spy(Redis) }

    describe 'actual processing' do
      before { 1.upto(1000) { |i| RedisMigrate.source.set i, i } }

      after do
        RedisMigrate.source.flushall
        RedisMigrate.target.flushall
      end

      it 'migrates all the keys from source to target' do
        expect { described_class.start }.to change {
          RedisMigrate.target.keys.sort
        }.from([]).to(RedisMigrate.source.keys.sort)
      end
    end

    context 'with configuration' do
      let(:worker_count) { 2 }
      let(:thread_pool) do
        instance_spy(
          Concurrent::FixedThreadPool,
          post: nil,
          shutdown: nil,
          wait_for_termination: nil
        )
      end

      before do
        RedisMigrate.configure do |config|
          config.worker_count = worker_count
          config.source = source
          config.target = target
        end
      end

      it 'configured correctly worker count' do
        allow(Concurrent::FixedThreadPool)
          .to receive(:new).with(worker_count).and_return(thread_pool)

        described_class.start

        expect(Concurrent::FixedThreadPool)
          .to have_received(:new).with(worker_count)
      end

      context 'with source and target configuration' do
        before do
          allow(source).to receive(:dump).with(key_1).and_return('dump_key_1')
          allow(source).to receive(:dump).with(key_2).and_return('dump_key_2')
          allow(source).to receive(:ttl).with(key_1).and_return(-1)
          allow(source).to receive(:ttl).with(key_2).and_return(1)
        end

        it 'restores on keys on the confugred target' do
          described_class.start

          expect(target)
            .to have_received(:restore).once.with(key_1, 0, 'dump_key_1')
          expect(target)
            .to have_received(:restore).once.with(key_2, 1, 'dump_key_2')
        end

        it 'scans for existing keys' do
          described_class.start

          expect(source)
            .to have_received(:scan).exactly(1).times.with(0, count: 100)
        end
      end
    end
  end
end
