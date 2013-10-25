require "active_support/core_ext/string"
require "core_ext/hash/compact"
require "core_ext/hash/deep_symbolize_keys"
require "faraday"

module Travis
  module Tasks
    class Notifier
      include Logging

      def self.perform(*args)
        new(*args).run
      end

      attr_reader :payload, :params

      def initialize(payload, params = {})
        @payload = payload.deep_symbolize_keys
        @params = params.deep_symbolize_keys
      end

      def run
        timeout(after: params[:timeout] || 60) do
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
        Timeout.timeout(options[:after], &block)
      end
    end
  end
end
