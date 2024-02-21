module Travis
  module Addons
    module GithubCheckStatus
      class Task < Travis::Task
        GITHUB_CHECK_API_PAYLOAD_LIMIT = 65535

        private

        def process(timeout)
          return if repository[:vcs_type] != 'GithubRepository'.freeze

          info("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} state=#{build[:state]} installation_id=#{installation_id} sha=#{sha}")

          check_run = check_runs(sha).select { |check_run| check_run["external_id"] == build[:id].to_s }.first

          if check_run
            response = client.update_check_run(id: repository[:vcs_id], type: repository[:vcs_type], check_run_id: check_run["id"], payload: check_status_payload.to_json)
          else
            if build[:state] == 'created'
              response = client.create_check_run(id: repository[:vcs_id], type: repository[:vcs_type], payload: check_status_payload.to_json)
            else
              error("type=github_check_status repo=#{repository[:slug]} sha=#{sha} reason=check_runs_empty check_status_payload=#{check_status_payload.to_json}")
              return
            end
          end

          response_data = JSON.parse(response.body) if response.body&.length > 0

          if response.success?
            log_data = "url=#{response_data['url']} html_url=#{response_data['html_url']}"
          else
            log_data = "response_body=#{response.body}"
          end

          info "type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} sha=#{sha} response_status=#{response.status} #{log_data}"
        rescue => e
          error("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} sha=#{sha} error='#{e}' url=#{client.create_check_run_url(repository[:vcs_id])} payload=#{check_status_payload}")
          raise e
        end

        def check_runs(ref)
          response = client.check_runs(id: repository[:vcs_id], type: repository[:vcs_type], ref: ref, check_run_name: check_run_name)

          if response.success?
            response_data = JSON.parse(response.body)
            check_runs = response_data["check_runs"]
          else
            error("type=github_check_status repo=#{repository[:slug]} path=#{response.env.url} response_status=#{response.status}")
            []
          end
        end

        def client
          @client ||= Travis::Api.backend(repository[:vcs_id], repository[:vcs_type], installation_id: installation_id)
        end

        def installation_id
          params.fetch(:installation)
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
