module Travis
  module Addons
    module CheckStatus
      class Task < Travis::Task
        GITHUB_CHECK_API_PAYLOAD_LIMIT = 65535

        private

        def process(timeout)
          info("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} state=#{build[:state]} installation_id=#{params.fetch(:installation)} sha=#{sha}")

          if build[:state] == 'created'
            log_response(create_check_run)
          else
            check_run = find_check_run(build[:id].to_s)
            log_response(update_check_run(check_run)) if check_run
          end
        end

        def create_check_run
          Travis::RemoteVCS::Repository.new.create_check_run(repository[:vcs_id], check_status_payload.to_json)
        end

        def update_check_run(check_run)
          Travis::RemoteVCS::Repository.new.update_check_run(repository[:vcs_id], check_run["id"], check_status_payload.to_json)
        end

        def log_response(resp)
          if resp.success?
            data = JSON.parse(resp.body)
            log_data = "url=#{data['url']} html_url=#{data['html_url']}"
          else
            log_data = "response_body=#{resp.body}"
          end

          info("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} sha=#{sha} response_status=#{resp.status} #{log_data}")
        end

        def find_check_run(check_run_id)
          check_run_name = check_status_payload[:name]
          resp = Travis::RemoteVCS::Repository.new.check_runs(repository[:vcs_id], sha, check_run_name)

          if resp.success?
            check_runs = JSON.parse(resp.body)["check_runs"]
            check_runs.find { |check_run| check_run["external_id"] == check_run_id }
          else
            error("type=github_check_status repo=#{repository[:slug]} sha=#{sha} reason=check_runs_empty check_status_payload=#{check_status_payload.to_json} response_status=#{resp.status}")
          end
        end

        def check_api_media_type
          "application/vnd.github.antiope-preview+json"
        end

        def sha
          pull_request? ? request[:head_commit] : commit[:sha]
        end

        def check_status_payload
          @check_status_payload ||= begin
            data = Output::Generator.new(payload).to_h
            if data.to_json.size > GITHUB_CHECK_API_PAYLOAD_LIMIT
              Output::Generator.new(data.merge(config_display_text: "Build configuration is too large to display")).to_h
            else
              data
            end
          end
        end
      end
    end
  end
end
