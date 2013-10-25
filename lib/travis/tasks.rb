$LOAD_PATH << File.expand_path("../..", __FILE__)

require 'bundler/setup'
require 'gh'
require 'core_ext/module/load_constants'
require 'roadie'
require 'roadie/action_mailer_extensions'
require 'ostruct'
require "travis/support"
require "travis/tasks/config"
require "travis/mailer"
require "travis/addons"
require "travis/task"

$stdout.sync = true

module Travis
  def self.config
    Tasks.config
  end

  module Tasks
    def self.config
      @config ||= Config.new
    end
  end
end

Sidekiq.configure_server do |config|
  config.redis = {
    :url       => Travis.config.redis.url,
    :namespace => Travis.config.sidekiq.namespace
  }
  #config.logger = nil unless Travis.config.log_level == :debug
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
Travis::Mailer.setup

