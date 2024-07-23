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
        count_request
        github_apps.post_with_app("#{api_path}/repositories/#{id}/check-runs", payload)
      end

      def update_check_run(id:, type:, check_run_id:, payload:)
        count_request
        github_apps.patch_with_app("#{api_path}/repositories/#{id}/check-runs/#{check_run_id}", payload)
      end

      def check_runs(id:, type:, ref:, check_run_name:)
        path = "#{api_path}/repositories/#{id}/commits/#{ref}/check-runs?check_name=#{URI::Parser.new.escape(check_run_name)}&filter=all"
        count_request
        github_apps.get_with_app(path)
      end

      def create_status(process_via_gh_apps:, id:, type:, ref:, payload:)
        url = "#{api_path}/repositories/#{id}/statuses/#{ref}"

        count_request
        if process_via_gh_apps
          github_apps.post_with_app(url, payload)
        else
          GH.post(url, payload)
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

      def api_path
        @api_path ||= URI(GH.api_host).path
      end
    end
  end
end
