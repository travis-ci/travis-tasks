require 'travis/github_apps'

module Travis
  module Addons
    module GithubCheckStatus
      class Task < Travis::Task
        GITHUB_CHECK_API_PAYLOAD_LIMIT = 65535

        private

        def process(timeout)
          info("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} state=#{build[:state]} installation_id=#{installation_id} sha=#{sha}")

          if build[:state] == 'created'
            response = github_apps.post_with_app(check_run_post_url, check_status_payload.to_json)
          else
            check_run = check_runs(sha).select { |check_run| check_run["external_id"] == build[:id].to_s }.first

            if check_run
              response = github_apps.patch_with_app(check_run_patch_url(check_run["id"]), check_status_payload.to_json)
            else
              error("type=github_check_status repo=#{repository[:slug]} sha=#{sha} reason=check_runs_empty check_status_payload=#{check_status_payload.to_json}")
              return
            end
          end

          response_data = JSON.parse(response.body)

          if response.success?
            log_data = "url=#{response_data['url']} html_url=#{response_data['html_url']}"
          else
            log_data = "response_body=#{response.body}"
          end

          info "type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} sha=#{sha} response_status=#{response.status} #{log_data}"
        rescue => e
          error("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} sha=#{sha} error='#{e}' url=#{check_run_post_url} payload=#{check_status_payload}")
          raise e
        end

        def check_run_post_url
          "/repositories/#{repository[:github_id]}/check-runs"
        end

        def check_run_patch_url(id)
          "/repositories/#{repository[:github_id]}/check-runs/#{id}"
        end

        def check_runs(ref)
          path = "/repositories/#{repository[:github_id]}/commits/#{ref}/check-runs?check_name=#{URI.encode check_run_name}&filter=latest"

          response = github_apps.get_with_app(path)

          if response.success?
            response_data = JSON.parse(response.body)
            check_runs = response_data["check_runs"]
          else
            error("type=github_check_status repo=#{repository[:slug]} path=#{path} response_status=#{response.status}")
            []
          end
        end

        def check_api_media_type
          "application/vnd.github.antiope-preview+json"
        end

        def github_apps
          @github_apps ||= Travis::GithubApps.new(
            installation_id,
            apps_id: Travis.config.github_apps.id,
            private_pem: Travis.config.github_apps.private_pem,
            redis: Travis.config.redis.to_h,
            accept_header: check_api_media_type,
            debug: debug?
          )
        end

        def installation_id
          params.fetch(:installation)
        end

        def debug?
          Travis.config.github_apps.debug
        end

        def sha
          pull_request? ? request[:head_commit] : commit[:sha]
        end

        def check_run_name
          check_status_payload[:name]
        end

        def check_status_payload
          return @check_status_payload if @check_status_payload
          return_data = Output::Generator.new(payload).to_h
          if return_data.to_json.size > GITHUB_CHECK_API_PAYLOAD_LIMIT
            return_data = Output::Generator.new(payload.merge(config_display_text: "Build configuration is too large to display")).to_h
            if return_data.to_json.size > GITHUB_CHECK_API_PAYLOAD_LIMIT
              return_data = Output::Generator.new(payload.merge(config_display_text: "Build configuration is too large to display", job_info_text: "Jobs information is too large to display")).to_h
            end
          end
          @check_status_payload = return_data
        end
      end
    end
  end
end
