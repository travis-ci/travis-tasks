require "core_ext/hash/deep_symbolize_keys"
require "hashr"
require "travis/support/logging"
require "yaml"

module Travis
  module Tasks
    class Config < Hashr
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

      define redis:   { url: "redis://localhost:6379" },
             sentry:  { },
             sidekiq: { namespace: "sidekiq", pool_size: 3 },
             smtp:    { },
             ssl:     { }

      default _access: [:key]

      def initialize(data = nil, *args)
        data = (data || self.class.load_env || self.class.load_file || {}).deep_symbolize_keys
        super
      end

      def env
        self.class.env
      end
    end
  end
end
