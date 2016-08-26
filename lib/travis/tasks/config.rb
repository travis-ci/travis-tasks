require 'travis/config'

module Travis
  def self.config
    @config ||= Tasks::Config.load
  end

  module Tasks
    class Config < Travis::Config
      HOSTS = {
        :production  => 'travis-ci.org',
        :staging     => 'staging.travis-ci.org',
        :development => 'localhost:3000'
      }

      define host:    "travis-ci.org",
             github:  { url: 'https://github.com' },
             redis:   { url: "redis://localhost:6379" },
             sentry:  { },
             metrics: { reporter: 'librato' },
             sidekiq: { namespace: "sidekiq", pool_size: 3, retry: 4 },
             smtp:    { },
             ssl:     { },
             email:   { },
             webhook: { },
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
