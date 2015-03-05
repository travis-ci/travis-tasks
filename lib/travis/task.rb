require 'faraday'
require 'core_ext/hash/compact'
require 'core_ext/hash/deep_symbolize_keys'
require 'active_support/core_ext/string'
require 'active_support/core_ext/class/attribute'
require 'travis/support/logging'
require 'travis/support/exceptions'

module Travis
  class Task
    include Logging

    class_attribute :run_local

    class << self
      extend Exceptions::Handling

      def run(queue, *args)
        Travis::Async.run(self, :perform, async_options(queue), *args)
      end

      def perform(*args)
        new(*args).run
      end
    end

    attr_reader :payload, :params

    def initialize(payload, params = {})
      @payload = payload.deep_symbolize_keys
      @params  = params.deep_symbolize_keys
    end

    def run
      timeout after: params[:timeout] || 60 do
        process
      end
    end

    private

      def repository
        @repository ||= payload[:repository]
      end

      def job
        @job ||= payload[:job]
      end

      def build
        @build ||= payload[:build]
      end

      def request
        @request ||= payload[:request]
      end

      def commit
        @commit ||= payload[:commit]
      end

      def pull_request?
        build[:pull_request]
      end

      def pull_request_number
        if pull_request?
          payload[:pull_request_number]
        end
      end

      def http
        @http ||= Faraday.new(http_options) do |f|
          f.request :url_encoded
          f.adapter :net_http
        end
      end

      def http_options
        { ssl: Travis.config.ssl.compact }
      end

      def timeout(options = { after: 60 }, &block)
        Timeout::timeout(options[:after], &block)
      end
  end
end
