$:.unshift(File.expand_path('..', File.dirname(__FILE__)))

require 'bundler/setup'
require 'gh'
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
require 'sidekiq'
require 'sidekiq/api'

$stdout.sync = true

if Travis.config.sentry.dsn
  Sentry.init do |config|
    config.dsn = Travis.config.sentry.dsn

    config.environment = Travis.env
    config.enabled_environments = ["staging", "production"]
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
    :url       => Travis.config.redis.url
  }
  config.server_middleware do |chain|
    chain.add Travis::Tasks::Middleware::Metriks
    chain.add Travis::Tasks::Middleware::Logging
    chain.add RetryCount

    chain.remove(Sidekiq::JobLogger)
    chain.add(Travis::Tasks::ErrorHandler)
  end
end

Sidekiq.configure_client do |c|
  url = Travis.config.redis.url
  config = Travis.config.sidekiq
  c.redis = { url: url, size: config[:pool_size] }
end
Sidekiq.default_configuration[:max_retries] = Travis.config.sidekiq.retry

GH.set(
  client_id:      Travis.config.oauth2.try(:client_id),
  client_secret:  Travis.config.oauth2.try(:client_secret),
  origin:         Travis.config.host,
  api_url:        Travis.config.github.api_url,
  ssl:            Travis.config.ssl.to_h.merge(Travis.config.github.ssl || {}).to_h.compact,
  formatter:      Travis.config.github_status.formatter,
  user_agent:     "Travis-CI GH/#{GH::VERSION}"
)

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
