require 'travis/rollout'
require 'faraday'
require 'travis/api'
require 'core_ext/hash/compact'
require 'core_ext/hash/deep_symbolize_keys'
require 'active_support/core_ext/string'
require 'active_support/core_ext/class/attribute'
require 'travis/support'
require 'travis/task/keenio'

module Travis
  class Task
    include Logging

    class_attribute :run_local

    DEFAULT_TIMEOUT = 60

    class << self
      extend ExceptionHandling

      def perform(*args)
        new(*args).run
      end
    end

    attr_reader :payload, :params, :retry_count

    def initialize(payload, params = {})
      @payload     = payload.deep_symbolize_keys
      @params      = params.deep_symbolize_keys
      @retry_count = params.delete(:retry_count)
    end

    def run
      with_keenio do
        process(params[:timeout] || DEFAULT_TIMEOUT)
      end
    end

    private

      def type
        self.class.name.sub('::Task', '').split('::').last.underscore
      end

      def repository
        @repository ||= payload[:repository]
      end

      def slug
        @slug ||= payload.values_at(:owner_name, :name).join("/")
      end

      def build_url
        @build_url ||= payload[:build_url]
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

      def with_utm(url, source)
        utm = { utm_source: source, utm_medium: :notification }
        Travis.config.utm ? with_query_params(url, utm) : url
      end

      def with_query_params(url, params)
        "#{url}?#{params.map { |pair| pair.join('=') }.join('&')}"
      end

      def http(url)
        @http ||= Faraday.new(http_options.merge(url: url)) do |f|
          f.request :url_encoded
          f.use FaradayMiddleware::FollowRedirects, limit: 5
          f.headers["User-Agent"] = user_agent_string
          f.adapter :net_http
        end
      end

      def http_options
        {
          ssl: Travis.config.ssl.compact,
          proxy: Travis.config.fixie.url
        }.compact
      end

      def base_url(endpoint)
        url = URI.parse(endpoint)
        base_url = "#{url.scheme}://#{url.host}"
      end

      def with_keenio
        yield
      rescue => e
      ensure
        status = e ? :failure : :success
        notify_keenio(status) if notify_keenio?(status)
        raise e if e
      end

      def notify_keenio?(status)
        return unless ENV['KEEN_PROJECT_ID']
        status == :success || retry_count == Travis.config.sidekiq.retry
      end

      def notify_keenio(status)
        Travis::Task::Keenio.new(type, status, payload).publish
      end

      def user_agent_string
        ["travis-tasks", ENV['HEROKU_SLUG_COMMIT']].compact.join(" ")
      end
  end
end
