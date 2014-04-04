$:.unshift(File.expand_path(File.dirname(__FILE__) + "/.."))

require 'bundler/setup'
require 'gh'
require 'roadie'
require 'roadie/action_mailer_extensions'
require 'ostruct'
require 'travis/tasks/error_handler'
require 'travis/support/async'
require 'travis/config'
require 'travis/task'
require 'travis/addons'
require 'travis/tasks/middleware/metriks'
require 'travis/tasks/middleware/logging'

$stdout.sync = true

Sidekiq.configure_server do |config|
  config.redis = {
    :url       => Travis.config.redis.url,
    :namespace => Travis.config.sidekiq.namespace
  }
  config.server_middleware do |chain|
    chain.add Travis::Tasks::Middleware::Metriks
    chain.add Travis::Tasks::Middleware::Logging

    if defined?(::Raven::Sidekiq)
      chain.remove(::Raven::Sidekiq)
    end

    chain.add(Travis::Tasks::ErrorHandler)
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

Travis::Addons::Email.setup
