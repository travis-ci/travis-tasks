require 'bundler/setup'
require 'gh'
require 'travis'
require 'roadie'
require 'roadie/action_mailer_extensions'
require 'ostruct'

$stdout.sync = true

class MetriksMiddleware
  def call(worker, message, queue, &block)
    begin
      ::Metriks.meter("tasks.jobs.#{queue}").mark
      ::Metriks.timer("tasks.jobs.#{queue}.perform").time(&block)
    rescue Exception
      ::Metriks.meter("tasks.jobs.#{queue}.failure").mark
      raise
    end
  end
end

Sidekiq.configure_server do |config|
  config.redis = {
    :url       => Travis.config.redis.url,
    :namespace => Travis.config.sidekiq.namespace
  }
  config.logger = nil unless Travis.config.log_level == :debug
  config.server_middleware do |chain|
    chain.add MetriksMiddleware
    if Travis.config.sentry.empty?
      if defined?(::Raven::Sidekiq)
        chain.remove(::Raven::Sidekiq)
      end
    end
  end
end

GH::DefaultStack.options[:ssl] = Travis.config.ssl
Travis.config.update_periodically

module Roadie
  def self.app
    @_config ||= OpenStruct.new(roadie: OpenStruct.new(enabled: true, provider: nil, after_inlining: nil))
    @_application ||= OpenStruct.new(config: @_config, root: Pathname.new(Dir.pwd))
  end
end

ActiveSupport.on_load(:action_mailer) do
  include Roadie::ActionMailerExtensions
end

if Travis.config.sentry
  Travis::Exceptions::Reporter.start
end

Travis::Notification.setup
Travis::Mailer.setup
Travis::Addons.register

