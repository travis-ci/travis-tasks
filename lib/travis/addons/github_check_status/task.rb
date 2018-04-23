require 'travis/github_apps'

module Travis
  module Addons
    module GithubCheckStatus
      class Task < Travis::Task
        STATUS = {
          'created'  => 'queued',
          'queued'   => 'queued',
          'started'  => 'in_progress',
          'passed'   => 'completed',
          'failed'   => 'completed',
          'errored'  => 'completed',
          'canceled' => 'completed',
        }

        CONCLUSION = {
          'passed'   => 'success',
          'failed'   => 'failure',
          'errored'  => 'action_required',
          'canceled' => 'neutral',
        }

        private

        def process(timeout)
          info("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} state=#{build[:state]} payload=#{check_status_payload}")

          ## DO STUFF
          if build[:state] == 'created'
            response = github_apps.post_with_app(check_run_post_url, check_status_payload.to_json)
          else
            check_run = check_runs(sha).first
            if check_run
              response = github_apps.patch_with_app(check_run_patch_url(check_run["id"]), check_status_payload.to_json)
            end
          end

          if response.success?
            response_data = JSON.parse(response.body)
            log_data = "url=#{response_data['url']} html_url=#{response_data['html_url']}"
          end

          info "type=github_check_status response_status=#{response.status} #{log_data}"
        rescue => e
          info "type=github_check_status error='#{e}' url=#{check_run_post_url} payload=#{check_status_payload}"
          raise e
        end

        def check_run_post_url
          "/repos/#{repository[:slug]}/check-runs"
        end

        def check_run_patch_url(id)
          "/repos/#{repository[:slug]}/check-runs/#{id}"
        end

        def check_runs(ref)
          path = "/repos/#{repository[:slug]}/commits/#{ref}/check-runs?#{URI.encode check_run_name}&filter=latest"

          response = github_apps.get_with_app(path)

          if response.success?
            response_data = JSON.parse(response.body)
            check_runs = response_data["check_runs"]
          end
        end

        def check_api_media_type
          "application/vnd.github.antiope-preview+json"
        end

        def github_apps
          @github_apps ||= Travis::GithubApps.new(installation_id, redis: Travis.config.redis.to_h, accept_header: check_api_media_type, debug: debug?)
        end

        def installation_id
          params.fetch(:installation)
        end

        def debug?
          Travis.config.gh_apps.debug
        end

        def type
          pull_request? ? "Pull Request" : "#{branch} Branch"
        end

        ## Convenience methods for building the GitHub Check API payload
        def check_run_name
          "Travis CI #{type} Build"
        end

        def status
          STATUS[build[:state]]
        end

        def conclusion
          CONCLUSION[build[:state]]
        end

        def branch
          commit[:branch]
        end

        def sha
          pull_request? ? request[:head_commit] : commit[:sha]
        end

        def details_url
          "#{Travis.config.http_host}/#{repository[:slug]}/builds/#{build[:id]}"
        end

        def external_id
          build[:id]
        end

        def completed_at
          build[:finished_at]
        end

        def title
          "Travis CI #{type} Build Result"
        end

        def summary
          "Build #{build[:state]}"
        end

        def text
          """# Summary

          Markdown text we can text

          [More documentation](https://docs.travis-ci.com)
          """.split("\n").map(&:lstrip).join("\n")
        end

        def output
          {
            title: title,
            summary: summary,
            text: text,
            # annotations: [],
            # images: []
          }
        end

        def check_status_payload
          return @data if @data

          @data = {
            name: check_run_name,
            branch: branch,
            sha: sha,
            details_url: details_url,
            external_id: external_id,
            status: status,
            output: output
          }

          if status == 'completed'
            @data.merge!({conclusion: conclusion, completed_at: completed_at})
          end

          @data
        end
      end
    end
  end
end