$:.unshift(File.expand_path('..', File.dirname(__FILE__)))

require 'bundler/setup'
require 'roadie'
require 'ostruct'
require 'travis/exceptions'
require 'travis/logger'
require 'travis/metrics'
require 'travis/tasks/error_handler'
require 'travis/tasks/config'
require 'travis/tasks/worker'
require 'travis/task'
require 'travis/addons'
require 'travis/tasks/middleware/metriks'
require 'travis/tasks/middleware/logging'

$stdout.sync = true

if Travis.config.sentry.dsn
  require 'raven'
  Raven.configure do |config|
    config.dsn = Travis.config.sentry.dsn

    config.current_environment = Travis.env
    config.environments = ["staging", "production"]
    config.excluded_exceptions = ['Timeout::Error']
  end
end

class RetryCount
  def call(worker, msg, queue)
    worker.retry_count = msg['retry_count']
    yield
  end
end

Sidekiq.configure_server do |config|
  config.redis = {
    :url       => Travis.config.redis.url,
    :namespace => Travis.config.sidekiq.namespace
  }
  config.server_middleware do |chain|
    chain.add Travis::Tasks::Middleware::Metriks
    chain.add Travis::Tasks::Middleware::Logging
    chain.add RetryCount

    if defined?(::Raven::Sidekiq)
      chain.remove(::Raven::Sidekiq)
    end

    chain.remove(Sidekiq::Middleware::Server::Logging)
    chain.add(Travis::Tasks::ErrorHandler)
    chain.add Sidekiq::Middleware::Server::RetryJobs, :max_retries => Travis.config.sidekiq.retry
  end
end

Sidekiq.configure_client do |c|
  url = Travis.config.redis.url
  config = Travis.config.sidekiq
  c.redis = { url: url, namespace: config[:namespace], size: config[:pool_size] }
end

module Roadie
  def self.app
    @_config ||= OpenStruct.new(roadie: OpenStruct.new(enabled: true, provider: nil, after_inlining: nil))
    @_application ||= OpenStruct.new(config: @_config, root: Pathname.new(Dir.pwd))
  end
end

if Travis.config.sentry
  Travis::Exceptions.setup(Travis.config, Travis.config.env, Travis.logger)
end

Travis.logger.info("Tasks started with Ciphers: #{OpenSSL::Cipher.ciphers.sort}")

Travis::Metrics.setup(Travis.config.metrics, Travis.logger)
Travis::Addons::Email.setup
