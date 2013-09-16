require 'bundler/setup'
require 'gh'
require 'travis'
require 'core_ext/module/load_constants'
require 'roadie'

$stdout.sync = true

Sidekiq.configure_server do |config|
  config.redis = {
    :url       => Travis.config.redis.url,
    :namespace => Travis.config.sidekiq.namespace
  }
  config.logger = nil unless Travis.config.log_level == :debug
end

GH::DefaultStack.options[:ssl] = Travis.config.ssl
Travis.config.update_periodically

ActiveSupport.on_load(:action_mailer) do
  include Roadie::ActionMailerExtensions
end

Travis::Exceptions::Reporter.start
Travis::Notification.setup
Travis::Mailer.setup
Travis::Addons.register

