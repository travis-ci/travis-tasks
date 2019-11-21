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
        github_apps.post_with_app("/repositories/#{id}/check-runs", payload)
      end

      def update_check_run(id:, type:, check_run_id:, payload:)
        github_apps.patch_with_app("/repositories/#{id}/check-runs/#{check_run_id}", payload)
      end

      def check_runs(id:, type:, ref:, check_run_name:)
        path = "/repositories/#{id}/commits/#{ref}/check-runs?check_name=#{URI.encode(check_run_name)}&filter=all"
        github_apps.get_with_app(path)
      end

      def create_status(process_via:, id:, type:, ref:, payload:)
        url = "/repositories/#{repository[:vcs_id]}/statuses/#{ref}"

        if process_via == 'gh'
          GH.post(url, payload)
        else
          client.post_with_app(url, payload)
        end
      end

      def file_url(id:, type:, slug:, branch:, file:)
        "#{Travis.config.github.url}/#{slug}/blob/#{branch}/#{file}"
      end

      def branch_url(id:, type:, slug:, branch:)
        "#{Travis.config.github.url}/#{slug}/tree/#{branch}"
      end

    private

      def github_apps
        @github_apps ||= Travis::GithubApps.new(
          @installation_id,
          apps_id:        Travis.config.github_apps.id,
          private_pem:    Travis.config.github_apps.private_pem,
          redis:          Travis.config.redis.to_h,
          debug:          Travis.config.github_apps.debug
          accept_header:  'application/vnd.github.antiope-preview+json',
        )
      end
    end
  end
end
