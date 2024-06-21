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

      class << self
        def http_basic_auth
          tokens = ENV['HTTP_BASIC_AUTH'] || ''
          tokens.split(',').map { |token| token.split(':').map(&:strip) }.to_h
        end
      end

      define host:    "travis-ci.org",
             host_domain: 'travis-ci.com',
             github:  { url: 'https://github.com' },
             redis:   { url: "redis://localhost:6379" },
             sentry:  { },
             metrics: { reporter: 'librato' },
             sidekiq: { pool_size: 3, retry: 4 },
             smtp:    { },
             ssl:     { },
             fixie:   { url: ENV['FIXIE_URL'] },
             email:   { },
             webhook: { },
             utm:     Travis.env == 'test',
             assets:  { host: HOSTS[Travis.env.to_sym] },
             s3:      { url: 'https://s3.amazonaws.com/travis-email-assets'},
             irc:     { freenode_password: nil, nick: nil },
             librato: { email: nil, token: nil },
             auth:    { jwt_public_key: ENV['JWT_RSA_PUBLIC_KEY'], http_basic_auth: http_basic_auth },
             github_apps: { debug: ENV['GITHUB_APPS_DEBUG'] },
             github_status: { },
             vcs:     { url: 'https://travis-vcs-staging.herokuapp.com/', token: '' },
             enterprise_platform: { host: ENV['TRAVIS_HOSTNAME']},
             plan_path: 'plan',
             purchase_path: 'purchase',
             settings_path: 'settings',
             payment_details_path: 'payment-details',
             intercom: { token: 'token' },
             admin_v2: { url: 'https://admin-v2.travis-ci.com' },
             enterprise: false


      default _access: [:key]

      def metrics
        # TODO cleanup keychain?
        super.to_h.merge(librato: librato.to_h.merge(source: librato_source))
      end

      def env
        Travis.env
      end

      def http_host
        "https://#{host}"
      end
    end
  end
end
