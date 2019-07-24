# frozen_string_literal: true

require 'concurrent/executor/fixed_thread_pool'
require 'redis_migrator'

module RedisMigrate
  # command line processing
  # ripped off from https://dev.to/afilmycode/how-we-migrated-aws-elasticache-redis-cluster-to-another-in-production-297f
  class Command
    def self.start
      new.start
    end

    def start
      current = 0
      is_first = true

      while current.to_i != 0 || is_first
        is_first      = false
        current, keys = source.scan(current.to_i, count: 100)

        keys.each { |key| pool.post { dump_and_restore(key) } }
      end

      pool.shutdown
      pool.wait_for_termination
    end

    private

    attr_accessor :is_first

    def source
      RedisMigrate.source
    end

    def target
      RedisMigrate.target
    end

    def ttl_for(key)
      ttl = source.ttl(key)
      ttl = 0 if ttl == -1
      ttl
    end

    def dump_and_restore(key)
      target.restore(key, ttl_for(key), source.dump(key))
    end

    def pool
      @pool ||= Concurrent::FixedThreadPool.new(RedisMigrate.worker_count)
    end
  end
end
