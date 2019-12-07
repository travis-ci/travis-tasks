# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

module Travis
  module Backends
    class VcsClient

      def post(path, params = {})
        client.post(path, params.to_json)
      end

      def method_missing(method, *args)
        client.send(method, *args)
      end

    private

      def client
        @client ||= Faraday.new(ssl: Travis.config.ssl.to_h, url: Travis.config.vcs.url) do |c|
          c.request :authorization, :token, Travis.config.vcs.token
          c.request :retry, max: 5, interval: 0.1, backoff_factor: 2
          c.request :json
          c.use FaradayMiddleware::Instrumentation
          c.request :retry
          c.response :raise_error
          c.adapter :net_http
        end
      end
    end
  end
end
