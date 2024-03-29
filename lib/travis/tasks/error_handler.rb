
module Travis
  module Tasks
    class ErrorHandler
      def call(worker, job, queue)
        yield
      rescue => ex
        Sidekiq.logger.warn(ex)

        if Travis.config.sentry.any?
          Sentry.capture_exception(ex, extra: {sidekiq: job})
        end

        raise
      end
    end
  end
end
