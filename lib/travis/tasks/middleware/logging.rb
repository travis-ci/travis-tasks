module Travis
  module Tasks
    module Middleware
      class Logging
        def call(worker, message, queue, &block)
          yield
          Sidekiq.logger.info("#{message.inspect}")
        end
      end
    end
  end
end
