require 'travis/logger'
require 'travis/support/exception_handling'
require 'travis/support/logging'
require 'connection_pool'

module Travis
  class << self
    def logger
      @logger ||= Logger.configure(Logger.new(STDOUT), config)
    end

    def logger=(logger)
      @logger = Logger.configure(logger, config)
    end

    def redis_pool
      @redis_pool ||= ConnectionPool.new { Redis.new( url: Travis.config.redis.url ) }
    end
  end
end
