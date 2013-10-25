require "sidekiq"
require "sidekiq/redis_connection"

module Travis
  module Tasks
    module Sidekiq
      class << self
        def setup
          Travis.logger.info("Setting up Sidekiq and the Redis connection")
          Travis.logger.info("  using redis:#{Tasks.config.redis.inspect}")
          Travis.logger.info("  using sidekiq:#{Tasks.config.sidekiq.inspect}")

          ::Sidekiq.redis = ::Sidekiq::RedisConnection.create(
            url: Tasks.config.redis.url,
            namespace: Travis.config.sidekiq.namespace,
            pool_size: Travis.config.sidekiq.pool_size
          )

          if Tasks.config.log_level == :debug
            ::Sidekiq.logger = Travis.logger
          else
            ::Sidekiq.logger = nil
          end
        end
      end
    end
  end
end
