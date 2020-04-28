require 'metriks'
require 'travis/github_apps'

module Travis
  module Backends
    class Github < Travis::Backends::Base
      def initialize(installation_id)
        @installation_id = installation_id
      end

      def name
        'github_apps'
      end

      def create_check_run(id:, type:, payload:)
        github_apps.post_with_app("/repositories/#{id}/check-runs", payload) if in_limit?
      end

      def update_check_run(id:, type:, check_run_id:, payload:)
        github_apps.patch_with_app("/repositories/#{id}/check-runs/#{check_run_id}", payload) if in_limit?
      end

      def check_runs(id:, type:, ref:, check_run_name:)
        path = "/repositories/#{id}/commits/#{ref}/check-runs?check_name=#{URI.encode(check_run_name)}&filter=all"
        github_apps.get_with_app(path) if in_limit?
      end

      def create_status(process_via_gh_apps:, id:, type:, ref:, payload:)
        url = "/repositories/#{id}/statuses/#{ref}"

        if process_via_gh_apps
          github_apps.post_with_app(url, payload) if in_limit?
        else
          GH.post(url, payload) if in_limit?
        end
      end

      def file_url(id:, type:, slug:, branch:, file:)
        "#{Travis.config.github.url}/#{slug}/blob/#{branch}/#{file}"
      end

      def branch_url(id:, type:, slug:, branch:)
        "#{Travis.config.github.url}/#{slug}/tree/#{branch}"
      end

      def create_check_run_url(id)
        "#{GH.api_host}/repositories/#{id}/check-runs"
      end

      def create_status_url(id, ref)
        "#{GH.api_host}/repositories/#{id}/statuses/#{ref}"
      end

    private

      def in_limit?
        if get_current_calls_counter <= max_calls_per_hour
          update_current_calls_counter
          count_request
          return true
        end
        false
      end

      def max_calls_per_hour
        Travis.config.github.max_calls_per_hour || 62500
      end

      def get_current_calls_counter
        Travis.redis_pool.with do |redis|
          return redis.get("gh_api_calls_#{Time.now.hour}").to_i
        end
        0
      end

      def update_current_calls_counter
        Travis.redis_pool.with do |redis|
          redis.multi do |multi|
            multi.incr("gh_api_calls_#{Time.now.hour}")
            multi.expire("gh_api_calls_#{Time.now.hour}", 60*60)
          end
        end
      end

      def count_request
        ::Metriks.meter("travis.github_api.requests").mark
      end

      def github_apps
        @github_apps ||= Travis::GithubApps.new(
          @installation_id,
          apps_id:        Travis.config.github_apps.id,
          private_pem:    Travis.config.github_apps.private_pem,
          redis:          Travis.config.redis.to_h,
          debug:          Travis.config.github_apps.debug,
          accept_header:  'application/vnd.github.antiope-preview+json'
        )
      end
    end
  end
end
