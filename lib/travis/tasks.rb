require 'bundler/setup'
require 'gh'
require 'travis'
require 'roadie'
require 'roadie/action_mailer_extensions'
require 'ostruct'

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

module Roadie
  def self.app
    @_config ||= OpenStruct.new(roadie: OpenStruct.new(enabled: true, provider: nil, after_inlining: nil))
    @_application ||= OpenStruct.new(config: @_config, root: Pathname.new(Dir.pwd))
  end
end

ActiveSupport.on_load(:action_mailer) do
  include Roadie::ActionMailerExtensions
end

Travis::Exceptions::Reporter.start
Travis::Notification.setup
Travis::Mailer.setup
Travis::Addons.register

