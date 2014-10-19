require 'travis/config'
require 'pusher'

module Travis
  def self.config
    @config ||= Tasks::Config.load
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

  module Tasks
    class Config < Travis::Config
      HOSTS = {
        :production  => 'travis-ci.org',
        :staging     => 'staging.travis-ci.org',
        :development => 'localhost:3000'
      }

      define host:    "travis-ci.org",
             redis:   { url: "redis://localhost:6379" },
             sentry:  { },
             metrics: { reporter: 'librato' },
             sidekiq: { namespace: "sidekiq", pool_size: 3 },
             smtp:    { },
             ssl:     { },
             pusher:  { },
             email:   { },
             assets:  { host: HOSTS[Travis.env.to_sym] }

      default _access: [:key]

      def env
        Travis.env
      end

      def http_host
        "https://#{host}"
      end
    end
  end
end
