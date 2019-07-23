# frozen_string_literal: true

require 'redis_migrator/version'

module RedisMigrator
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end
end
