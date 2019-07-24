# frozen_string_literal: true

require 'redis_migrator/version'
require 'redis'
require 'forwardable'

# migrate date from one redis instance to another
module RedisMigrator
  class Error < StandardError; end

  # configure source and target
  class Configuration
    attr_accessor :source, :target, :worker_count

    def initialize
      self.source       = Redis.new(url: ENV['REDIS_MIGRATOR_SOURCE_URL'])
      self.target       = Redis.new(url: ENV['REDIS_MIGRATOR_TARGET_URL'])
      self.worker_count = 5
    end
  end

  class << self
    attr_accessor :configuration

    extend Forwardable
    def_delegators :@configuration, :source, :target, :worker_count

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end
  end

  configure
end
