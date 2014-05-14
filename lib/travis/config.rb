require "core_ext/hash/deep_symbolize_keys"
require "hashr"
require "travis/support/logger"
require "travis/support/logging"
require "yaml"
require 'logger'
require 'pusher'

module Travis
  def self.env
   ENV['ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end

  def self.logger
    @logger ||= Travis::Logger.configure(Logger.new(STDOUT))
  end

  def self.logger=(logger)
    @logger = Travis::Logger.configure(logger)
  end

  def self.config
    @config ||= Config.new
  end

  def self.uuid= (uuid)
    Thread.current[:uuid] = uuid
  end

  def self.uuid
    Thread.current[:uuid] ||= SecureRandom.uuid
  end

  def self.pusher
    @pusher ||= ::Pusher.tap do |pusher|
      pusher.scheme = config.pusher.scheme if config.pusher.scheme.present?
      pusher.host   = config.pusher.host   if config.pusher.host.present?
      pusher.port   = config.pusher.port   if config.pusher.port.present?
      pusher.app_id = config.pusher.app_id
      pusher.key    = config.pusher.key
      pusher.secret = config.pusher.secret
    end
  end

  class Config < Hashr
    HOSTS = {
      :production  => 'travis-ci.org',
      :staging     => 'staging.travis-ci.org',
      :development => 'localhost:3000'
    }

    class << self
      def env
        ENV["ENV"] || ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
      end

      def load_env
        @load_env ||= YAML.load(ENV["travis_config"]) if ENV["travis_config"]
      end

      def load_file
        @load_file ||= YAML.load_file(filename)[env] if File.exists?(filename) rescue {}
      end

      def filename
        @filename ||= File.expand_path("config/travis.yml")
      end

      include Logging
    end

    define host:    "travis-ci.org",
           redis:   { url: "redis://localhost:6379" },
           sentry:  { },
           sidekiq: { namespace: "sidekiq", pool_size: 3 },
           smtp:    { },
           ssl:     { },
           pusher:  { },
           email:   { },
           assets:  { host: HOSTS[Travis.env.to_sym] }

    default _access: [:key]

    def initialize(data = nil, *args)
      data = (data || self.class.load_env || self.class.load_file || {}).deep_symbolize_keys
      super
    end

    def env
      self.class.env
    end

    def http_host
      "https://#{host}"
    end
  end
end
