require 'travis/config'

module Travis
  class << self
    def config
      @config ||= Tasks::Config.load
    end

    def env
     ENV['ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
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
             github:  { url: 'https://github.com' },
             redis:   { url: "redis://localhost:6379" },
             sentry:  { },
             metrics: { reporter: 'librato' },
             sidekiq: { namespace: "sidekiq", pool_size: 3, retry: 4 },
             smtp:    { },
             ssl:     { },
             fixie:   { url: ENV['FIXIE_URL'] },
             email:   { },
             webhook: { },
             utm:     Travis.env == 'test',
             assets:  { host: HOSTS[Travis.env.to_sym] },
             irc:     { freenode_password: nil, nick: nil }

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
