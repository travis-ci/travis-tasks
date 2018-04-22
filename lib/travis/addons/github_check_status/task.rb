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
          info("type=github_check_status build=#{build[:id]} repo=#{repository[:slug]} state=#{build[:state]} payload=#{payload}")

          ## DO STUFF
          response = github_apps.post_with_app(url, check_status_payload.to_json)

          info "status=#{response.status} body=#{response.body}"
        rescue => e
          info "url=#{url} payload=#{check_status_payload}"
          raise e
        end

        def url
          "/repos/#{repository[:slug]}/check-runs"
        end

        def check_api_media_type
          "application/vnd.github.antiope-preview+json"
        end

        def github_apps
          @github_apps ||= Travis::GithubApps.new(installation_id, redis: Travis.config.redis.to_h, accept_header: check_api_media_type, debug: Travis.config.gh_apps.debug)
        end

        def installation_id
          params.fetch(:installation)
        end

        def access_token
          github_apps.access_token
        end

        ## Convenience methods for building the GitHub Check API payload
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
          "Travis CI check"
        end

        def summary
          ""
        end

        def text
          ""
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
            name: "Travis CI",
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