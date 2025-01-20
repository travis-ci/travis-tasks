require 'travis/logger'
require 'travis/support/exception_handling'
require 'travis/support/logging'
require 'connection_pool'

module Travis
  class << self
    def logger
      @logger ||= Logger.configure(Logger.new(STDOUT), config)
    end

    def logger=(logger)
      @logger = Logger.configure(logger, config)
    end

    def redis_pool
      @redis_pool ||= ConnectionPool.new {
        Redis.new(
                    url: Travis.config.redis.url,
                    ssl: Travis.config.redis.ssl || false,
                    ssl_params: redis_ssl_params
                  )
      }
    end

    def redis_ssl_params
      @redis_ssl_params ||=
        begin
          return nil unless Travis.config.redis.ssl

          value = {}
          value[:ca_path] = ENV['REDIS_SSL_CA_PATH'] if ENV['REDIS_SSL_CA_PATH']
          value[:cert] = OpenSSL::X509::Certificate.new(File.read(ENV['REDIS_SSL_CERT_FILE'])) if ENV['REDIS_SSL_CERT_FILE']
          value[:key] = OpenSSL::PKEY::RSA.new(File.read(ENV['REDIS_SSL_KEY_FILE'])) if ENV['REDIS_SSL_KEY_FILE']
          value[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if Travis.config.ssl_verify == false
          value
        end
    end

  end
end
