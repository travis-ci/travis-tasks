require "sidekiq"
require "sidekiq/redis_connection"

module Travis
  module Notifications
    module Sidekiq
      class << self
        def setup
          Travis.logger.info("Setting up Sidekiq and the Redis connection")
          Travis.logger.info("  using redis:#{Notifications.config.redis.inspect}")
          Travis.logger.info("  using sidekiq:#{Notifications.config.sidekiq.inspect}")

          ::Sidekiq.redis = ::Sidekiq::RedisConnection.create(
            url: Notifications.config.redis.url,
            namespace: Travis.config.sidekiq.namespace,
            pool_size: Travis.config.sidekiq.pool_size
          )

          ::Sidekiq.logger = Travis.logger
        end
      end
    end
  end
end
